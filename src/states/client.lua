local Client = {
    ip = "50.77.44.41",
    port = 27020,
}

function Client:enter()
end

function Client:leave()
    -- ClientSystem:stop()
    loveframes.util:RemoveAll()
end

function Client:draw()
    Renderer:draw()
    loveframes.draw()
end

function Client:update( dt )
    BindSystem:update( dt )
    ClientSystem:update( dt )
    DemoSystem:update( dt )
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
    Renderer:resize( w, h )
    World:resize( w, h )
end

return Client
