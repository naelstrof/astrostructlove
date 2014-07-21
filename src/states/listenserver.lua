local ListenServer = {
    playercount = 1,
    port = 27020,
    server = nil
}

function ListenServer:enter()
end

function ListenServer:leave()
    loveframes.util:RemoveAll()
end

function ListenServer:draw()
    Renderer:draw()
    loveframes.draw()
end

function ListenServer:update( dt )
    BindSystem:update( dt )
    Network:updateClient( 0, BindSystem.getControls(), Network:getTick() )
    -- World:update( dt, Network:getTick() )
    DemoSystem:update( dt )
    Network:update( dt )
    loveframes.update( dt )
end

function ListenServer:mousepressed( x, y, button )
    loveframes.mousepressed( x, y, button )
end

function ListenServer:mousereleased( x, y, button )
    loveframes.mousereleased( x, y, button )
end

function ListenServer:keypressed( key, unicode )
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
                State.listenserver.gamemenu:Remove()
                State.listenserver.gamemenu = nil
            end
            local quitbutton = loveframes.Create( "button", self.gamemenu )
            quitbutton:SetText( "Quit" )
            quitbutton:SetPos( 128 - quitbutton:GetWidth()/2, 128 + quitbutton:GetHeight()/2 )
            quitbutton.OnClick = function( object, x, y )
                Network:stop()
                StateMachine.switch( State.menu )
            end
        end
    end
    loveframes.keypressed( key, unicode )
end

function ListenServer:keyreleased( key )
    loveframes.keyreleased( key )
end

function ListenServer:textinput( text )
    loveframes.textinput( text )
end

function ListenServer:resize( w, h )
    Renderer:resize( w, h )
    World:resize( w, h )
end

return ListenServer
