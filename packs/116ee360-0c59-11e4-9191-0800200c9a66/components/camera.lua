-- CameraComponent component allows an entity to control the view
local CameraComponent = {
    __name = "CameraComponent",
    camera = nil,
    zoom = 1,
    active = false,
    networkinfo = {
        setZoom = "zoom"
    }
}

function CameraComponent:setPos( t )
    self.camera:lookAt( t.x, t.y )
end

function CameraComponent:setRot( rot )
    self.camera:rotateTo( -rot )
end

function CameraComponent:setZoom( zoom )
    self.zoom = zoom
    self.camera:zoomTo( zoom )
end

function CameraComponent:Zoom( zoom )
    self.zoom = self.zoom * zoom
    self.camera:zoom( zoom )
end

function CameraComponent:getZoom()
    return self.zoom
end

function CameraComponent:setLocalPlayer( bool )
    if bool then
        CameraSystem:setActive( self )
    end
end

function CameraComponent:toWorld( pos )
    local x,y = self.camera:worldCoords( pos.x, pos.y )
    return Vector( x, y )
end

function CameraComponent:init()
    self.camera = Camera()
    self.camera:lookAt( self:getPos().x, self:getPos().y )
    self.camera:zoomTo( self.zoom )
    self.camera:rotateTo( -self.rot )
    if self:hasComponent( Components.controllable ) then
        if self:isLocalPlayer() then
            CameraSystem:setActive( self )
        end
    end
end

return CameraComponent
