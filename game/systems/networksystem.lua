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
    maxsize = 1000,
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
    -- Hold exactly 1.5 seconds worth of gamestates in memory
    self.maxsize = 1500/self.updaterate
    self.snapshots[ self.tick ] = game.demosystem:generateSnapshot( self.tick, self.totaltime )
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
    self.totaltime = self.totaltime + dt
    self.currenttime = self.currenttime + dt*1000
    if self.currenttime > self.updaterate then
        self.tick = self.tick + 1
        -- Generate a new snapshot
        self.snapshots[ self.tick ] = game.demosystem:generateSnapshot( self.tick, self.totaltime )
        self.currrenttime = self.currenttime % self.updaterate
        -- We find which player is furthest behind
        local minplayer = nil
        for i,v in pairs( self.players ) do
            if minplayer == nil or v.tick < minplayer.tick then
                minplayer = v
            end
        end
        -- Then we go back in time and resimulate everything from where
        -- we last recieved an input from that player
        -- but only if the last input recieved is not on time (Which
        -- should pretty much be never given internet generally has a delay of
        -- more than 15 milliseconds)
        -- before we resimulate though, we save the last snapshot
        local save = self.snapshots[ self.tick - 1 ]
        if minplayer.tick ~= self.tick - 1 and minplayer.tick ~= nil then
            self:resimulate( minplayer.tick )
        end

        -- Now that we have an updated game world, we send over diff
        -- updates based on our previous save of the game world.
        for i,v in pairs( self.players ) do
            -- Don't "send" anything to ourselves.
            if v.id ~= 0 then
                local snapa = save
                local snapb = self.snapshots[ self.tick ]
                self.server:send( Tserial.pack( game.demosystem:getDiff( snapa, snapb ) ), v.id )
            end
        end
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
    local tick = snapshot
    -- Go back forward in time, with the new player inputs.
    while tick < self.tick do
        -- Gets the difference between the two snapshots
        -- if a is nil it returns a full snapshot to be used
        -- to recreate the world.
        local diffshot = game.demosystem:getDiff( self.snapshots[ tick ], self.snapshots[ tick + 1 ] )
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
            for o,w in pairs( game.gamemode.entities[ ent.__name ].networkedvars ) do
                local val = v[w]
                -- Call the coorisponding function to set the
                -- value
                if val ~= nil then
                    ent[ game.gamemode.entities[ ent.__name ].networkedfunctions[ o ] ]( ent, val )
                end
            end
        end
        game.entities:update( self.snapshots[ tick + 1 ].time - self.snapshots[ tick ].time, tick )
        tick = tick + 1
        -- After we've updated, re-write the new snapshot over the old one
        self.snapshots[ tick ] = game.demosystem:generateSnapshot( tick, self.snapshots[ tick ].time )
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
