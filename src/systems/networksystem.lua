-- Majority of the work is already done with my demoing system :)

local Network = {
    port = 27020,
    running = false,
    updaterate = 30/1000,
    networkrate = 120/1000,
    playerupdate = 0,
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

function Network:addChatText( id, text )
    if not self.players[ id ] then
        return
    end
    table.insert( self.chat, self.players[ id ].name .. ": " .. text )
    if Network.onTextReceive then
        Network.onTextReceive( { self.players[ id ].name .. ": " .. text } )
    end
end

function Network:startLobby( port )
    self.port = self.port or port
    Enet.Server:init( port )
    Enet.Server:setCallbacks( self.onLobbyReceive, self.onLobbyDisconnect, self.onLobbyConnect )
end

function Network:startGame()
    Enet.Server:setCallbacks( self.onGameReceive, self.onGameDisconnect, self.onGameConnect )
    self.running = true
    self.totaltime = 0
    self.playerupdate = 0
    self.currenttime = 0
    self.tick = 0
    self.backtick = 0
    -- Max ping is 500ms
    self.maxsize = 500/self.updaterate
    MapSystem:load( Gamemode.map )
    -- Tick 0 is always just the plain map
    self.snapshots[ self.tick ] = DemoSystem:generatePlayerSnapshot( self.tick, self.totaltime )
    for i,v in pairs( self.players ) do
        if v.id == 0 then
            v.ent = Gamemode:spawnPlayer( { playerid = v.id, localplayer = true } ).demoIndex
        else
            v.ent = Gamemode:spawnPlayer( { playerid = v.id } ).demoIndex
        end
    end
    -- Tick 1 is after all the players spawned
    self.tick = self.tick + 1
    self.snapshots[ self.tick ] = DemoSystem:generatePlayerSnapshot( self.tick, self.totaltime )
    self.lastsent = table.copy( self.snapshots[ self.tick ] )
    for i,v in pairs( self.players ) do
        if v.id ~= 0 then
            local t = DemoSystem:getDiff( self.snapshots[ 0 ], self.snapshots[ self.tick ] )
            t.map = Gamemode.map
            t.clientid = v.id
            Enet.Server:send( Tserial.pack( t ), v.id, 0, "reliable" )
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
            Enet.Server:send( Tserial.pack( t ), id, 0, "reliable" )
        end
    end
end

function Network:removePlayer( id )
    local playerent = DemoSystem.entities[ self.players[ id ].ent ]
    if playerent then
        playerent:remove()
    end
    self.players[ id ] = nil
end

function Network:updateClient( id, controls, tick )
    DemoSystem.entities[ self.players[ id ].ent ]:addControlSnapshot( controls, World:getCurrentTime() )
    -- This is used to tell the client the last tick we've registered.
    if ( not self.players[ id ].tick or tick > self.players[ id ].tick ) and tick then
        self.players[ id ].tick = tick
    end
end

function Network:stop()
    Enet.Server:disconnect()
    self.players = {}
    self.running = false
    self.totaltime = 0
    self.currenttime = 0
    self.tick = 0
end

-- We send out updates at the current updaterate
function Network:update( dt )
    Enet.Server:update()
    self.currenttime = self.currenttime + dt
    if self.currenttime >= self.updaterate then
        -- Update pings
        for i,v in pairs( self.players ) do
            -- Oh and update everyone's ping :)
            if v.id ~= 0 then
                v.ping = Enet.Server.peers[ v.id ]:round_trip_time()
            end
        end

        while self.currenttime >= self.updaterate do
            self.currenttime = self.currenttime - self.updaterate
            Physics:update( self.updaterate )
            World:update( self.updaterate )
            self.totaltime = self.totaltime + self.updaterate
        end
        self.tick = self.tick + 1
        -- Generate a new snapshot
        self.snapshots[ self.tick ] = DemoSystem:generatePlayerSnapshot( self.tick, self.totaltime )

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
            self.playerupdate = self.totaltime
        elseif self.totaltime - self.playerupdate > 2 then
            t.players = {}
            for i,v in pairs( self.players ) do
                local p = {}
                -- We're more strict on what to send on periodic updates
                p.ping = v.ping
                p.name = v.name
                p.id = v.id
                table.insert( t.players, p )
            end
            self.playerschanged = false
            self.playerupdate = self.totaltime
        end
        if #self.chat > 0 then
            t.chat = self.chat
        end
        local flag = "unreliable"
        if t.chat or t.players then
            flag = "reliable"
        end
        for i,v in pairs( self.players ) do
            if v.id ~= 0 then
                t.lastregistered = v.tick
                Enet.Server:send( Tserial.pack( t ), v.id, 0, flag )
            end
        end
        if #self.chat > 0 then
            self.chat = {}
        end
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
        Network.playerschanged = true
    end
    if t.avatar then
        Network.players[ id ].avatar = t.avatar
        Network.playerschanged = true
    end
    if t.control then
        Network:updateClientSystem( id, t.control, t.tick )
    end
    if t.chat then
        Network:addChatText( id, t.chat )
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
end

function Network.onGameReceive( data, id )
    local t = Tserial.unpack( data )
    if not Network.players[ id ] then
        return
    end
    if t.control and t.tick then
        Network:updateClient( id, t.control, t.tick )
    end
    if t.name then
        Network.players[ id ].name = t.name
    end
    if t.avatar then
        Network.players[ id ].avatar = t.avatar
    end
    if t.chat then
        Network:addChatText( id, t.chat )
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
