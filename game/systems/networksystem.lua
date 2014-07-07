-- Majority of the work is already done with my demoing system :)

local Network = {
    server = nil,
    running = false,
    updaterate = 15,
    currenttime = 0,
    totaltime = 0,
    tick = 0,
    -- We never want to remove the first snapshot due to it being used
    -- constantly
    backtick = 1,
    lastsent = nil,
    maxsize = 100,
    snapshots = {},
    players = {}
}

function Network:addPlayer( id, ent )
    local player = {}
    player.id = id
    player.ent = ent
    player.snapshots = {}
    player.tick = 0
    self.players[ id ] = player
    if self.server ~= nil then
        -- When a player connects, we immediately send over
        -- the mapname and then a diff snapshot from the beginning of the
        -- game to now, this is usually cheaper than just sending
        -- over the whole gamestate
        if id ~= 0 then
            local t = game.demosystem:getDiff( self.snapshots[ 0 ], self.snapshots[ self.tick ] )
            t.map = game.gamemode.map
            t.clientid = id
            self.server:send( Tserial.pack( t ), id )
        end
    end
end

function Network:removePlayer( id )
    self.players[ id ] = nil
end

function Network:updateClient( id, controls, tick )
    self.players[ id ].snapshots[ tick ] = controls
    self.players[ id ].tick = tick
end

function Network:start( server )
    self.running = true
    self.server = server
    self.totaltime = 0
    self.currenttime = 0
    self.tick = 0
    self.backtick = 0
    -- Hold exactly 2 seconds worth of gamestates in memory
    self.maxsize = 2000/self.updaterate
    self.snapshots[ self.tick ] = game.demosystem:generateSnapshot( self.tick, self.totaltime )
    self.lastsent = table.copy( self.snapshots[ self.tick ] )
end

function Network:stop()
    self.server = nil
    self.running = false
    self.totaltime = 0
    self.currenttime = 0
    self.tick = 0
end

-- We send out updates at the current updaterate
function Network:update( dt )
    self.currenttime = self.currenttime + dt*1000
    if self.currenttime > self.updaterate then
        -- We find which player is furthest behind
        local minplayer = nil
        for i,v in pairs( self.players ) do
            if minplayer == nil or v.tick < minplayer.tick then
                minplayer = v
            end
        end
        -- Then we go back in time and resimulate everything from where
        -- we last recieved an input from that player
        if minplayer.tick ~= self.tick and minplayer.tick ~= nil then
            self:resimulate( minplayer.tick )
        end

        -- May have to skip a few snapshots to catch up
        while self.currenttime > self.updaterate do
            self.currenttime = self.currenttime - self.updaterate
            self.totaltime = self.totaltime + self.updaterate/1000
            game.entities:update( self.updaterate/1000, self.tick )
        end
        self.tick = self.tick + 1
        -- Generate a new snapshot
        self.snapshots[ self.tick ] = game.demosystem:generateSnapshot( self.tick, self.totaltime )

        -- Now that we have an updated game world, we send over diff
        -- updates based on our previous save of the game world.
        self.server:send( Tserial.pack( game.demosystem:getDiff( self.lastsent, self.snapshots[ self.tick ] ) ) )
        self.lastsent = table.copy( self.snapshots[ self.tick ] )
    end
    -- Remove ticks that are too far into the past
    for i = self.backtick, self.tick - self.maxsize, 1 do
        if i ~= 0 then
            self.snapshots[ i ] = nil
        end
        self.backtick = self.backtick + 1
    end
end

function Network:resimulate( snapshot )
    -- We won't resimulate anything that's out of our memory range
    if snapshot <= self.backtick then
        return
    end
    -- Unfortunately we have to completely rebuild the world in order to
    -- resimulate the past
    game.entities:removeAll()
    for i,v in pairs( self.snapshots[ snapshot ].entities ) do
        game.entity:new( v.__name, v )
    end
    local curtick = snapshot
    local saveshot = table.copy( self.snapshots[ curtick ] )
    -- Go back forward in time, with the new player inputs.
    while curtick < self.tick do
        -- Gets the difference between the two snapshots
        -- if a is nil it returns a full snapshot to be used
        -- to recreate the world.
        local diffshot = game.demosystem:getDiff( saveshot, self.snapshots[ curtick + 1 ] )
        -- This is where we delete everything it asks in the timeline
        for i,v in pairs( diffshot.removed ) do
            --print( "Removed ent", v )
            -- Given the unique ID's, we should never
            -- have problems from directly removing
            -- entities like this.
            if game.demosystem.entities[ v ] ~= nil then
                game.demosystem.entities[ v ]:remove()
            end
        end
        -- This is where we add everything it asks in the timeline
        for i,v in pairs( diffshot.added ) do
            local ent = game.entity( v.__name, v )
        end
        game.entities:update( self.updaterate/1000, curtick )
        -- After we've updated, re-write the new snapshot over the old one
        -- but keep the old one to remember if we created/removed anything
        -- for the next frame
        saveshot = table.copy( self.snapshots[ curtick ] )
        curtick = curtick + 1
        self.snapshots[ curtick ] = game.demosystem:generateSnapshot( curtick, self.snapshots[ curtick ].time )
    end
end

function Network:getControls( id, tick )
    if not self.running then
        return control.current
    end
    if tick == nil then
        tick = self.tick
    end
    if self.players[ id ] == nil then
        return nil
    end
    if id == 0 and tick == self:getTick() then
        return control.current
    end
    local controls = self.players[ id ].snapshots[ tick ]
    if controls == nil then
        -- If that specified instance of controls doesn't exist
        -- get previous instance instead
        -- it can be nil, which should be accounted for
        local last = nil
        for i,v in pairs( self.players[ id ].snapshots ) do
            if last == nil or ( i < tick and i > last ) then
                last = i
            end
        end
        return self.players[ id ].snapshots[ last ]
    end
    return controls
end

function Network:getTick()
    return self.tick
end

return Network
