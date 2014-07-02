-- Majority of the work is already done with my demoing system :)

local Network = {
    server = nil,
    running = false,
    updaterate = 15,
    currenttime = 0,
    totaltime = 0,
    tick = 0,
    backtick = 0,
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
        -- the full current gamestate

        -- But only if they aren't ourselves.
        if id ~= 0 then
            local str = Tserial.pack( game.demosystem:getFull( self.snapshots[ self.tick ] ) )
            self.server:send( Tserial.pack( game.demosystem:getFull( self.snapshots[ self.tick ] ) ), id )
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
        if minplayer.tick ~= self.tick then
            self:resimulate( minplayer.tick )
        end

        -- Now that we have an updated game world, we send over diff updates
        -- specific for each player's current gamestate
        for i,v in pairs( self.players ) do
            -- Don't "send" anything to ourselves.
            if v.id ~= 0 then
                local snapa = self.snapshots[ v.tick ]
                local snapb = self.snapshots[ self.tick ]
                self.server:send( Tserial.pack( game.demosystem:getDiff( snapa, snapb ) ), v.id )
            end
        end
    end
end

function Network:resimulate( snapshot )
    -- Unfortunately we have to completely rebuild the world in order to
    -- resimulate the past
    game.entities:removeAll()
    for i,v in pairs( self.snapshots[ snapshot ].entities ) do
        game.entity:new( v.__name, v )
    end
    local tick = snapshot
    local time = self.snapshots[ snapshot ].time
    -- Get the timestep in seconds
    local timestep = self.updaterate / 1000
    -- Go back forward in time, with the new player inputs.
    while time < self.totaltime - self.updaterate do
        game.entities:update( self.updaterate, tick )
        -- After we've updated, re-write the new snapshot over the old one
        self.snapshots[ tick ] = game.demosystem:generateSnapshot( tick, time )
        tick = tick + 1
        time = time + self.updaterate
    end
    -- Make sure we end up at the right time
    game.entities:update( self.totaltime - time )
    self.snapshots[ tick ] = game.demosystem:generateSnapshot( tick, self.totaltime )
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
            if last == nil or i < tick and i - tick < last then
                last = i
            end
            if last ~= nil and i > tick then
                break
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
