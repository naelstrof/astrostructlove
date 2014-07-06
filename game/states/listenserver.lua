local ListenServer = {
    playercount = 1,
    port = 27020,
    server = nil
}

function ListenServer:enter()
    game.mapsystem:load( game.gamemode.map )
    -- game.renderer:setFullbright( true )
    -- Set up the server
    self.server = lube.udpServer()
    self.server:init()
    self.server.callbacks = { recv = self.onReceive, connect = self.onConnect, disconnect = self.onDisconnect }
    self.server.handshake = game.version
    self.server:listen( self.port )
    -- Start the server!
    game.network:start( self.server )
    -- Spawn ourselves in
    game.gamemode:spawnPlayer( 0 )
end

function ListenServer.onConnect( id )
    print( "Got a connection from " .. id )
    local player = game.gamemode:spawnPlayer( id )
    gamestates.listenserver.playercount = gamestates.listenserver.playercount + 1
end

function ListenServer.onReceive( data, id )
    print( "Recieved data " .. data .. " from " .. id )
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
    game.network:updateClient( 0, control.current, game.network:getTick() )
    game.entities:update( dt, game.network:getTick() )
    game.demosystem:update( dt )
    game.renderer:update( dt )
    game.network:update( dt )
    self.server:update( dt )
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
