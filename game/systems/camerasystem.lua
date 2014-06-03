local CameraSystem = love.class( { activecamera = nil } )

function CameraSystem:setActive( e )
    if e:hasComponent( compo.camera ) then
        self.activecamera = e
    end
end

function CameraSystem:getActive()
    return self.activecamera
end

function CameraSystem:getWorldMouse()
    return self.activecamera:toWorld( game.vector( love.mouse.getX(), love.mouse.getY() ) )
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
