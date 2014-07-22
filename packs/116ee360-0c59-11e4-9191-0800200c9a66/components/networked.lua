local Networked = {
    __name = "Networked"
}

function Networked:init()
    -- We need to be able to give the entity a specified ID
    -- Useful for networking
    if self.demoIndex ~= nil then
        DemoSystem:addEntity( self, self.demoIndex )
    else
        DemoSystem:addEntity( self )
    end
end

function Networked:deinit()
    DemoSystem:removeEntity( self )
end

return Networked
