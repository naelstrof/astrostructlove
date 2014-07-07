-- Majority of the work is already done with my demoing system :)

local Client = {
    running = false,
    time = 0,
    tick = 0,
    lastshot = nil,
    prevshot = nil,
    nextshot = nil,
    id = 0,
    delay = 30/1000,
    client = nil,
    snapshots = {}
}

function Client:setID( id )
    self.id = id
end

function Client:start( snapshot, client )
    -- Just like source multiplayer, we render 30 miliseconds in the past
    self.time = snapshot.time - self.delay
    --self.time = snapshot.time - 1
    self.client = client
    self.tick = snapshot.tick
    self.snapshots[ snapshot.tick ] = snapshot
    self.lastshot = self.snapshots[ snapshot.tick ]
    self.prevshot = self.snapshots[ snapshot.tick ]
    self.nextshot = nil
    self.running = true
    -- This is where we delete everything it asks
    for i,v in pairs( self.prevshot.removed ) do
        --print( "Removed ent", v )
        -- Given the unique ID's, we should never
        -- have problems from directly removing
        -- entities like this.
        if game.demosystem.entities[ v ] ~= nil then
            game.demosystem.entities[ v ]:remove()
        end
    end
    -- This is where we add everything it asks
    for i,v in pairs( self.prevshot.added ) do
        if v.playerid == self.id then
            v.active = true
        elseif v.playerid or v.active then
            v.active = false
        end
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
end

function Client:addSnapshot( snapshot )
    self.snapshots[ snapshot.tick ] = snapshot
end

function Client:stop()
    self.running = false
end

function Client:update( dt )
    if not self.running then
        return
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
        for i,v in pairs( self.prevshot.removed ) do
            --print( "Removed ent", v )
            -- Given the unique ID's, we should never
            -- have problems from directly removing
            -- entities like this.
            if game.demosystem.entities[ v ] ~= nil then
                game.demosystem.entities[ v ]:remove()
            end
        end
        -- This is where we add everything it asks
        for i,v in pairs( self.prevshot.added ) do
            if v.playerid == self.id then
                v.active = true
            elseif v.playerid or v.active then
                v.active = false
            end
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
        -- This is where we interpolate forward a bit
        self:update( 0 )
        return
    end
end

function Client.interpolate( prevshot, nextshot, x )
    for i,v in pairs( game.demosystem.entities ) do
        local pent = prevshot.entities[ v.demoIndex ]
        local fent = nextshot.entities[ v.demoIndex ]
        -- We do NOT extrapolate our player, it's simulated
        if x > 1 and v.playerid == game.client.id then
            pent = nil
            fent = nil
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

return Client
