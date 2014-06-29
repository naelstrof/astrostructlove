local ListenServer = {
    playercount = 1,
    port = 27020,
    server = nil
}

function ListenServer:enter()
    game.mapsystem:load( game.gamemode.map )
    -- game.renderer:setFullbright( true )
    -- Spawn ourselves in
    game.gamemode:spawnPlayer( 0 )
    -- Set up the server
    self.server = lube.server( self.port )
    self.server:setCallback( self.onReceive, self.onConnect, self.onDisconnect )
    self.server:setHandshake( game.version )
end

function ListenServer:onConnect( ip, port )
    print( "Got a connection from " .. ip .. " on port " .. tostring( port ) )
    local player = game.gamemode:spawnPlayer( self.playercount )
    self.playercount = self.playercount + 1
    game.network:addPlayer( ip, player )
end

function ListenServer:onReceive( data, ip, port )
    print( "Recieved data " .. data .. " from " .. ip )
    local t = Tserial:unpack( data )
    game.network:updateClient( ip, t.controls, t.lastsnapshot )
end

function ListenServer:onDisconnect( ip, port )
    print( ip .. " disconnected..." )
    game.network:removePlayer( ip )
end

function ListenServer:leave()
    self.server:disconnect()
end

function ListenServer:draw()
    game.renderer:draw()
end

function ListenServer:update( dt )
    game.network:sendUpdates( dt )
    self.server:update( dt )
    game.entities:update( dt )
    game.demosystem:update( dt )
    game.renderer:update( dt )
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
