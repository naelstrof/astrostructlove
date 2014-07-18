-- An entity cannot be assumed to have anything besides a list of its
-- components, position, and rotation.

-- Oh and it keeps track of networked variables and their coorisponding
-- functions to update the variables.
-- It only supports networking simple types like tables, numbers, and strings.
-- There's no recursive tables or functions or metadata allowed.

-- An entity with "nil" components is literally nothing but a position and rotation.

local Entity = Class( {
    __type = "Entity",
    components = nil,
    -- TODO: Make pos into __pos so that users never have to worry about conflicting names
    tempfunction = nil,
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
-- World are initialized via their index within the gamemodes.entities
function Entity:__init( name, extraattributes )
    self.__name = name
    if not Entities.entities[ name ] then
        error( "Failed to load entity named " .. name .. "! Does it exist?" )
    end
    local attributes = Entities.entities[ name ].attributes or {}
    extraattributes = extraattributes or {}
    -- All entities should have the default component at LEAST
    self.components = Entities.entities[ name ].components
    -- Set up the attributes first as they may affect the components
    for i,v in pairs( attributes ) do
        self[i] = v
    end
    -- This is for on-the-fly attributes/overrides
    for i,v in pairs( extraattributes ) do
        self[i] = v
    end
    -- Attempt to inherit all functions and variables in each component
    for i,v in pairs( self.components ) do
        if v == nil then
            error( "WARN: Entity created with nil component!" )
        end
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
            elseif type( self[o] ) == "function" and type( w ) == "function" and attributes[o] == nil and extraattributes[o] == nil then
                -- We attempt to chain similar functions
                self[o] = function( ... )
                    self:startChain( o, { ... } )
                end
            end
            -- Every other variable is considered an override
        end
    end
    -- Purge networked stuff, the gamemode handles tracking these
    self.networkinfo = nil
    self.networkedfunctions = nil
    -- After we have inherited all functions and variables,
    -- we initialize each component. Since each component has
    -- an init function, it has been chained together.
    self:init()
end

function Entity:removeComponent( comp )
    -- First we call the component's specific deinit function
    self.tempfunction = comp.deinit()
    self:tempfunction()
    self.tempfunction = nil
    -- Remove the component because we're not using it anymore.
    for i, v in pairs( self.components ) do
        if v == comp then
            self.components[i] = nil
        end
    end
end

function Entity:startChain( index, tableofargs )
    table.remove( tableofargs, 1 )
    for i, v in pairs( self.components ) do
        local func = v[ index ]
        if func ~= nil and type( func ) == "function" then
            self.tempfunction = func
            self:tempfunction( unpack( tableofargs ) )
        end
    end
    self.tempfunction = nil
end

function Entity:remove()
    self:deinit()
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
