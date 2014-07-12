-- Since position is stored as a table
-- we must be able to set it as a table
-- so that it can be networked easily
local setPos = function( e, t )
    if t == nil or t.x == nil or t.y == nil then
        error( "Failed to set position: Invalid parameters supplied!" )
    end
    e.pos = game.vector( t.x, t.y )
end

local getPos = function( e )
    return e.pos
end

local setRot = function( e, rot )
    e.rot = rot
end

local getRot = function( e )
    return e.rot
end

-- Initialization/deinitialization can remove a entity from the world,
-- but keep it in play in some way or another
-- It's used right now for containers, and thus needs to be networked
local setInitialized = function( e, i )
    if e.initialized == i then
        return
    end
    if i then
        e:init()
    else
        e:deinit()
    end
    -- We don't have to update e.initialized since
    -- init() and deinit() take care of it
    -- e.initialized = i
end

local init = function( e )
    game.entities:addEntity( e )
    e.initialized = true
end

local deinit = function( e )
    game.entities:removeEntity( e )
    e.initialized = false
end

local Default = {
    __name = "Default",
    pos = game.vector( 0, 0 ),
    rot = 0,
    setPos = setPos,
    getPos = getPos,
    setRot = setRot,
    getRot = getRot,
    initialized = false,
    setInitialized = setInitialized,
    networkedvars = { "pos", "rot", "initialized" },
    networkedfunctions = { "setPos", "setRot", "setInitialized" },
    init = init,
    deinit = deinit
}

return Default
