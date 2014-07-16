-- Keeps track of all entities that are created so they can easily be filtered, disposed of, or otherwise
-- worked with.

local World = Class( { entities = {} } )

function World:addEntity( e )
    table.insert( self.entities, e )
    e.entitiesIndex = table.maxn( self.entities )
end

function World:removeEntity( e )
    table.remove( self.entities, e.entitiesIndex )
    -- Have to update all the indicies of all the other entities.
    for i=e.entitiesIndex, table.maxn( self.entities ), 1 do
        self.entities[i].entitiesIndex = self.entities[i].entitiesIndex - 1
    end
end

function World:removeAll()
    for i,v in pairs( self:getAll() ) do
        v:remove()
    end
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

function World:update( dt, tick )
    for i,v in pairs( self.entities ) do
        if v.update ~= nil then
            v:update( dt, tick )
        end
    end
end

function World:resize( w, h )
    for i,v in pairs( self.entities ) do
        if v.resize ~= nil then
            v:resize( w, h )
        end
    end
end

return World
