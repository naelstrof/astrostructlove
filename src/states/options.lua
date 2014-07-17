local Options = {}

function Options:enter()
    frame = loveframes.Create( "frame" ):SetName( "Options" ):Center():ShowCloseButton( false )
    
    fullscreen = loveframes.Create( "checkbox", frame ):SetText( "Fullscreen" ):SetPos(200, 37)
    setName = loveframes.Create( "textinput", frame ):SetPlaceholderText( "Enter Name" ):SetPos(10, 75)
    setAvatar = loveframes.Create( "textinput", frame ):SetPlaceholderText( "Enter Avatar URL" ):SetPos(10, 105)
    setNameButton = loveframes.Create( "button", frame ):SetText( "Set Name" ):SetPos(215, 75)
    setAvatarButton = loveframes.Create( "button", frame ):SetText( "Set Avatar" ):SetPos(215, 105)
    
    local width, height, flags = love.window.getMode()
    fullscreen:SetChecked( flags.fullscreen )
    
    back = loveframes.Create( "button", frame ):SetText( "Back" ):SetPos( 10, 35 )
    back.OnClick = function()
      StateMachine.switch( State.menu )
    end
    
    setNameButton.OnClick = function()
      SystemOptions.options.playername = setName:GetText()
     --print("Name: " .. SystemOptions["playername"])

      SystemOptions:save()
    end
    
    setAvatarButton.OnClick = function()
      SystemOptions.options.playeravatar = setAvatar:GetText()
      SystemOptions:save()
    end
      
end

function Options:leave()
    frame:Remove()
    fullscreen:Remove()
    back:Remove()
end

function Options:draw()
    loveframes.draw()
end

function Options:update( dt )
    loveframes.update( dt )
    local checked = fullscreen:GetChecked()
    local width, height, flags = love.window.getMode()
    if flags.fullscreen ~= checked then
        flags.fullscreen = checked
        flags.fullscreentype = "desktop"
        love.window.setMode( width, height, flags )
    end
end

function Options:mousepressed( x, y, button )
    loveframes.mousepressed( x, y, button )
end

function Options:mousereleased( x, y, button )
    loveframes.mousereleased( x, y, button )
end

function Options:keypressed( key, unicode )
    loveframes.keypressed( key, unicode )
end

function Options:keyreleased( key )
    loveframes.keyreleased( key )
end

function Options:textinput( text )
    loveframes.textinput( text )
end

function Options:resize( w, h )
    frame:Center()
end

return Options
