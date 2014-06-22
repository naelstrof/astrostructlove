-- An entity cannot be assumed to have anything besides a list of its
-- components, position, and rotation.

-- An entity with "nil" components is literally nothing but a position and rotation.

local Entity = love.class( {
                             components = nil,
                             chains = {},
                             -- TODO: Make pos into __pos so that users never have to worry about conflicting names
                             pos = nil,
                             tempfunction = nil,
                             rot = 0,
                             valid = true
                           } )


function Entity:deepCopy( t )
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = self:deepCopy(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

--function Entity:__init( components, attributes )
-- Entities are initialized via their index within the gamemodes.entities
function Entity:__init( name )
    self.__name = name
    self.pos = game.vector( 0, 0 )
    local attributes = game.gamemode.entities[ name ].attributes or {}
    self.components = game.gamemode.entities[ name ].components
    -- Set up the attributes first as they may affect the components
    for i,v in pairs( attributes ) do
        self[i] = v
    end
    -- Attempt to inherit all functions and variables in each component
    for i,v in pairs( self.components ) do
        -- Each component should be a class
        -- We inherit all values and functions
        for o,w in pairs( v ) do
            if self[o] == nil then
                if type( w ) == "table" then
                    -- Deep copy tables
                    self[o] = self:deepCopy( w )
                else
                    self[o] = w
                end
            elseif type( self[o] ) == "function" and type( w ) == "function" then
                -- We attempt to chain similar functions
                if self.chains[o] == nil then
                    self.chains[o] = { default=self[o] }
                end
                -- v ( the component ) is guaranteed to be unique
                -- for the purposes of chaining.
                self.chains[o][v] = w
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

function Entity:removeComponent( comp )
    -- First we call the component's specific deinit function
    self.tempfunction = self.chains["deinit"][ comp ]
    self:tempfunction()
    self.tempfunction = nil
    -- Because chains use the component as an index, we can easily
    -- remove chained functions.
    for i, v in pairs( self.chains ) do
        v[comp] = nil
    end
    -- Remove the component because we're not using it anymore.
    for i, v in pairs( self.components ) do
        if v == comp then
            v = nil
        end
    end
end

function Entity:startChain( index, tableofargs )
    -- Refuse to start chains if we're considered invalid
    if not self.valid then
        return
    end
    table.remove( tableofargs, 1 )
    local args = unpack( tableofargs )
    for i, v in pairs( self.chains[index] ) do
        -- We always execute the original function last
        -- so that the old information can be referenced.
        if i ~= "default" then
            self.tempfunction = v
            self:tempfunction( args )
        end
    end
    self.tempfunction = self.chains[ index ][ "default" ]
    self:tempfunction( args )
    self.tempfunction = nil
end

function Entity:remove()
    -- Refuse to remove self if we're invalid.
    -- Reason is to keep entities from being removed twice.
    if not self.valid then
        return
    end
    self:deinit()
    game.entities:removeEntity( self )
    self.valid = false
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
