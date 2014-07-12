local ListenServer = {
    playercount = 1,
    port = 27020,
    server = nil
}

function ListenServer:enter()
end

function ListenServer.onConnect( id )
    print( "Got a connection from " .. id )
    local player = game.gamemode:spawnPlayer( id )
    gamestates.listenserver.playercount = gamestates.listenserver.playercount + 1
end

function ListenServer.onReceive( data, id )
    local t = Tserial.unpack( data )
    game.network:updateClient( id, t.control, t.tick )
end

function ListenServer.onDisconnect( id )
    print( id .. " disconnected..." )
    game.network:removePlayer( id )
end

function ListenServer:leave()
    self.network:stop()
    self.server:disconnect()
end

function ListenServer:draw()
    game.renderer:draw()
end

function ListenServer:update( dt )
    game.bindsystem:update( dt )
    game.network:updateClient( 0, game.bindsystem.getControls(), game.network:getTick() )
    -- game.entities:update( dt, game.network:getTick() )
    game.demosystem:update( dt )
    game.network:update( dt )
end

function ListenServer:mousepressed( x, y, button )
end

function ListenServer:mousereleased( x, y, button )
end

function ListenServer:keypressed( key, unicode )
end

function ListenServer:keyreleased( key )
end

function ListenServer:textinput( text )
end

function ListenServer:resize( w, h )
    game.renderer:resize( w, h )
    game.entities:resize( w, h )
end

return ListenServer
