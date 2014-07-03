-- Camera component allows an entity to control the view

local setPos = function( e, t )
    e.camera:lookAt( t.x, t.y )
end

local setRot = function( e, rot )
    e.camera:rotateTo( -rot )
end

local setZoom = function( e, zoom )
    e.zoom = zoom
    e.camera:zoomTo( zoom )
end

local Zoom = function( e, zoom )
    e.zoom = e.zoom * zoom
    e.camera:zoom( zoom )
end

local getZoom = function( e )
    return e.zoom
end

local setActive = function( e, active )
    e.active = active
    if active then
        game.camerasystem:setActive( e )
    end
end

local toWorld = function( e, pos )
    local x,y = e.camera:worldCoords( pos.x, pos.y )
    return game.vector( x, y )
end

local init = function( e )
    e.camera = game.camera()
    e.camera:lookAt( e:getPos().x, e:getPos().y )
    e.camera:zoomTo( e.zoom )
    e.camera:rotateTo( -e.rot )
    if e.active then
        game.camerasystem:setActive( e )
    end
end

local deinit = function( e )
end

local Camera = {
    __name = "Camera",
    camera = nil,
    zoom = 1,
    init = init,
    active = false,
    deinit = deinit,
    setPos = setPos,
    setRot = setRot,
    setZoom = setZoom,
    setActive = setActive,
    getZoom = getZoom,
    networkedvars = { "zoom", "active" },
    networkedfunctions = { "setZoom", "setActive" },
    Zoom = Zoom,
    toWorld = toWorld
}

return Camera
