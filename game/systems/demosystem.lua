local DemoSystem = love.class( {
    entities = {},
    removed = {},
    added = {},
    humanreadable = false,
    recording = false,
    file = nil,
    updaterate = 15,
    timepassed = 0,
    tick = 0,
    totaltimepassed = 0,
    stream = nil
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
    local comps = {}
    for i,v in pairs( e.components ) do
        table.insert( comps, v.__name )
    end
    table.insert( self.added, comps )
end

function DemoSystem:removeEntity( e )
    -- We record entities that we remove, so that we know to remove
    -- them before working with the next snapshot
    table.insert( self.removed, e.demoIndex )
    table.remove( self.entities, e.demoIndex )
    -- Have to update all the indicies of all the other entities.
    for i=e.entitiesIndex, table.maxn( self.entities ), 1 do
        self.entities[i].demoIndex = self.entities[i].demoIndex - 1
    end
end

function DemoSystem:record( filename )
    self.stream = zlib.deflate()
    local i = 0
    local original = filename
    filename = filename .. ".bin"
    -- Make sure we have a file that doesn't exist
    while love.filesystem.exists( filename ) do
        filename = original .. "_" .. tostring( i ) .. ".bin"
        i = i + 1
    end
    self.file = love.filesystem.newFile( filename, "w" )
    local string = self.stream( luabins.save( self:generateFullSnapshot() ), "sync" )
    local success, errormsg = self.file:write( string .. "\n" )
    if not success then
        error( errormsg )
    end
    self.recording = true
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
    if not self.recording and self.file ~= nil then
        return
    end
    self.totaltimepassed = self.totaltimepassed + dt
    self.timepassed = self.timepassed + dt * 1000
    while self.timepassed > self.updaterate do
        self.tick = self.tick + 1
        self.timepassed = self.timepassed - self.updaterate
        local snapshot = self:generateSnapshot()
        print( luabins.save( snapshot ) )
        local string = self.stream( luabins.save( snapshot ), "sync" )
        local success, errormsg = self.file:write( string .. "\n" )
        if not success then
            error( errormsg )
        end
    end
end

return DemoSystem
