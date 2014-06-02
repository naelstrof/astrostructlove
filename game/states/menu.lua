local Menu = {}

function Menu:enter()
    frame = loveframes.Create( "frame" ):SetName( "Main Menu" ):Center():ShowCloseButton( false )
    play = loveframes.Create( "button", frame ):CenterX():SetY( 40 ):SetText( "Play" )
    options = loveframes.Create( "button", frame ):CenterX():SetY( 70 ):SetText( "Options" )
    quit = loveframes.Create( "button", frame ):CenterX():SetY( 100 ):SetText( "Quit" )
    play.OnClick = function( object, x, y )
        game.gamestate.switch( gamestates.game )
    end
    options.OnClick = function( object, x, y )
        game.gamestate.switch( gamestates.options )
    end
    quit.OnClick = function( object, x, y )
        love.event.quit()
    end
end

function Menu:leave()
    frame:Remove()
    options:Remove()
    play:Remove()
end

function Menu:draw()
    loveframes.draw()
end

function Menu:update( dt )
    loveframes.update( dt )
end

function Menu:mousepressed( x, y, button )
    loveframes.mousepressed( x, y, button )
end

function Menu:mousereleased( x, y, button )
    loveframes.mousereleased( x, y, button )
end

function Menu:keypressed( key, unicode )
    loveframes.keypressed( key, unicode )
end

function Menu:keyreleased( key )
    loveframes.keyreleased( key )
end

function Menu:textinput( text )
    loveframes.textinput( text )
end

function Menu:resize( w, h )
    frame:Center()
end

return Menu
