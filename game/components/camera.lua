local Camera = compo.component:extends()

function Camera:init( e )
    e.camera = game.camera( e.pos.x, e.pos.y )
    e.zoom = 1

    -- Override setPos and setRot to affect the actual camera object as well
    -- Make sure to chain the original function so that everything gets called
    e.setPosCameraBackup = e.setPos
    e.setPos = function( e, pos )
        e:setPosCameraBackup( pos )
        e.camera:lookAt( pos:unpack() )
    end

    e.setRotCameraBackup = e.setRot
    e.setRot = function( e, rot )
        e:setRotCameraBackup( rot )
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
    e.setPos = e.setPosCameraBackup
    e.setRot = e.setRotCameraBackup
    e.setPosCameraBackup = nil
    e.setRotCameraBackup = nil
    e.camera = nil
    e.zoom = nil
end

return Camera
