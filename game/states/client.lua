local Client = {
    ip = "50.77.44.41",
    port = 27020,
    client = nil
}

function Client:enter()
    self.client = lube.udpClient()
    self.client:init()
    self.client.callbacks = { recv = self.onReceive }
    self.client.handshake = game.version
    print( self.ip, self.port )
    self.client:connect( self.ip, self.port )
end

function Client.onReceive( data )
    print( "Recieved data " .. type( data ) .. " " .. data )
    --local t = Tserial:unpack( data )
end

function Client:leave()
    self.client:disconnect()
end

function Client:draw()
    game.renderer:draw()
end

function Client:update( dt )
    game.bindsystem:update( dt )
    game.entities:update( dt )
    game.demosystem:update( dt )
    game.renderer:update( dt )
    self.client:update( dt )
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
