-- Majority of the work is already done with my demoing system :)

local ClientSystem = {
    running = false,
    time = 0,
    players = nil,
    tick = 0,
    lastshot = nil,
    prevshot = nil,
    nextshot = nil,
    newesttick = 0,
    id = nil,
    player = nil,
    predictionfixspeed = 8,
    delay = 100/1000,
    client = nil,
    snapshots = {}
}

function ClientSystem:setID( id )
    self.id = id
end

function ClientSystem:setPlayers( players )
    self.players = players
end

function ClientSystem:startLobby( ip, port )
    self.client = lube.udpClient()
    self.client:init()
    self.client.callbacks = { recv = self.onLobbyReceive }
    self.client.handshake = Game.version
    self.client:connect( ip, port )
    self.client:send( Tserial.pack( { name=Options.playername, avatar=Options.playeravatar } ) )
end

function ClientSystem:startGame( snapshot )
    MapSystem:load( snapshot.map )
    self.client.callbacks = { recv = self.onGameReceive }
    -- Just like source multiplayer, we render 100 miliseconds in the past
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
        if v.playerid == self.id and v.setActive then
            self.player = v
            v:setActive( true )
        elseif v.playerid and v.setActive then
            v:setActive( false )
        end
    end
end

function ClientSystem:addSnapshot( snapshot )
    self.snapshots[ snapshot.tick ] = snapshot
    self.newesttick = snapshot.tick
end

function ClientSystem:stop()
    self.running = false
end

function ClientSystem:update( dt )
    if self.client then
        self.client:update( dt )
    end
    if not self.running then
        return
    end
    -- We don't simulate physics due to the server doing it all for us
    --Physics:update( dt )
    World:update( dt, self.tick )
    self.time = self.time + dt

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
        -- Here we send our current controls to the server
        local t = {}
        t.tick = self.newesttick
        t.control = BindSystem.getControls()
        self.client:send( Tserial.pack( t ) )
        self.tick = self.nextshot.tick
        self.lastshot = self.prevshot
        self.prevshot = self.nextshot
        self.nextshot = nil
        -- This is where we delete everything it asks
        DemoSystem:applyDiff( self.prevshot )
        -- Find our player
        for i,v in pairs( DemoSystem.entities ) do
            if v.playerid == self.id and v.setActive then
                self.player = v
                v:setActive( true )
            elseif v.playerid and v.setActive then
                v:setActive( false )
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
        ClientSystem:setPlayers( t.players )
        State.clientlobby:clearPlayers()
        for i,v in pairs( t.players ) do
            State.clientlobby:listPlayer( v )
        end
    end
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
        ClientSystem:setPlayers( t.players )
    end
    ClientSystem:addSnapshot( t )
end


return ClientSystem
