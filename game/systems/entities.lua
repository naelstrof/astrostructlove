-- Keeps track of all entities that are created so they can easily be filtered, disposed of, or otherwise
-- worked with.

local Entities = love.class( { entities = {} } )

function Entities:addEntity( e )
    table.insert( self.entities, e )
    e.entitiesIndex = table.maxn( self.entities )
end

function Entities:removeEntity( e )
    table.remove( self.entities, e.entitiesIndex )
    -- Have to update all the indicies of all the other entities.
    for i=e.entitiesIndex, table.maxn( self.entities ), 1 do
        self.entities[i].entitiesIndex = self.entities[i].entitiesIndex - 1
    end
end

function Entities:getAll()
    -- Must return a copy so the user can't manually edit the table
    -- This keeps bugs like removing entities with :remove() messing
    -- with the table size or structure in the middle of a loop.
    local ents = {}
    for i,v in pairs( self.entities ) do
        ents[i] = v
    end
    return ents
end

-- TODO: Needs some kind of optimization so we don't have to loop through every entity in the world.
function Entities:getNearby( pos, radius )
    local ents = {}
    for i,v in pairs( self.entities ) do
        if v:hasComponent( compo.drawable ) then
            -- FIXME: This could be way more accurate, its assuming everything is a circle because I'm a lazy ass.
            -- Perhaps a component could describe the shape of something? May need to implement a shape collision library.
            local vradius = math.max( v:getDrawable():getWidth()*v:getScale().x, v:getDrawable():getHeight()*v:getScale().y )
            if pos:dist( v:getPos() ) < (radius + vradius) / 2 then
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

function Entities:getClicked()
    local mousepos = game.camerasystem:getWorldMouse()
    -- FIXME: Having a radius selection of 1 means that selection could be more annoying or less annoying when attempting to click on singular pixel objects
    -- testing may have to be done.
    local ents = self:getNearby( mousepos, 1 )
    -- Find the top-most drawable entity
    local topmost = nil
    for i,v in pairs( ents ) do
        if v:hasComponent( compo.drawable ) then
            if topmost == nil or topmost.layer < v.layer or ( topmost.rendererIndex < v.rendererIndex and topmost.layer <= v.layer ) then
                topmost = v
            end
        end
    end
    return topmost
end

return Entities
