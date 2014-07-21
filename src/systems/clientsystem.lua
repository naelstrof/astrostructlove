-- Majority of the work is already done with my demoing system :)

local ClientSystem = {
    running = false,
    time = 0,
    players = nil,
    tick = 0,
    lastrecievetime = 0,
    lastshot = nil,
    prevshot = nil,
    timeout = 10,
    nextshot = nil,
    newesttick = 0,
    id = nil,
    player = nil,
    playerpos = Vector( 0, 0 ),
    predictionfixspeed = 2,
    -- I wanted to be like source multiplayer and make a render
    -- delay so we can always be interpolating, but all it caused
    -- was instability and weirdness
    delay = 0/1000,
    client = nil,
    snapshots = {}
}

function ClientSystem:setID( id )
    self.id = id
    -- Find our player
    for i,v in pairs( DemoSystem.entities ) do
        if v.playerid == self.id then
            self.player = v
            self.player:setLocalPlayer( true )
        end
    end
end

function ClientSystem:updatePlayers( players )
    local copy = {}
    for i,v in pairs( players ) do
        copy[ v.id ] = v
    end
    if not self.players then
        self.players = copy
    else
        for i,v in pairs( copy ) do
            self.players[ i ] = table.merge( self.players[ i ], v )
        end
    end
end

function ClientSystem:startLobby( ip, port )
    self.client = lube.udpClient()
    self.client:init()
    self.client:setPing( true, 10, "p" )
    self.client.callbacks = { recv = self.onLobbyReceive, disconnect = self.onDisconnect }
    self.client.handshake = Game.version
    self.client:connect( ip, port )
    self.client:send( Tserial.pack( { name=OptionSystem.options.playername, avatar=OptionSystem.options.playeravatar } ) )
end

function ClientSystem:startGame( snapshot )
    MapSystem:load( snapshot.map )
    self.client.callbacks = { recv = self.onGameReceive, disconnect = self.onDisconnect }
    self.time = snapshot.time
    --self.time = snapshot.time - 1
    self.tick = snapshot.tick
    self.snapshots[ snapshot.tick ] = snapshot
    self.lastshot = self.snapshots[ snapshot.tick ]
    self.prevshot = self.snapshots[ snapshot.tick ]
    self.nextshot = nil
    self.running = true
    -- Add/remove required entities
    DemoSystem:applyDiff( self.prevshot )
    -- Find our player
    for i,v in pairs( DemoSystem.entities ) do
        if v.playerid == self.id then
            self.player = v
            self.player:setLocalPlayer( true )
            self.playerpos = v:getPos()
        end
    end
end

function ClientSystem:addSnapshot( snapshot )
    if not snapshot.tick then
        return
    end
    self.snapshots[ snapshot.tick ] = snapshot
    if self.newesttick < snapshot.tick then
        self.newesttick = snapshot.tick
    end
end

function ClientSystem:stop()
    self.time = 0
    self.lastrecievetime = 0
    self.players = nil
    self.tick = 0
    self.lastshot = nil
    self.prevshot = nil
    self.nextshot = nil
    self.newesttick = 0
    self.id = nil
    self.player = nil
    self.playerpos = Vector( 0, 0 )
    if self.client then
        self.client:disconnect()
    end
    self.client = nil
    self.running = false
end

function ClientSystem:update( dt )
    if self.client then
        self.client:update( dt )
    end
    if self.lastrecievetime and self.time - self.lastrecievetime > 2 then
        if not self.warntext then
            self.warntext = loveframes.Create( "text" )
            self.warntext:SetDefaultColor( 255, 0, 0, 255 )
            self.warntext:SetPos( 0, 0 )
        end
        self.warntext:SetText( "Connection Error: " .. math.floor( self.time - self.lastrecievetime ) .. " / " .. self.timeout )
    elseif self.warntext then
        self.warntext:Remove()
    end
    if self.lastrecievetime and self.time - self.lastrecievetime > self.timeout then
        self:stop()
        StateMachine.switch( State.menu )
    end
    self.time = self.time + dt
    if not self.running then
        return
    end
    -- Use a light spring to fix prediction errors
    if self.player ~= nil and self.playerpos ~= nil then
        local diff = self.playerpos - self.player:getPos()
        diff:normalize_inplace()
        local dist = self.player:getPos():dist( self.playerpos )
        self.player:setPos( self.player:getPos() + diff * dist * dt * self.predictionfixspeed )
    end
    if self.player then
        self.player:addControlSnapshot( BindSystem.getControls(), self.tick )
    end
    World:update( dt, self.tick )

    -- We shouldn't do anything as long as we're too far in the
    -- past
    if self.time < self.prevshot.time + self.delay then
        return
    end
    -- If our next snapshot doesn't exist, try to find it
    if self.nextshot == nil then
        for i = self.tick + 1, self.tick + 10, 1 do
            self.nextshot = self.snapshots[ i ]
            if self.nextshot ~= nil then
                break
            end
        end
        -- If we couldn't find a snapshot, we need to extrapolate
        if self.nextshot == nil then
            local x = ( ( self.time - self.prevshot.time + self.delay ) * 1000 / 30 ) + 1
            -- Interpolate with a x > 1 makes it extrapolate
            self.interpolate( self.lastshot, self.prevshot, x )
            return
        end
    end
    -- If we're in between the two we interpolate the world
    if self.time > self.prevshot.time + self.delay and self.time < self.nextshot.time + self.delay then
        -- Uses linear progression
        local x = ( self.time - ( self.prevshot.time + self.delay ) ) / ( ( self.nextshot.time + self.delay ) - ( self.prevshot.time + self.delay ) )
        self.interpolate( self.prevshot, self.nextshot, x )
        return
    end
    -- If we're past the next frame, we up our tick and re-run ourselves.
    if self.time > self.nextshot.time + self.delay then
        -- First we really need to make sure our interpolation finished completely
        for i,v in pairs( self.nextshot.entities ) do
            local ent = DemoSystem.entities[ i ]
            if ent and ent.playerid == ClientSystem.id and v.pos ~= nil then
                ClientSystem.playerpos = Vector( v.pos.x, v.pos.y )
            elseif ent then
                for o,w in pairs( Entities.entities[ ent.__name ].networkinfo ) do
                    local val = v[ w ]
                    -- Call the coorisponding function to set the value
                    if not ent[ o ] then
                        error( "Entity " .. ent.__name .. " is missing function " .. o .. "!" )
                    end
                    if val then
                        ent[ o ]( ent, val )
                    end
                end
            end
        end
        -- Here we send our current controls to the server
        local t = {}
        --t.tick = self.newesttick - 1
        t.tick = self.tick
        if self.player then
            t.control = BindSystem.getDiff( self.player:getControls( self.tick - 1 ), BindSystem.getControls() )
        else
            t.control = BindSystem.getControls()
        end
        self.client:send( Tserial.pack( t ) )
        self.tick = self.nextshot.tick
        self.lastshot = self.prevshot
        self.prevshot = self.nextshot
        self.nextshot = nil
        -- This is where we delete/add everything it asks
        DemoSystem:applyDiff( self.prevshot )
        -- Find our player
        for i,v in pairs( DemoSystem.entities ) do
            if v.playerid == self.id then
                self.player = v
                self.player:setLocalPlayer( true )
                self.playerpos = v:getPos()
            end
        end
        -- This is where we interpolate forward a bit
        self:update( 0 )
        return
    end
end

function ClientSystem.interpolate( prevshot, nextshot, x )
    for i,v in pairs( DemoSystem.entities ) do
        local pent = prevshot.entities[ v.demoIndex ]
        local fent = nextshot.entities[ v.demoIndex ]
        -- We do NOT extrapolate/interpolate our player
        -- Since it's so important to have it be responsive
        -- as well as smooth, we use a light spring instead to fix
        -- prediction errors
        if v.playerid == ClientSystem.id and fent ~= nil and fent.pos ~= nil then
            ClientSystem.playerpos = Vector( fent.pos.x, fent.pos.y )
            return
        end
        -- Since everything is delta-compressed, only a nil future entity
        -- would indicate that the entity didn't change.
        -- So we're going to have to fill in the past entity snapshot
        -- with some information if it doesn't exist.
        if pent == nil and fent ~= nil then
            local copy = {}
            for o,w in pairs( Entities.entities[ v.__name ].networkinfo ) do
                copy[w] = v[w]
            end
            prevshot.entities[ v.demoIndex ] = copy
            pent = copy
        end
        -- Make sure the entity is changing somehow
        if pent ~= nil and fent ~= nil then
            for o,w in pairs( Entities.entities[ v.__name ].networkinfo ) do
                local pastval = pent[w]
                local futureval = fent[w]
                -- ANGLE, needs special care
                if w == "rot" then
                    if pastval and futureval then
                        if math.abs( pastval - futureval ) > math.pi then
                            if pastval < futureval then
                                pastval = pastval + math.pi * 2
                            else
                                futureval = futureval + math.pi * 2
                            end
                        end
                    end
                end

                -- Call the coorisponding function to set the
                -- interpolated value (which can be a table)
                if pastval ~= nil then
                    v[ o ]( v, DemoSystem:interpolate( pastval, futureval, x ) )
                end
            end
        elseif fent ~= nil then
            error( "Something is dramatically wrong I think, I don't remember why I have this error here." )
        end
    end
end

function ClientSystem.onLobbyReceive( data )
    local t = Tserial.unpack( data )
    if t.clientid then
        ClientSystem:setID( t.clientid )
    end
    if t.map then
        StateMachine.switch( State.client )
        -- We have to load everything after, else we may remove GUI elements
        ClientSystem:startGame( t )
    end
    if t.players then
        ClientSystem:updatePlayers( t.players )
        State.clientlobby:clearPlayers()
        for i,v in pairs( t.players ) do
            State.clientlobby:listPlayer( v )
        end
    end
    ClientSystem.lastrecievetime = ClientSystem.time
end

function ClientSystem.onDisconnect( data )
    ClientSystem:stop()
    StateMachine.switch( State.menu )
end

function ClientSystem.onGameReceive( data )
    local t = Tserial.unpack( data )
    if t.clientid then
        ClientSystem:setID( t.clientid )
    end
    if t.map then
        MapSystem:load( t.map )
    end
    if t.players then
        ClientSystem:updatePlayers( t.players )
    end
    ClientSystem:addSnapshot( t )
    ClientSystem.lastrecievetime = ClientSystem.time
end


return ClientSystem
