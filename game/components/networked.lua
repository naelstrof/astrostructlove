local setPos = function( e, pos )
    if e.pos ~= pos then
        e.netchanged = true
    end
end

local setRot = function( e, rot )
    if e.rot ~= rot then
        e.netchanged = true
    end
end

local setScale = function( e, scale )
    if e.scale ~= scale then
        e.netchanged = true
    end
end

local init = function( e )
    game.demosystem:addEntity( e )
end

local deinit = function( e )
    game.demosystem:removeEntity( e )
end

local Networked = {
    __name = "Networked",
    netchanged = true,
    init = init,
    deinit = deinit,
    setPos = setPos,
    setRot = setRot,
    setScale = setScale
}

return Networked
