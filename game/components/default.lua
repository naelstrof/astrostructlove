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

local init = function( e )
    game.entities:addEntity( e )
end

local deinit = function( e )
    game.entities:removeEntity( e )
end

local Default = {
    __name = "Default",
    pos = game.vector( 0, 0 ),
    rot = 0,
    setPos = setPos,
    getPos = getPos,
    setRot = setRot,
    getRot = getRot,
    networkedvars = { "pos", "rot" },
    networkedfunctions = { "setPos", "setRot" },
    init = init,
    deinit = deinit
}

return Default
