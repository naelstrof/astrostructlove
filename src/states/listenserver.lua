local ListenServer = {
    playercount = 1,
    port = 27020,
    server = nil
}

function ListenServer:enter()
end

function ListenServer.onConnect( id )
    print( "Got a connection from " .. id )
    local player = Gamemode:spawnPlayer( id )
    State.listenserver.playercount = State.listenserver.playercount + 1
end

function ListenServer.onReceive( data, id )
    local t = Tserial.unpack( data )
    Network:updateListenServer( id, t.control, t.tick )
end

function ListenServer.onDisconnect( id )
    print( id .. " disconnected..." )
    Network:removePlayer( id )
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
