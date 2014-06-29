local Playback = {
    demoname = "test"
}

function Playback:enter()
    local back = loveframes.Create( "button" )
    back:SetPos( 2, 2 )
    back:SetText( "Back" )
    back.OnClick = function( object )
        game.gamestate.switch( gamestates.menu )
    end
    game.renderer:setFullbright( true )
    game.demosystem:play( self.demoname )
end

function Playback:leave()
    game.demosystem:stop()
    game.entities:removeAll()
    loveframes.util:RemoveAll()
end

function Playback:draw()
    game.renderer:draw()
    loveframes.draw()
end

function Playback:update( dt )
    -- We don't update game.bindsystem since you shouldn't be able to
    -- move anything in the demo
    game.entities:update( dt )
    game.demosystem:update( dt )
    game.renderer:update( dt )
    loveframes.update( dt )
end

function Playback:mousepressed( x, y, button )
    loveframes.mousepressed( x, y, button )
end

function Playback:mousereleased( x, y, button )
    loveframes.mousereleased( x, y, button )
end

function Playback:keypressed( key, unicode )
    if key == "f" then
        game.renderer:toggleFullbright()
    end
    loveframes.keypressed( key, unicode )
end

function Playback:keyreleased( key )
    loveframes.keypressed( key, unicode )
end

function Playback:textinput( text )
    loveframes.textinput( text )
end

function Playback:resize( w, h )
    game.renderer:resize( w, h )
    game.entities:resize( w, h )
end

return Playback
