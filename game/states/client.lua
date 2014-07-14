local Client = {
    ip = "50.77.44.41",
    port = 27020,
}

function Client:enter()
end

function Client:leave()
    game.client:stop()
end

function Client:draw()
    game.renderer:draw()
end

function Client:update( dt )
    game.bindsystem:update( dt )
    game.client:update( dt )
    game.demosystem:update( dt )
end

function Client:mousepressed( x, y, button )
end

function Client:mousereleased( x, y, button )
end

function Client:keypressed( key, unicode )
end

function Client:keyreleased( key )
end

function Client:textinput( text )
end

function Client:resize( w, h )
    game.renderer:resize( w, h )
    game.entities:resize( w, h )
end

return Client
