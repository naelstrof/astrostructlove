local DemoSystem = love.class( {
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

function DemoSystem:copy( orig )
    local copy = {}
    --for i,v in next, orig, nil do
        --local vtype = type( v )
        --if vtype ~= "function" and i~= "__index" and i~= "components" and i~= "chains" and vtype ~= "thread" and vtype ~= "userdata" then
            --if vtype == "table" then
                --copy[i] = self:copy( v )
            --else
                --copy[i] = v
            --end
        --end
    --end
    -- Only network positions and rotations for now
    copy.pos = orig.pos
    copy.rot = orig.rot
    return copy
end

function DemoSystem:addEntity( e )
    table.insert( self.entities, e )
    e.demoIndex = table.maxn( self.entities )

    -- We record entities we add so that we know to create them
    -- before working with the next snapshot
    if self.recording then
        -- Only network over these critical attributes.
        local ent = { __name=e.__name, pos=e:getPos(), rot=e:getRot() }
        table.insert( self.added, ent )
    end
end

function DemoSystem:removeEntity( e )
    -- We record entities that we remove, so that we know to remove
    -- them before working with the next snapshot
    if self.recording then
        table.insert( self.removed, e.demoIndex )
    end
    table.remove( self.entities, e.demoIndex )
    -- Have to update all the indicies of all the other entities.
    for i=e.entitiesIndex, table.maxn( self.entities ), 1 do
        self.entities[i].demoIndex = self.entities[i].demoIndex - 1
    end
end

function DemoSystem:record( filename )
    local i = 0
    local original = filename
    filename = filename .. ".txt"
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
    self.file = love.filesystem.newFile( filename, "r" )
    self.filelines = self.file:lines()
    self.playing = true
    self.recording = false
    -- FIXME: Assumes file will have more than two lines in it.
    self.prevframe = Tserial.unpack( self.filelines() )
    self.nextframe = Tserial.unpack( self.filelines() )
    self.tick = self.prevframe.tick
    for i,v in pairs( self.prevframe.added ) do
        local ent = game.entity( v.__name )
        ent:setPos( game.vector( v.pos.x, v.pos.y ) )
        ent:setRot( v.rot )
        -- Automatically set the default camera
        if ent:hasComponent( compo.camera ) then
            game.camerasystem:setActive( ent )
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
            table.insert( snapshot.entities, v.demoIndex, self:copy( v ) )
        end
    end
    return snapshot
end

-- Same as generateSnapshot but it includes ALL entities, not just what
-- has changed since the last snapshot
function DemoSystem:generateFullSnapshot( update )
    local added = {}
    for i,v in pairs( self.entities ) do
        local ent = { __name=v.__name, pos=v:getPos(), rot=v:getRot() }
        table.insert( added, ent )
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
    snapshot["entities"] = {}
    for i,v in pairs( self.entities ) do
        table.insert( snapshot.entities, v.demoIndex, self:copy( v ) )
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
    print( "Recording stopped!" )
end

function DemoSystem:leave()
    self:stop()
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
            -- This is where we spawn/delete everything it asks
            for i,v in pairs( self.prevframe.removed ) do
                --print( "Removed ent", v )
                self.entities[ v ]:remove()
            end
            for i,v in pairs( self.prevframe.added ) do
                local ent = game.entity( v.__name )
                ent:setPos( game.vector( unpack( v.pos ) ) )
                ent:setRot( v.rot )
                local pent = self.prevframe.entities[ ent.demoIndex ]
                if pent ~= nil then
                    ent:setPos( game.vector( pent.pos.x, pent.pos.y ) )
                    ent:setRot( pent.rot )
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
                local ppos = game.vector( pent.pos.x, pent.pos.y )
                local fpos = game.vector( fent.pos.x, pent.pos.y )
                v:setPos( ppos + ( fpos - ppos ) * x )
                v:setRot( pent.rot + ( fent.rot - pent.rot ) * x )
            end
        end
    end
end

return DemoSystem
