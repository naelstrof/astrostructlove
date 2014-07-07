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
    self.client:connect( self.ip, self.port )
end

function Client.onReceive( data )
    print( data )
    local t = Tserial.unpack( data )
    if t.map then
        game.mapsystem:load( t.map )
    end
    if t.clientid then
        game.client:setID( t.clientid )
    end
    if not game.client.running then
        game.client:start( t, gamestates.client.client )
    else
        game.client:addSnapshot( t )
    end
end

function Client:leave()
    self.client:disconnect()
    game.client:stop()
end

function Client:draw()
    game.renderer:draw()
end

function Client:update( dt )
    game.bindsystem:update( dt )
    game.entities:update( dt )
    self.client:update( dt )
    game.client:update( dt )
    game.demosystem:update( dt )
    game.renderer:update( dt )
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
