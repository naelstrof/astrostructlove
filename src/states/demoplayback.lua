local Playback = {
    demoname = "test"
}

function Playback:enter()
    local back = loveframes.Create( "button" )
    back:SetPos( 2, 2 )
    back:SetText( "Back" )
    back.OnClick = function( object )
        StateMachine.switch( State.menu )
    end
    Renderer:setFullbright( true )
    DemoSystem:play( self.demoname )
end

function Playback:leave()
    DemoSystem:stop()
    World:removeAll()
    loveframes.util:RemoveAll()
end

function Playback:draw()
    Renderer:draw()
    loveframes.draw()
end

function Playback:update( dt )
    -- We don't update BindSystem since you shouldn't be able to
    -- move anything in the demo
    World:update( dt )
    DemoSystem:update( dt )
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
        Renderer:toggleFullbright()
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
    Renderer:resize( w, h )
    World:resize( w, h )
end

return Playback
