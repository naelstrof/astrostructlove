local CameraSystem = Class( { activecamera = nil } )

function CameraSystem:setActive( e )
    if e:hasComponent( Components.camera ) then
        self.activecamera = e
    end
end

function CameraSystem:getActive()
    return self.activecamera
end

function CameraSystem:getWorldMouse()
    return self.activecamera:toWorld( Vector( love.mouse.getX(), love.mouse.getY() ) )
end

function CameraSystem:getPos()
    if self.activecamera == nil then
        return Vector( 0, 0 )
    end
    return self.activecamera:getPos()
end

function CameraSystem:attach()
    if self.activecamera ~= nil then
        self.activecamera.camera:attach()
    end
end

function CameraSystem:detach()
    if self.activecamera ~= nil then
        self.activecamera.camera:detach()
    end
end

return CameraSystem
