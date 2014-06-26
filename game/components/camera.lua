-- Camera component allows an entity to control the view

local setPos = function( e, pos )
    e.camera:lookAt( pos.x, pos.y )
end

local setRot = function( e, rot )
    e.camera:rotateTo( -rot )
end

local setZoom = function( e, zoom )
    if e.zoom ~= zoom then
        e:setNetworkChanged( "zoom" )
    end
    e.zoom = zoom
    e.camera:zoomTo( zoom )
end

local Zoom = function( e, zoom )
    if e.zoom * zoom ~= e.zoom then
        e:setNetworkChanged( "zoom" )
    end
    e.zoom = e.zoom * zoom
    e.camera:zoom( zoom )
end

local getZoom = function( e )
    return e.zoom
end

local setActive = function( e, active )
    if e.active ~= active then
        e:setNetworkChanged( "active" )
    end
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
    e.camera:lookAt( e:getPos() )
    e.camera.x = 0
    e.camera.y = 0
end

local deinit = function( e )
end

local Camera = {
    __name = "Camera",
    camera = game.camera( 0, 0 ),
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
