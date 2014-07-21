-- Majority of the work is already done with my demoing system :)

local Network = {
    server = nil,
    port = 27020,
    running = false,
    updaterate = 30,
    currenttime = 0,
    totaltime = 0,
    tick = 0,
    -- We never want to remove the first snapshot due to it being used
    -- constantly
    backtick = 1,
    lastsent = nil,
    maxsize = 10,
    snapshots = {},
    events = {},
    chat = {},
    playerschanged = false,
    playercount = 0,
    players = {}
}

function Network:addEvent( event )
    if not self.events[ event.tick ] then
        self.events[ event.tick ] = event
    else
        table.merge( self.events[ event.tick ], event )
    end
end

function Network:getEvent( tick )
    return self.events[ tick ]
end

function Network:startLobby( port )
    self.port = self.port or port
    self.server = lube.udpServer()
    self.server:init()
    self.server:setPing( true, 10, "p" )
    self.server.callbacks = { recv = self.onLobbyReceive, connect = self.onLobbyConnect, disconnect = self.onLobbyDisconnect }
    self.server.handshake = Game.version
    self.server:listen( self.port )
    print( "Created Listen Lobby on port " .. self.port )
end

function Network:startGame()
    if not self.server then
        error( "Network needs startLobby() called before startGame()!" )
    end
    self.server.callbacks = { recv = self.onGameReceive, connect = self.onGameConnect, disconnect = self.onGameDisconnect }
    self.running = true
    self.totaltime = 0
    self.currenttime = 0
    self.tick = 0
    self.backtick = 0
    -- Max ping is 500ms
    self.maxsize = 500/self.updaterate
    MapSystem:load( Gamemode.map )
    -- Tick 0 is always just the plain map
    self.snapshots[ self.tick ] = DemoSystem:generateSnapshot( self.tick, self.totaltime )
    for i,v in pairs( self.players ) do
        if v.id == 0 then
            v.ent = Gamemode:spawnPlayer( { playerid = v.id, localplayer = true } ).demoIndex
        else
            v.ent = Gamemode:spawnPlayer( { playerid = v.id } ).demoIndex
        end
    end
    -- Tick 1 is after all the players spawned
    self.tick = self.tick + 1
    self.snapshots[ self.tick ] = DemoSystem:generateSnapshot( self.tick, self.totaltime )
    self.lastsent = table.copy( self.snapshots[ self.tick ] )
    for i,v in pairs( self.players ) do
        if v.id ~= 0 then
            local t = DemoSystem:getDiff( self.snapshots[ 0 ], self.snapshots[ self.tick ] )
            t.map = Gamemode.map
            t.clientid = v.id
            self.server:send( Tserial.pack( t ), v.id )
        end
    end
end

function Network:addPlayer( id, entDemoIndex )
    local player = {}
    self.playerschanged = true
    if id == 0 then
        player.name = OptionSystem.options.playername
        player.avatar = OptionSystem.options.playeravatar
        player.ping = 0
    end
    player.id = id
    player.ent = entDemoIndex
    player.snapshots = {}
    player.tick = 0
    player.newtick = nil
    self.playercount = self.playercount + 1
    self.players[ id ] = player
    -- When a player connects, we immediately send over
    -- the mapname and then a diff snapshot from the beginning of the
    -- Game to now, this is usually cheaper than just sending
    -- over the whole gamestate
    -- but only when we're already mid-Game.
    if self.running then
        if id ~= 0 then
            local t = DemoSystem:getDiff( self.snapshots[ 0 ], self.snapshots[ self.tick ] )
            t.map = Gamemode.map
            t.clientid = id
            self.server:send( Tserial.pack( t ), id )
        end
    end
end

function Network:removePlayer( id )
    local playerent = DemoSystem.entities[ self.players[ id ].ent ]
    if playerent then
        -- We add a network event saying something got removed
        local event = {}
        event.removed = { self.players[ id ].demoIndex }
        event.tick = self.tick
        event.added = {}
        Network:addEvent( event )
        playerent:remove()
    end
    self.players[ id ] = nil
end

function Network:updateClient( id, controls, tick )
    self.players[ id ].snapshots[ tick ] = controls
    -- We record their OLDEST recieved update, so we know how far back to
    -- go in time for our fellow players with poor internet
    if not self.players[ id ].newtick or self.players[ id ].newtick > tick then
        self.players[ id ].newtick = tick
    end
end

function Network:stop()
    if self.server then
        self.server:disconnect()
    end
    self.server = nil
    self.running = false
    self.totaltime = 0
    self.currenttime = 0
    self.tick = 0
end

function Network:mergeControls()
    for i,v in pairs( self.players ) do
        local ent = DemoSystem.entities[ v.ent ]
        if ent then
            for o,w in pairs( v.snapshots ) do
                ent:addControlSnapshot( w, o )
            end
        end
        v.snapshots = {}
    end
end

-- We send out updates at the current updaterate
function Network:update( dt )
    if self.server then
        self.server:update( dt )
    end
    self.totaltime = self.totaltime + dt
    self.currenttime = self.currenttime + dt*1000
    if self.currenttime > self.updaterate then
        -- Update pings
        -- We find which player is furthest behind
        local mintick = nil
        for i,v in pairs( self.players ) do
            if mintick == nil or ( v.newtick ~= nil and mintick > v.newtick ) then
                mintick = v.newtick
            end
            -- Oh and update everyone's ping :)
            if v.id ~= 0 and v.newtick then
                v.ping = math.floor( ( self.tick - v.newtick ) * 15 )
            end
            v.newtick = nil
        end
        -- Then we go back in time and resimulate everything from where
        -- we last recieved an input from that player
        if mintick ~= self.tick and mintick ~= nil then
            self:unsimulate( mintick )
            -- Merging the controls simply updates the player controls
            -- with what we recieved.
            -- We have to do that here so that we can accurately go back
            -- in time is all.
            self:mergeControls()
            self:simulate( mintick )
        else
            --if love.mouse.isDown( "m" ) then
                --self:unsimulate( self.tick - 10 )
                --self:mergeControls()
                --self:simulate( self.tick - 10 )
            --else
                self:mergeControls()
            --end
        end

        while self.currenttime > self.updaterate do
            self.currenttime = self.currenttime - self.updaterate
            World:update( self.updaterate/1000, self.tick )
        end
        self.tick = self.tick + 1
        -- Generate a new snapshot
        self.snapshots[ self.tick ] = DemoSystem:generateSnapshot( self.tick, self.totaltime )

        -- Now that we have an updated Game world, we send over diff
        -- updates based on our previous save of the Game world.
        local t = DemoSystem:getDiff( self.lastsent, self.snapshots[ self.tick ] )
        -- If our connected players changed, send over all their information
        if self.playerschanged then
            t.players = {}
            for i,v in pairs( self.players ) do
                local p = {}
                for o,w in pairs( v ) do
                    -- Copy pretty much everything except these things.
                    if o ~= "snapshots" and o ~= "ent" and o ~= "tick" and o ~= "newtick" and o ~= "__index" then
                        p[o] = w
                    end
                end
                table.insert( t.players, p )
            end
            self.playerschanged = false
        end
        self.server:send( Tserial.pack( t ) )
        self.lastsent = self.snapshots[ self.tick ]
    end
    -- Remove ticks that are too far into the past
    for i = self.backtick, self.tick - self.maxsize, 1 do
        if i ~= 0 then
            self.snapshots[ i ] = nil
        end
        self.backtick = self.backtick + 1
    end
end

function Network:unsimulate( snapshot )
    if snapshot < self.backtick + 1 then
        snapshot = self.backtick + 1
    end
    -- Go back backward in time
    --for i = self.tick, snapshot + 1, -1 do
        -- Gets the difference between the two snapshots
        -- if a is nil it returns a full snapshot to be used
        -- to recreate the world.
        --local diffshot = DemoSystem:getCheapDiff( self.snapshots[ i ], self.snapshots[ i - 1 ] )
        --DemoSystem:applyDiff( diffshot )
        --local time = self.snapshots[ i - 1 ].time - self.snapshots[i].time
        --World:update( -time, i-1 )
        --while time < 0 do
            --World:update( -self.updaterate/1000, i-1 )
            --time = time + self.updaterate/1000
        --end
    --end
    -- Now that we're back in time enough, we make sure the world is
    -- in the right position by just setting everything to the snapshot
    if self.snapshots[ snapshot ] then
        local time = self.snapshots[ self.tick ].time - self.snapshots[ snapshot ].time
        World:update( -time )
        local diffshot = DemoSystem:getCheapDiff( self.snapshots[ self.tick ], self.snapshots[ snapshot ] )
        DemoSystem:applyDiff( diffshot )
        for i,v in pairs( self.snapshots[ snapshot ].entities ) do
            local ent = DemoSystem.entities[ i ]
            if ent then
                for o,w in pairs( Entities.entities[ ent.__name ].networkinfo ) do
                    local val = v[ w ]
                    -- Call the coorisponding function to set the
                    -- value
                    if not ent[ o ] then
                        error( "Entity " .. ent.__name .. " is missing function " .. o .. "!" )
                    end
                    ent[ o ]( ent, val )
                end
            end
        end
    end
end

function Network:simulate( snapshot )
    if snapshot < self.backtick + 1 then
        snapshot = self.backtick + 1
    end
    for i = snapshot, self.tick - 1, 1 do
        -- Gets the difference between the two snapshots
        -- if a is nil it returns a full snapshot to be used
        -- to recreate the world.
        --local diffshot = DemoSystem:getCheapDiff( self.snapshots[ i ], self.snapshots[ i + 1 ] )
        local diffshot = self:getEvent( i )
        if diffshot then
            DemoSystem:applyDiff( diffshot )
        end
        --DemoSystem:applyDiff( diffshot )
        local time = self.snapshots[ i + 1 ].time - self.snapshots[ i ].time
        --print( time )
        --World:update( time, i )
        World:update( time, i )
        -- After we've updated, re-write the new snapshot over the old one
        self.snapshots[ i + 1 ] = DemoSystem:generateSnapshot( i, self.snapshots[ i + 1 ].time )
    end
end

function Network:resimulate( snapshot )
    if snapshot < self.backtick + 1 then
        return
    end
    self:unsimulate( snapshot )
    self:simulate( snapshot )
end

function Network.onLobbyConnect( id )
    print( "Got a connection from " .. id )
    Network:addPlayer( id )
end

function Network.onLobbyReceive( data, id )
    local t = Tserial.unpack( data )
    --Network:updateClientSystem( id, t.control, t.tick )
    if not Network.players[ id ] then
        Network:addPlayer( id )
    end
    if t.name then
        Network.players[ id ].name = t.name
    end
    if t.avatar then
        Network.players[ id ].avatar = t.avatar
    end
    if t.control and t.tick then
        Network:updateClientSystem( id, t.control, t.tick )
    end
end

function Network.onLobbyDisconnect( id )
    print( id .. " disconnected..." )
    Network:removePlayer( id )
end

function Network.onGameConnect( id )
    print( "Got a connection from " .. id )
    local player = Gamemode:spawnPlayer( { playerid = id } )
    Network:addPlayer( id, player.demoIndex )
    -- We add a network event saying something got added
    local event = {}
    event.added = {}
    event.added[ player.demoIndex ] = DemoSystem.netcopy( player )
    event.tick = Network:getTick()
    event.removed = {}
    Network:addEvent( event )
end

function Network.onGameReceive( data, id )
    local t = Tserial.unpack( data )
    if t.control and t.tick then
        Network:updateClient( id, t.control, t.tick )
    end
end

function Network.onGameDisconnect( id )
    print( id .. " disconnected..." )
    Network:removePlayer( id )
end

function Network:getTick()
    return self.tick
end

return Network
