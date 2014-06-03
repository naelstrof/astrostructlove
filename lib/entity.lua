-- An entity cannot be assumed to have anything besides a list of its
-- components, position, and rotation.

-- An entity with "nil" components is literally nothing but a position and rotation.

local Entity = love.class( { components = nil,
                             pos = nil,
                             rot = 0
                           } )

Entity.__name = "Entity"

function Entity:__init( components )
    self.pos = game.vector( 0, 0 )
    self.rot = 0
    self.components = components
    for i,v in pairs( components ) do
        v:init( self )
    end
    game.entities:addEntity( self )
end

function Entity:remove()
    for i,v in pairs( self.components ) do
        v:deinit( self )
    end
    game.entities:removeEntity( self )
end

function Entity:setPos( pos )
    self.pos = pos
end

function Entity:getPos( pos )
    return self.pos
end

function Entity:setRot( rot )
    self.rot = rot
end

function Entity:getRot()
    return self.rot
end

function Entity:hasComponent( comp )
    for i,v in pairs( self.components ) do
        if comp == v then
            return true
        end
    end
    return false
end

return Entity
