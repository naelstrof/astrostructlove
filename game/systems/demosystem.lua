local DemoSystem = love.class( {
    entities = {},
    removed = {},
    added = {},
    lookup = {},
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

function DemoSystem:copy( orig )
    local copy = {}
    for i,v in next, orig, nil do
        local vtype = type( v )
        if vtype ~= "function" and i~= "__index" and i~= "components" and i~= "chains" and vtype ~= "thread" and vtype ~= "userdata" then
            if vtype == "table" then
                copy[i] = self:copy( v )
            else
                copy[i] = v
            end
        end
    end
    return copy
end

function DemoSystem:addEntity( e )
    table.insert( self.entities, e )
    e.demoIndex = table.maxn( self.entities )

    -- We record entities we add so that we know to create them
    -- before working with the next snapshot
    if self.recording then
        local comps = {}
        for i,v in pairs( e.components ) do
            table.insert( comps, v.__name )
        end
        table.insert( self.added, comps )
    end
end

function DemoSystem:removeEntity( e )
    -- We record entities that we remove, so that we know to remove
    -- them before working with the next snapshot
    if self.recording then
        table.insert( self.removed, e.entityIndex )
    end
    table.remove( self.entities, e.demoIndex )
    -- Have to update all the indicies of all the other entities.
    for i=e.entitiesIndex, table.maxn( self.entities ), 1 do
        self.entities[i].demoIndex = self.entities[i].demoIndex - 1
    end
end

-- Generates string->component object table
-- to easily look up components via string
function DemoSystem:generateComponentKeys()
    self.lookup = {}
    for i,v in pairs( compo ) do
        self.lookup[ v.__name ] = v
    end
end

function DemoSystem:record( filename )
    local i = 0
    local original = filename
    filename = filename .. ".bin"
    -- Make sure we have a file that doesn't exist
    while love.filesystem.exists( filename ) do
        filename = original .. "_" .. tostring( i ) .. ".bin"
        i = i + 1
    end
    self.file = love.filesystem.newFile( filename, "w" )
    local string = luabins.save( self:generateFullSnapshot() )
    local success, errormsg = self.file:write( string .. "\n" )
    if not success then
        error( errormsg )
    end
    self.recording = true
    self.playing = false
end

function DemoSystem:play( filename )
    self:generateComponentKeys()
    if self.recording then
        self:stop()
    end
    self.file = love.filesystem.newFile( filename, "r" )
    self.filelines = self.file:lines()
    self.playing = true
    self.recording = false
    local string = string.sub( self.filelines(), 1, -2 )
    print( string )
    print( luabins.load( string ) )
    self.prevframe = luabins.load( self.filelines() )
    self.nextframe = luabins.load( self.filelines() )
    for i,v in pairs( self.prevframe ) do
        print( i, v )
    end
    for i,v in pairs( self.nextframe ) do
        print( i, v )
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
    self.added = {}
    for i,v in pairs( self.entities ) do
        if v.netchanged then
            v.netchanged = false
            table.insert( snapshot, v.demoIndex, self:copy( v ) )
        end
    end
    return snapshot
end

-- Same as generateSnapshot but it includes ALL entities, not just what
-- has changed since the last snapshot
function DemoSystem:generateFullSnapshot( update )
    local added = {}
    for i,v in pairs( self.entities ) do
        local comps = {}
        for o,w in pairs( v.components ) do
            table.insert( comps, w.__name )
        end
        table.insert( added, comps )
    end
    local snapshot = {}
    snapshot["time"] = self.totaltimepassed
    snapshot["tick"] = self.tick
    snapshot["added"] = added
    -- If we're told to empty the added queue do so.
    if update then
        self.added = {}
    end
    snapshot["full"] = true
    for i,v in pairs( self.entities ) do
        table.insert( snapshot, v.demoIndex, self:copy( v ) )
    end
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
end

function DemoSystem:leave()
    if self.file ~= nil then
        self.file:close()
        self.file = nil
    end
    self.recording = false
end

function DemoSystem:update( dt )
    if self.recording and self.file ~= nil then
        self.totaltimepassed = self.totaltimepassed + dt
        self.timepassed = self.timepassed + dt * 1000
        while self.timepassed > self.updaterate do
            self.tick = self.tick + 1
            self.timepassed = self.timepassed - self.updaterate
            local snapshot = self:generateSnapshot()
            local string = luabins.save( snapshot )
            local success, errormsg = self.file:write( string .. "\n" )
            if not success then
                error( errormsg )
            end
        end
    elseif self.playing and self.file ~= nil then
        self.totaltimepassed = self.totaltimepassed + dt
        while self.timepassed > self.nextframe.time do
            self.tick = self.tick + 1
            self.prevframe = self.nextframe
            -- This is where we spawn/delete everything it asks
            for i,v in pairs( self.prevframe.removed ) do
                self.entities[ v ]:remove()
            end
            for i,v in pairs( self.prevframe.added ) do
                local components = {}
                for o,w in pairs( v ) do
                    -- We use a lookup table to speed up string->component
                    -- conversion
                    table.insert( components, self.lookup[w] )
                end
                local ent = game.entity( components )
            end
            self.nextframe = luabins.load( self.filelines() )
        end
        error( "unimplemented" )
        --for i,v in pairs( self.entities ) do
        --end
    end
end

return DemoSystem
