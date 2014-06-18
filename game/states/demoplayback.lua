local Playback = {}

function Playback:enter()
    game.demosystem:play( "test.bin" )
end

function Playback:leave()
end

function Playback:draw()
    game.renderer:draw()
end

function Playback:update( dt )
    game.controlsystem:update( dt )
    game.starsystem:update( dt )
    game.renderer:update( dt )
    game.demosystem:update( dt )
end

function Playback:mousepressed( x, y, button )
end

function Playback:mousereleased( x, y, button )
end

function Playback:keypressed( key, unicode )
end

function Playback:keyreleased( key )
end

function Playback:textinput( text )
end

function Playback:resize( w, h )
end

return Playback
