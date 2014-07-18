local Options = {}

function Options:enter()
    self.frame = loveframes.Create( "frame" )
    self.frame:SetName( "Options" )
    self.frame:SetWidth( 512 )
    self.frame:SetHeight( 512 )
    self.frame:Center()
    self.frame:ShowCloseButton( false )

    local column1 = loveframes.Create( "text", self.frame )
    column1:SetText( "Option Name" )
    column1:SetPos( 15, 40 )

    local column2 = loveframes.Create( "text", self.frame )
    column2:SetText( "Option Value" )
    column2:SetPos( 512-column2:GetWidth()-15, 40 )

    local middle = loveframes.Create( "text", self.frame )
    middle:SetText( "Edit options to your liking" )
    middle:SetPos( 256-middle:GetWidth()/2, 40 )

    local list = loveframes.Create( "list", self.frame )
    list:SetSize( 512-10, 512-103 )
    list:SetPos( 5, 68 )
    list:SetPadding( 5 )
    list:SetSpacing( 5 )

    for i,v in pairs( OptionSystem.options ) do
        local t = type( v )
        local panel = loveframes.Create( "panel", list )
        panel:SetSize( 512-10-5, 40 )
        local text = loveframes.Create( "text", panel )
        text:SetPos( 5, 13 )
        text:SetText( tostring( i ) )
        if t == "string" then
            local edit = loveframes.Create( "textinput", panel )
            edit:SetWidth( 356 )
            edit:SetPos( 512-10-10-edit:GetWidth()-5, 7 )
            edit:SetText( v )
            edit.index = i
            edit.OnEnter = function( object, text )
                OptionSystem:setOption( object.index, object:GetText() )
            end
            edit.OnFocusLost = function( object )
                OptionSystem:setOption( object.index, object:GetText() )
            end
            edit.OnFocusGained = function( object )
                object:SelectAll()
            end
        elseif t == "boolean" then
            local edit = loveframes.Create( "checkbox", panel )
            edit:SetChecked( v )
            edit:SetPos( 512-40-edit:GetWidth()-5, 10 )
            edit.index = i
            edit.OnChanged = function( object, checked )
                OptionSystem:setOption( object.index, checked )
            end
        end
        list:AddItem( panel )
    end

    local cancel = loveframes.Create( "button", self.frame )
    cancel:SetText( "Cancel" )
    cancel:SetPos( 5, 512 - 30 )
    cancel.OnClick = function( object, x, y )
        --We have to reset everything if we canceled
        OptionSystem:load()
        StateMachine.switch( State.menu )
    end

    local save = loveframes.Create( "button", self.frame )
    save:SetText( "Save and Exit" )
    save:SetPos( 512 - save:GetWidth() - 5, 512 - 30 )
    save.OnClick = function( object, x, y )
        OptionSystem:save()
        StateMachine.switch( State.menu )
    end

end

function Options:leave()
    loveframes.util:RemoveAll()
end

function Options:draw()
    loveframes.draw()
end

function Options:update( dt )
    loveframes.update( dt )
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
    self.frame:Center()
end

return Options
