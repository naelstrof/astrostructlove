-- Majority of the work is already done with my demoing system :)

local Network = {
    server = nil,
    running = false,
    updaterate = 15,
    currenttime = 0,
    totaltime = 0,
    tick = 0,
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
        self.server.send( id, Tserial.pack( game.demosystem:getFull( snapshots[ tick ] ) ) )
    end
end

function Network:removePlayer( id )
    self.players[ id ] = nil
end

function Network:updateClient( id, controls, tick )
    players[ id ].snapshots[ tick ] = controls
    players[ id ].tick = tick
end

function Network:start( server )
    self.running = true
    self.server = server
    self.totaltime = 0
    self.tick = 0
    self.snapshots[ self.tick ] = game.demosystem:generateSnapshot( self.tick, self.totaltime )
end

function Network:stop()
    self.server = nil
    self.running = false
    self.totaltime = 0
    self.tick = 0
end

-- We send out updates at the current updaterate
function Network:update( dt )
    self.totaltime = self.totaltime + dt
    if self.currenttime > self.updaterate then
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
        self:simulate( minplayer.tick, self.players )

        -- Now that we have an updated game world, we send over diff updates
        -- specific for each player's current gamestate
        for i,v in pairs( self.players ) do
            local snapa = self.snapshots[ v.tick ]
            local snapb = self.snapshots[ self.tick ]
            self.server.send( v.id, Tserial.pack( game.demosystem:getDiff( snapa, snapb ) ) )
        end
    end
end

function Network:simulate( snapshot, players )
end

function Network:getControls( id, tick )
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
