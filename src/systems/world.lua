-- Keeps track of all entities that are created so they can easily be filtered, disposed of, or otherwise
-- worked with.

local World = {
    entities = {},
    totaltime = 0,
    grid={}
}

function World:getCurrentTime()
    return self.totaltime
end

function World:addEntity( e )
    table.insert( self.entities, e )
    e.entitiesIndex = table.maxn( self.entities )
end

function World:addToGrid( e )
    local x = e:getPos().x - 32
    local y = e:getPos().y - 32
    -- If we don't fit perfectly onto the self.grid
    if not ( x % 64 == 0 and y % 64 == 0 ) then
        error( "Attempted to add entity to the self.grid when it's not on the self.grid!" )
    end
    x = math.floor( x/64 )
    y = math.floor( y/64 )
    if not self.grid[x] then
        self.grid[x] = {}
    end
    if not self.grid[x][y] then
        self.grid[x][y] = {}
    end
    table.insert( self.grid[x][y], e )
    e.griddepth = #(self.grid[x][y])
end

function World:removeFromGrid( e )
    if not e.griddepth then
        return
    end
    local x = math.floor( ( e:getPos().x - 32 ) / 64 )
    local y = math.floor( ( e:getPos().y - 32 ) / 64 )
    self.grid[x][y][e.griddepth] = nil
    e.griddepth = nil
end

function World:getEntitiesAtGrid( x, y )
    x = math.floor( (x-32)/64 )
    y = math.floor( (y-32)/64 )
    if not self.grid[x] then
        self.grid[x] = {}
    end
    if not self.grid[x][y] then
        self.grid[x][y] = {}
    end
    return self.grid[x][y]
end

function World:removeEntity( e )
    table.remove( self.entities, e.entitiesIndex )
    -- Have to update all the indicies of all the other entities.
    for i=e.entitiesIndex, table.maxn( self.entities ), 1 do
        self.entities[i].entitiesIndex = self.entities[i].entitiesIndex - 1
    end
    if e.griddepth then
        local x = math.floor( (e:getPos().x-32)/64 )
        local y = math.floor( (e:getPos().y-32)/64 )
        self.grid[x][y][e.griddepth] = nil
    end
end

function World:removeAll()
    for i,v in pairs( self:getAll() ) do
        v:remove()
    end
    self.totaltime = 0
end

function World:getAll()
    -- Must return a copy so the user can't manually edit the table
    -- This keeps bugs like removing entities with :remove() messing
    -- with the table size or structure in the middle of a loop.
    local ents = {}
    for i,v in pairs( self.entities ) do
        ents[i] = v
    end
    return ents
end

function World:getAllNamed( name )
    local ents = {}
    for i,v in pairs( self.entities ) do
        if v.__name == name then
            table.insert( ents, v )
        end
    end
    return ents
end

-- TODO: Needs some kind of optimization so we don't have to loop through every entity in the world.
function World:getNearby( pos, radius )
    local ents = {}
    for i,v in pairs( self.entities ) do
        if v:hasComponent( Components.drawable ) then
            -- FIXME: This could be way more accurate, its assuming everything is a circle because I'm a lazy ass.
            -- Perhaps a component could describe the shape of something? May need to implement a shape collision library.
            local vradius = math.max( v:getDrawable():getWidth()*v:getScale().x, v:getDrawable():getHeight()*v:getScale().y ) / 2
            if pos:dist( v:getPos() ) < radius + vradius then
                table.insert( ents, v )
            end
        else
            if pos:dist( v:getPos() ) < radius then
                table.insert( ents, v )
            end
        end
    end
    return ents
end

function World:getClicked()
    local mousepos = CameraSystem:getWorldMouse()
    -- FIXME: Having a radius selection of 5 means that selection could be more annoying or less annoying when attempting to click on singular pixel objects
    -- testing may have to be done.
    local ents = self:getNearby( mousepos, 5 )
    -- Find the top-most drawable entity
    local topmost = nil
    for i,v in pairs( ents ) do
        if v:hasComponent( Components.drawable ) then
            if topmost == nil or not topmost:hasComponent( Components.drawable ) or topmost.layer < v.layer or ( topmost.rendererIndex < v.rendererIndex and topmost.layer <= v.layer ) then
                topmost = v
            end
        else
            topmost = v
        end
    end
    return topmost
end

function World:update( dt )
    for i,v in pairs( self.entities ) do
        if v.update ~= nil then
            v:update( dt, self.totaltime )
        end
    end
    self.totaltime = self.totaltime + dt
end

function World:resize( w, h )
    for i,v in pairs( self.entities ) do
        if v.resize ~= nil then
            v:resize( w, h )
        end
    end
end

return World
