local DemoSystem = common.class( {
    uniqueid = 0,
    entities = {},
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

function DemoSystem:deltacopy( a, b )
    local changed = false
    local copy = {}
    -- Network all networked vars
    for i,v in pairs( b ) do
        -- but only network the ones that changed
        if a[i] ~= b[i] then
            changed = true
            copy[i] = b[i]
        end
    end
    if changed then
        -- We don't need to copy the name or index in a delta copy
        -- Due to entities being placed in the array using the index
        copy.__name = nil
        copy.demoIndex = nil
        return copy
    else
        return nil
    end
end

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
end

function DemoSystem:removeEntity( e )
    self.entities[ e.demoIndex ] = nil
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
    self.prevframe = self:generateSnapshot( self.tick, self.totaltimepassed )
    local string = Tserial.pack( self:getFull( self.prevframe ) )
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
        local ent = game.entity:new( v.__name, { demoIndex=v.demoIndex } )
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

-- Creates a delta snapshot based on what has changed, from a previous full snapshot
function DemoSystem:getDiff( a, b )
    local diffsnapshot = {}
    diffsnapshot["time"] = b.time
    diffsnapshot["tick"] = b.tick
    diffsnapshot["removed"] = {}
    diffsnapshot["added"] = {}
    diffsnapshot["entities"] = {}
    for i,v in pairs( a.entities ) do
        if b.entities[ i ] == nil then
            table.insert( diffsnapshot["removed"], v.demoIndex )
        end
    end
    for i,v in pairs( b.entities ) do
        if a.entities[ i ] == nil then
            table.insert( diffsnapshot["added"], v )
        else
            diffsnapshot["entities"][ v.demoIndex ] = self:deltacopy( a.entities[ i ], v )
        end
    end
    return diffsnapshot
end

-- Get the difference between a nil snapshot to a snapshot
function DemoSystem:getFull( a )
    local snapshot = {}
    snapshot["time"] = a.time
    snapshot["tick"] = a.tick
    snapshot["removed"] = {}
    snapshot["added"] = {}
    snapshot["entities"] = {}
    for i,v in pairs( a.entities ) do
        table.insert( snapshot["added"], v )
    end
    return snapshot
end

-- Gets a snapshot of the current state of the game
-- Manually specify the tick and time so that other systems
-- Can generate snapshots
function DemoSystem:generateSnapshot( tick, time )
    local snapshot = {}
    snapshot["time"] = time
    snapshot["tick"] = tick
    snapshot["removed"] = {}
    snapshot["added"] = {}
    snapshot["entities"] = {}
    for i,v in pairs( self.entities ) do
        snapshot["entities"][ v.demoIndex ] = self:copy( v )
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
            local snapshot = self:generateSnapshot( self.tick, self.totaltimepassed )
            local string = Tserial.pack( self:getDiff( self.prevframe, snapshot ) )
            local success, errormsg = self.file:write( string .. "\n" )
            if not success then
                error( errormsg )
            end
            self.prevframe = snapshot
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
                if self.entities[ v ] ~= nil then
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
