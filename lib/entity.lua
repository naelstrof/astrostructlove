-- An entity cannot be assumed to have anything besides a list of its
-- components and a position.

-- An entity with "nil" components is literally nothing but a position.

local Entity = love.class( { components = nil, pos = game.vector( 0, 0 ) } )

Entity.__name = "Entity"

function Entity:__init( components )
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

return Entity
