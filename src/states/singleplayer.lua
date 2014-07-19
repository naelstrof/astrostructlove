local Singleplayer = {
    tick = 0,
    player = nil
}

function Singleplayer:enter()
    MapSystem:load( Gamemode.map )
    -- Spawn ourselves in
    self.player = Gamemode:spawnPlayer( { playerid = 0, localplayer = true } )
end

function Singleplayer:leave()
end

function Singleplayer:draw()
    Renderer:draw()
    loveframes.draw()
end

function Singleplayer:update( dt )
    BindSystem:update( dt )
    -- Despite being in single player, we still rely on knowing our
    -- past... So we must keep track of a tick rate.
    self.player:addControlSnapshot( BindSystem.getControls(), self.tick )
    World:update( dt, self.tick )
    DemoSystem:update( dt )
    loveframes.update( dt )
    self.tick = self.tick + 1
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
    Renderer:resize( w, h )
    World:resize( w, h )
end

return Singleplayer
