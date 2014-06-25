local init = function( e )
    game.demosystem:addEntity( e )
end

local deinit = function( e )
    game.demosystem:removeEntity( e )
end

local Networked = {
    __name = "Networked",
    init = init,
    deinit = deinit
}

return Networked
