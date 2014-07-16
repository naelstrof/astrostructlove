local init = function( e )
    -- We need to be able to give the entity a specified ID
    -- Useful for networking
    if e.demoIndex ~= nil then
        DemoSystem:addEntity( e, e.demoIndex )
    else
        DemoSystem:addEntity( e )
    end
end

local deinit = function( e )
    DemoSystem:removeEntity( e )
end

local Networked = {
    __name = "Networked",
    init = init,
    deinit = deinit
}

return Networked
