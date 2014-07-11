-- Majority of the work is already done with my demoing system :)

local Client = {
    running = false,
    time = 0,
    players = nil,
    tick = 0,
    lastshot = nil,
    prevshot = nil,
    nextshot = nil,
    id = nil,
    player = nil,
    playerpos = game.vector(0,0),
    playerrot = 0,
    predictionfixspeed = 8,
    delay = 50/1000,
    client = nil,
    snapshots = {}
}

function Client:setID( id )
    self.id = id
end

function Client:setPlayers( players )
    self.players = players
end

function Client:startLobby( ip, port )
    self.client = lube.udpClient()
    self.client:init()
    self.client.callbacks = { recv = self.onLobbyReceive }
    self.client.handshake = game.version
    self.client:connect( ip, port )
    self.client:send( Tserial.pack( { name=game.options.playername } ) )
end

function Client:startGame( snapshot )
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
    game.demosystem:applyDiff( self.prevshot )
    -- Find our player
    for i,v in pairs( game.demosystem.entities ) do
        if v.playerid == self.id and v.setActive then
            self.player = v
            v:setActive( true )
        elseif v.playerid and v.setActive then
            v:setActive( false )
        end
    end
end

function Client:addSnapshot( snapshot )
    self.snapshots[ snapshot.tick ] = snapshot
end

function Client:stop()
    self.running = false
end

function Client:update( dt )
    if self.client then
        self.client:update( dt )
    end
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
    if self.player ~= nil and self.playerrot ~= nil then
        local diff = self.playerrot - self.player:getRot()
        self.player:setRot( self.player:getRot() + diff * dt * self.predictionfixspeed )
    end
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
            local x = ( ( self.time - self.prevshot.time + self.delay ) * 1000 / 15 ) + 1
            -- Interpolate with a x > 1 makes it extrapolate
            self.interpolate( self.lastshot, self.prevshot, x )
            return
        end
    end
    -- If we're in between the two we interpolate the world
    if self.time > self.prevshot.time + self.delay and self.time < self.nextshot.time + self.delay then
        -- Uses linear progression
        local x = ( self.time - self.prevshot.time + self.delay ) / ( self.time - self.nextshot.time + self.delay )
        self.interpolate( self.prevshot, self.nextshot, x )
        return
    end
    -- If we're past the next frame, we up our tick and re-run ourselves.
    if self.time > self.nextshot.time + self.delay then
        -- Here we send our current controls to the server
        local t = {}
        t.tick = self.tick
        t.control = control.current
        self.client:send( Tserial.pack( t ) )
        self.tick = self.nextshot.tick
        self.lastshot = self.prevshot
        self.prevshot = self.nextshot
        self.nextshot = nil
        -- This is where we delete everything it asks
        game.demosystem:applyDiff( self.prevshot )
        -- Find our player
        for i,v in pairs( game.demosystem.entities ) do
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

function Client.interpolate( prevshot, nextshot, x )
    for i,v in pairs( game.demosystem.entities ) do
        local pent = prevshot.entities[ v.demoIndex ]
        local fent = nextshot.entities[ v.demoIndex ]
        -- We do NOT extrapolate/interpolate our player
        -- Since it's so important to have it be responsive
        -- as well as smooth, we use a light spring instead to fix
        -- prediction errors
        if x > 1 and v.playerid == game.client.id and fent ~= nil and fent.pos ~= nil then
            game.client.playerpos = game.vector( fent.pos.x, fent.pos.y )
            if fent.rot then
                game.client.playerrot = fent.rot
            end
            return
        end
        -- Since everything is delta-compressed, only a nil future entity
        -- would indicate that the entity didn't change.
        -- So we're going to have to fill in the past entity snapshot
        -- with some information if it doesn't exist.
        if pent == nil and fent ~= nil then
            local copy = {}
            for o,w in pairs( game.gamemode.entities[ v.__name ].networkedvars ) do
                copy[w] = v[w]
            end
            prevshot.entities[ v.demoIndex ] = copy
            pent = copy
        end
        -- Make sure the entity is changing somehow
        if pent ~= nil and fent ~= nil then
            for o,w in pairs( game.gamemode.entities[ v.__name ].networkedvars ) do
                local pastval = pent[w]
                local futureval = fent[w]
                -- Call the coorisponding function to set the
                -- interpolated value (which can be a table)
                if pastval ~= nil then
                    v[ game.gamemode.entities[ v.__name ].networkedfunctions[ o ] ]( v, game.demosystem:interpolate( pastval, futureval, x ) )
                end
            end
        elseif fent ~= nil then
            error( "AA" )
        end
    end
end

function Client.onLobbyReceive( data )
    print( data )
    local t = Tserial.unpack( data )
    if t.map then
        game.mapsystem:load( t.map )
        game.client:startGame( t )
        game.gamestate.switch( gamestates.client )
    end
    if t.clientid then
        game.client:setID( t.clientid )
    end
    if t.players then
        game.client:setPlayers( t.players )
        gamestates.clientlobby:clearPlayers()
        for i,v in pairs( t.players ) do
            gamestates.clientlobby:listPlayer( v )
        end
    end
end

function Client.onGameReceive( data )
    local t = Tserial.unpack( data )
    if t.map then
        game.mapsystem:load( t.map )
    end
    if t.clientid then
        game.client:setID( t.clientid )
    end
    if t.players then
        game.client:setPlayers( t.players )
    end
    game.client:addSnapshot( t )
end


return Client
