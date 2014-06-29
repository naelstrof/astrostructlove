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
end

function Singleplayer:update( dt )
    game.bindsystem:update( dt )
    game.demosystem:update( dt )
    game.controlsystem:update( dt )
    game.starsystem:update( dt )
    game.renderer:update( dt )
end

function Singleplayer:mousepressed( x, y, button )
end

function Singleplayer:mousereleased( x, y, button )
end

function Singleplayer:keypressed( key, unicode )
end

function Singleplayer:keyreleased( key )
end

function Singleplayer:textinput( text )
end

function Singleplayer:resize( w, h )
    game.renderer:resize( w, h )
end

return Singleplayer
