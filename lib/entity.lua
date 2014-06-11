-- An entity cannot be assumed to have anything besides a list of its
-- components, position, and rotation.

-- An entity with "nil" components is literally nothing but a position and rotation.

local Entity = love.class( { components = nil,
                             chains = {},
                             pos = nil,
                             tempfunction = nil,
                             rot = 0
                           } )

Entity.__name = "Entity"

function Entity:__init( components, attributes )
    self.pos = game.vector( 0, 0 )
    attributes = attributes or {}
    self.components = components
    -- Set up the attributes first as they may affect the components
    for i,v in pairs( attributes ) do
        self[i] = v
    end
    -- Attempt to inherit all functions and variables in each component
    for i,v in pairs( components ) do
        -- Each component should be a class
        -- We inherit all values and functions
        for o,w in pairs( v ) do
            if self[o] == nil then
                self[o] = w
            elseif type( self[o] ) == "function" and type( w ) == "function" then
                -- We attempt to chain similar functions
                if self.chains[o] == nil then
                    self.chains[o] = { self[o] }
                end
                table.insert( self.chains[o], w )
                self[o] = function( ... )
                    self:startChain( o, { ... } )
                end
            end
            -- Every other variable is considered an override
        end
    end
    -- After we have inherited all functions and variables,
    -- we initialize each component. Since each component has
    -- an init function, it has been chained together.
    self:init()
    game.entities:addEntity( self )
end

function Entity:startChain( index, tableofargs )
    table.remove( tableofargs, 1 )
    for i, v in pairs( self.chains[index] ) do
        self.tempfunction = v
        self:tempfunction( unpack( tableofargs ) )
    end
end

function Entity:remove()
    self:deinit()
    game.entities:removeEntity( self )
end

function Entity:setPos( x, y )
    if game.vector.isvector( x ) and y == nil then
        self.pos = x
    elseif x ~= nil and y ~= nil then
        self.pos = game.vector( x, y )
    else
        error( "Failed to set position: Invalid parameters supplied!" )
    end
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
