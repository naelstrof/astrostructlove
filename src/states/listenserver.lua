local ListenServer = {
    playercount = 1,
    port = 27020,
    server = nil
}

function ListenServer:enter()
end

function ListenServer:leave()
    self.network:stop()
    self.server:disconnect()
    loveframes.util:RemoveAll()
end

function ListenServer:draw()
    Renderer:draw()
    loveframes.draw()
end

function ListenServer:update( dt )
    BindSystem:update( dt )
    Network:updateClient( 0, BindSystem.getControls(), Network:getTick() )
    -- World:update( dt, Network:getTick() )
    DemoSystem:update( dt )
    Network:update( dt )
    loveframes.update( dt )
end

function ListenServer:mousepressed( x, y, button )
    loveframes.mousepressed( x, y, button )
end

function ListenServer:mousereleased( x, y, button )
    loveframes.mousereleased( x, y, button )
end

function ListenServer:keypressed( key, unicode )
    loveframes.keypressed( key, unicode )
end

function ListenServer:keyreleased( key )
    loveframes.keyreleased( key )
end

function ListenServer:textinput( text )
    loveframes.textinput( text )
end

function ListenServer:resize( w, h )
    Renderer:resize( w, h )
    World:resize( w, h )
end

return ListenServer
