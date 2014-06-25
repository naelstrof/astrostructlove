local ListenServer = {}

function ListenServer:enter()
    game.renderer:setFullbright( true )
    game.demosystem:play( "test.txt" )
end

function ListenServer:leave()
end

function ListenServer:draw()
    game.renderer:draw()
end

function ListenServer:update( dt )
    game.demosystem:update( dt )
    game.controlsystem:update( dt )
    game.starsystem:update( dt )
    game.renderer:update( dt )
end

function ListenServer:mousepressed( x, y, button )
end

function ListenServer:mousereleased( x, y, button )
end

function ListenServer:keypressed( key, unicode )
    if key == "f" then
        game.renderer:toggleFullbright()
    end
end

function ListenServer:keyreleased( key )
end

function ListenServer:textinput( text )
end

function ListenServer:resize( w, h )
    game.renderer:resize( w, h )
end

return ListenServer
