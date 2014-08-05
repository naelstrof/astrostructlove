-- CameraComponent component allows an entity to control the view
local CameraComponent = {
    __name = "CameraComponent",
    camera = nil,
    zoom = 1,
    active = false,
    smooth = false,
    springstrength = 8,
    networkinfo = {
        setZoom = "zoom"
    }
}

function CameraComponent:setPos( t )
    if self.smooth then
        self.wantedposition = Vector( t.x, t.y )
    else
        self.camera:lookAt( t.x, t.y )
    end
end

function CameraComponent:setRot( rot )
    -- TODO: Make this smooth like the position
    self.camera:rotateTo( -rot )
end

function CameraComponent:setZoom( zoom )
    -- TODO: Ditto ^^^
    self.zoom = zoom
    self.camera:zoomTo( zoom )
end

function CameraComponent:Zoom( zoom )
    -- TODO: Ditto ^^^
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

function CameraComponent:update( dt )
    if not self.smooth then
        return
    end
    -- If we're smoothed out we move toward our wanted position via
    -- a spring constraint.
    local x, y = self.camera:pos()
    local campos = Vector( x, y )
    local dir = self.wantedposition - campos
    dir:normalize_inplace()
    local dist = self.wantedposition:dist( campos )
    campos = campos + ( dir * self.springstrength * dt * dist )
    self.camera:lookAt( campos.x, campos.y )
end

function CameraComponent:toWorld( pos )
    local x,y = self.camera:worldCoords( pos.x, pos.y )
    return Vector( x, y )
end

function CameraComponent:init()
    self.camera = Camera()
    if self.smooth then
        self.wantedposition = Vector( self:getPos().x, self:getPos().y )
        self.camera:lookAt( self.wantedposition.x, self.wantedposition.y )
    else
        self.camera:lookAt( self:getPos().x, self:getPos().y )
    end
    self.camera:zoomTo( self.zoom )
    self.camera:rotateTo( -self.rot )
    if self:hasComponent( Components.controllable ) then
        if self:isLocalPlayer() then
            CameraSystem:setActive( self )
        end
    end
end

return CameraComponent
