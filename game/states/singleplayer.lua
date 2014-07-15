local Singleplayer = {}

function Singleplayer:enter()
    game.mapsystem:load( game.gamemode.map )
    -- Spawn ourselves in
    game.gamemode:spawnPlayer( 0 )
end

function Singleplayer:leave()
end

function Singleplayer:draw()
    game.renderer:draw()
    loveframes.draw()
end

function Singleplayer:update( dt )
    game.bindsystem:update( dt )
    game.physics:update( dt )
    game.entities:update( dt )
    game.demosystem:update( dt )
    loveframes.update( dt )
end

function Singleplayer:mousepressed( x, y, button )
    loveframes.mousepressed( x, y, button )
end

function Singleplayer:mousereleased( x, y, button )
    loveframes.mousereleased( x, y, button )
end

function Singleplayer:keypressed( key, unicode )
    loveframes.keypressed( key, unicode )
end

function Singleplayer:keyreleased( key )
    loveframes.keyreleased( key )
end

function Singleplayer:textinput( text )
    loveframes.textinput( text )
end

function Singleplayer:resize( w, h )
    game.renderer:resize( w, h )
    game.entities:resize( w, h )
end

return Singleplayer
