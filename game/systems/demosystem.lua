local DemoSystem = love.class( {
    uniqueid = 0,
    entities = {},
    removed = {},
    added = {},
    recording = false,
    playing = false,
    file = nil,
    filelines = nil,
    updaterate = 15,
    timepassed = 0,
    tick = 0,
    totaltimepassed = 0,
    prevframe = nil,
    nextframe = nil
} )

-- This is used to create delta snapshots of entities,
-- aka it only records/copies changes from the last deltacopy()
function DemoSystem:deltacopy( orig )
    local copy = { demoIndex=orig.demoIndex }
    -- Network all networked vars
    for i,v in pairs( orig.networkedvars ) do
        -- but only network the ones that changed
        if orig.networkedchanges[ v ] then
            copy[v] = orig[v]
        end
    end
    -- Reset any change flags
    orig.networkedchanges = {}
    return copy
end

-- This is used to add new entities
function DemoSystem:copy( orig )
    local copy = { __name=orig.__name, demoIndex=orig.demoIndex }
    -- Network all networked vars
    for i,v in pairs( orig.networkedvars ) do
        copy[v] = orig[v]
    end
    return copy
end

function DemoSystem:addEntity( e, uid )
    uid = uid or self.uniqueid
    -- table.insert( self.entities, e )
    -- If our unique ID conflicts with something, remove the old
    -- entity that had the id.
    if self.entities[ uid ] ~= nil then
        self.entities[ uid ]:remove()
    end
    self.entities[ uid ] = e
    e.demoIndex = uid
    if uid > self.uniqueid then
        self.uniqueid = uid + 1
    else
        self.uniqueid = self.uniqueid + 1
    end

    -- We record entities we add so that we know to create them
    -- before working with the next snapshot
    if self.recording then
        -- self:copy makes sure we only network critical variables
        table.insert( self.added, self:copy( e ) )
    end
end

function DemoSystem:removeEntity( e )
    -- We record entities that we remove, so that we know to remove
    -- them before working with the next snapshot
    if self.recording then
        table.insert( self.removed, e.demoIndex )
    end
    --table.remove( self.entities, e.demoIndex )
    self.entities[ e.demoIndex ] = nil
    -- Have to update all the indicies of all the other entities.
    -- Just kidding now we have unique ids
    --for i=e.entitiesIndex, table.maxn( self.entities ), 1 do
        --self.entities[i].demoIndex = self.entities[i].demoIndex - 1
    --end
end

function DemoSystem:record( filename )
    local i = 0
    local original = "demos/" .. filename
    love.filesystem.createDirectory( "demos/" )
    filename =  "demos/" .. filename .. ".txt"
    -- Make sure we have a file that doesn't exist
    while love.filesystem.exists( filename ) do
        filename = original .. "_" .. tostring( i ) .. ".txt"
        i = i + 1
    end
    print( "Recording demo to " .. filename )
    self.file = love.filesystem.newFile( filename, "w" )
    local string = Tserial.pack( self:generateFullSnapshot() )
    local success, errormsg = self.file:write( string .. "\n" )
    if not success then
        error( errormsg )
    end
    self.recording = true
    self.playing = false
end

function DemoSystem:play( filename )
    if self.recording then
        self:stop()
    end
    filename = "demos/" .. filename .. ".txt"
    self.file = love.filesystem.newFile( filename, "r" )
    self.filelines = self.file:lines()
    self.playing = true
    self.recording = false
    -- FIXME: Assumes file will have more than two lines in it.
    self.prevframe = Tserial.unpack( self.filelines() )
    self.nextframe = Tserial.unpack( self.filelines() )
    self.tick = self.prevframe.tick
    for i,v in pairs( self.prevframe.added ) do
        local ent = game.entity( v.__name, { demoIndex=v.demoIndex } )
        for o,w in pairs( ent.networkedvars ) do
            local val = v[w]
            -- Call the coorisponding function to set the
            -- value
            if val ~= nil then
                ent[ ent.networkedfunctions[ o ] ]( ent, val )
            end
        end
        --print( "Created ent", ent.__name, "at", ent:getPos() )
    end
end

-- Creates a delta snapshot based on what has changed.
function DemoSystem:generateSnapshot()
    local snapshot = {}
    -- We show that some entities have been removed with this variable
    -- That way indicies can be kept track of
    snapshot["time"] = self.totaltimepassed
    snapshot["tick"] = self.tick
    snapshot["removed"] = self.removed
    self.removed = {}
    snapshot["added"] = self.added
    snapshot["entities"] = {}
    self.added = {}
    for i,v in pairs( self.entities ) do
        if v.netchanged then
            v.netchanged = false
            table.insert( snapshot.entities, v.demoIndex, self:deltacopy( v ) )
        end
    end
    return snapshot
end

-- Same as generateSnapshot but it includes ALL entities, not just what
-- has changed since the last snapshot
function DemoSystem:generateFullSnapshot()
    local added = {}
    for i,v in pairs( self.entities ) do
        local ent = { __name=v.__name, pos=v:getPos(), rot=v:getRot() }
        table.insert( added, ent )
    end
    local snapshot = {}
    snapshot["time"] = self.totaltimepassed
    snapshot["tick"] = self.tick
    snapshot["added"] = {}
    for i,v in pairs( self.entities ) do
        table.insert( snapshot.added, v.demoIndex, self:copy( v ) )
    end
    snapshot["full"] = true
    -- Since all of the entities are going to be added this frame, we don't have an entities table
    snapshot["entities"] = {}
    return snapshot
end

function DemoSystem:stop()
    if self.file ~= nil then
        self.file:close()
        self.file = nil
    end
    self.recording = false
    self.tick = 0
    self.totaltimepassed = 0
    self.timepassed = 0
    print( "Recording/Playback stopped!" )
end

function DemoSystem:leave()
    self:stop()
end

function DemoSystem:interpolate( pt, ft, x )
    if ft == nil then
        return pt
    end
    if type( pt ) == "table" then
        local t = {}
        for i,v in pairs( pt ) do
            local pastval = v
            local futureval = ft[i]
            if type( pastval ) == "table" then
                t[i] = self:interpolate( pastval, futureval, x )
            else
                t[i] = pastval + ( futureval - pastval ) * x
            end
        end
        return t
    else
        local pastval = pt
        local futureval = ft
        return pastval + ( futureval - pastval ) * x
    end
end

function DemoSystem:update( dt )
    if self.recording and self.file ~= nil then
        self.totaltimepassed = self.totaltimepassed + dt
        self.timepassed = self.timepassed + dt * 1000
        while self.timepassed > self.updaterate do
            self.tick = self.tick + 1
            self.timepassed = self.timepassed - self.updaterate
            local snapshot = self:generateSnapshot()
            local string = Tserial.pack( snapshot )
            local success, errormsg = self.file:write( string .. "\n" )
            if not success then
                error( errormsg )
            end
        end
    elseif self.playing and self.file ~= nil then
        self.totaltimepassed = self.totaltimepassed + dt
        while self.totaltimepassed > self.nextframe.time do
            self.tick = self.tick + 1
            --print( "Moved to tick", self.tick )
            self.prevframe = self.nextframe
            -- This is where we delete everything it asks
            for i,v in pairs( self.prevframe.removed ) do
                --print( "Removed ent", v )
                -- Given the unique ID's, we should never
                -- have problems from directly removing
                -- entities like this.
                if self.entities[v] ~= nil then
                    self.entities[ v ]:remove()
                end
            end
            -- This is where we add everything it asks
            for i,v in pairs( self.prevframe.added ) do
                local ent = game.entity( v.__name, { demoIndex=v.demoIndex } )
                for o,w in pairs( ent.networkedvars ) do
                    local val = v[w]
                    -- Call the coorisponding function to set the
                    -- value
                    if val ~= nil then
                        ent[ ent.networkedfunctions[ o ] ]( ent, val )
                    end
                end
                local pent = self.prevframe.entities[ ent.demoIndex ]
                if pent ~= nil then
                    for o,w in pairs( ent.networkedvars ) do
                        local val = pent[w]
                        -- Call the coorisponding function to set the
                        -- value
                        if val ~= nil then
                            ent[ ent.networkedfunctions[ o ] ]( ent, val )
                        end
                    end
                end
                --print( "Created ent", ent.demoIndex, ent.__name, "at", ent:getPos() )
            end
            local test = self.filelines()
            if test == nil then
                self:stop()
                return
            end
            self.nextframe = Tserial.unpack( test )
        end
        -- Uses linear progression
        local x = ( self.totaltimepassed - self.prevframe.time ) / self.nextframe.time
        for i,v in pairs( self.entities ) do
            local pent = self.prevframe.entities[ v.demoIndex ]
            local fent = self.nextframe.entities[ v.demoIndex ]
            -- Make sure the entity is changing somehow
            if pent ~= nil and fent ~= nil then
                for o,w in pairs( v.networkedvars ) do
                    local pastval = pent[w]
                    local futureval = fent[w]
                    -- Call the coorisponding function to set the
                    -- interpolated value (which can be a table)
                    if pastval ~= nil then
                        v[ v.networkedfunctions[ o ] ]( v, self:interpolate( pastval, futureval, x ) )
                    end
                end
            end
        end
    end
end

return DemoSystem
