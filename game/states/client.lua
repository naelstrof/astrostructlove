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
    loveframes.draw()
end

function Client:update( dt )
    game.bindsystem:update( dt )
    game.client:update( dt )
    game.demosystem:update( dt )
    loveframes.update( dt )
end

function Client:mousepressed( x, y, button )
    loveframes.mousepressed( x, y, button )
end

function Client:mousereleased( x, y, button )
    loveframes.mousereleased( x, y, button )
end

function Client:keypressed( key, unicode )
    loveframes.keypressed( key, unicode )
end

function Client:keyreleased( key )
    loveframes.keyreleased( key )
end

function Client:textinput( text )
    loveframes.textinput( text )
end

function Client:resize( w, h )
    game.renderer:resize( w, h )
    game.entities:resize( w, h )
end

return Client
