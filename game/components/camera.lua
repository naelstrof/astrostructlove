local Camera = compo.component:extends()

function Camera:init( e )
    e.camera = game.camera( e.pos.x, e.pos.y )
    e.zoom = 1

    -- Override setPos and setRot to affect the actual camera object as well
    e.setPos = function( e, pos )
        e.pos = pos
        e.camera:lookAt( pos:unpack() )
    end

    e.setRot = function( e, rot )
        e.rot = rot
        e.camera:rotateTo( rot )
    end

    e.setZoom = function( e, zoom )
        e.zoom = zoom
        e.camera:zoomTo( zoom )
    end

    e.getZoom = function( e )
        return e.zoom
    end

    e.Zoom = function( e, zoom )
        e.zoom = e.zoom * zoom
        e.camera:zoom( zoom )
    end

    e.setLayer = function( e, l )
        game.renderer:removeEntity( e )
        e.layer = l
        game.renderer:addEntity( e )
    end

    e.getLayer = function( e )
        return e.layer
    end

    e.toWorld = function( e, pos )
        x,y = e.camera:worldCoords( pos.x, pos.y )
        return game.vector( x, y )
    end
end

function Camera:deinit( e )
    e.setZoom = nil
    e.getZoom = nil
    e.setLayer = nil
    e.getLayer = nil
    e.setPos = game.entity.setPos
    e.setRot = game.entity.setRot
    e.camera = nil
    e.zoom = nil
end

return Camera
