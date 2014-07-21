local Client = {
    ip = "50.77.44.41",
    port = 27020,
}

function Client:enter()
end

function Client:leave()
    -- ClientSystem:stop()
    loveframes.util:RemoveAll()
end

function Client:draw()
    Renderer:draw()
    loveframes.draw()
end

function Client:update( dt )
    BindSystem:update( dt )
    ClientSystem:update( dt )
    DemoSystem:update( dt )
    loveframes.update( dt )
end

function Client:mousepressed( x, y, button )
    loveframes.mousepressed( x, y, button )
end

function Client:mousereleased( x, y, button )
    loveframes.mousereleased( x, y, button )
end

function Client:keypressed( key, unicode )
    if key == "escape" then
        if self.gamemenu then
            self.gamemenu:Remove()
            self.gamemenu = nil
        else
            self.gamemenu = loveframes.Create( "frame" )
            self.gamemenu:SetWidth( 256 )
            self.gamemenu:SetHeight( 256 )
            self.gamemenu:SetName( "Game Menu" )
            self.gamemenu:Center()
            local resumebutton = loveframes.Create( "button", self.gamemenu )
            resumebutton:SetText( "Resume" )
            resumebutton:SetPos( 128 - resumebutton:GetWidth()/2, 128 - resumebutton:GetHeight()/2 )
            resumebutton.OnClick = function( object, x, y )
                State.client.gamemenu:Remove()
                State.client.gamemenu = nil
            end
            local quitbutton = loveframes.Create( "button", self.gamemenu )
            quitbutton:SetText( "Quit" )
            quitbutton:SetPos( 128 - quitbutton:GetWidth()/2, 128 + quitbutton:GetHeight()/2 )
            quitbutton.OnClick = function( object, x, y )
                ClientSystem:stop()
                StateMachine.switch( State.menu )
            end
        end
    end
    loveframes.keypressed( key, unicode )
end

function Client:keyreleased( key )
    loveframes.keyreleased( key )
end

function Client:textinput( text )
    loveframes.textinput( text )
end

function Client:resize( w, h )
    Renderer:resize( w, h )
    World:resize( w, h )
end

return Client
