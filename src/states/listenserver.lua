local ListenServer = {
    time = 0,
    textremovaltime = 8,
    text = {},
    playercount = 1,
    port = 27020,
    server = nil
}

function ListenServer:enter()
    Network.onTextReceive = function( textarray )
        if #State.listenserver.text == 0 then
            State.listenserver.time = 0
        end
        for i,v in pairs( textarray ) do
            for o,w in pairs( State.listenserver.text ) do
                local x, y = w:GetPos()
                w:SetPos( x, y - w:GetHeight() )
            end
            local text = loveframes.Create( "text" )
            text:SetShadowColor( 155, 155, 155, 255 )
            text:SetShadow( true )
            text:SetDefaultColor( 20, 20, 20, 255 )
            text:SetText( v )
            text:SetPos( 0, love.graphics.getHeight() - text:GetHeight()*4 )
            table.insert( State.listenserver.text, text )
        end
    end
end

function ListenServer:leave()
    loveframes.util:RemoveAll()
end

function ListenServer:draw()
    Renderer:draw()
    loveframes.draw()
end

function ListenServer:update( dt )
    self.time = self.time + dt
    if self.time > self.textremovaltime then
        if #self.text > 0 then
            self.text[ 1 ]:Remove()
            table.remove( self.text, 1 )
        end
        self.time = 0
    end
    BindSystem:update( dt )
    Network:updateClient( 0, BindSystem:getControls(), Network:getTick() )
    -- World:update( dt, Network:getTick() )
    DemoSystem:update( dt )
    Network:update( dt )
    if self.playerlist then
        for i,v in pairs( self.playerlist.players ) do
            if Network.players[ i ] then
                local ping = Network.players[ i ].ping or "Unknown"
                local name = Network.players[ i ].name or "Unknown"
                v:SetText( name .. " Ping: " .. ping )
            end
        end
    end
    loveframes.update( dt )
end

function ListenServer:mousepressed( x, y, button )
    loveframes.mousepressed( x, y, button )
end

function ListenServer:mousereleased( x, y, button )
    loveframes.mousereleased( x, y, button )
end

function ListenServer:keypressed( key, unicode )
    loveframes.keypressed( key, unicode )
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
    elseif key == "tab" then
        if not self.playerlist then
            self.playerlist = loveframes.Create( "frame" )
            self.playerlist:SetWidth( 256 )
            self.playerlist:SetHeight( 256 )
            self.playerlist:SetName( "Player List" )
            self.playerlist:ShowCloseButton( false )
            self.playerlist:Center()
            self.playerlist.players = {}
            local list = loveframes.Create( "list", self.playerlist )
            list:SetPos( 5, 24+5 )
            list:SetWidth( 256 - 10 )
            list:SetHeight( 256 - 24 - 10 )
            list:SetPadding( 5 )
            list:SetSpacing( 16 )
            for i,v in pairs( Network.players ) do
                local text = loveframes.Create( "imagebutton", list )
                v.ping = v.ping or "Unknown"
                v.name = v.name or "Unknown"
                text:SetText( v.name .. " Ping: " .. v.ping )
                if v.avatar then
                    local filename = Downloader.download( v.avatar )
                    text:SetImage( filename )
                    if text:GetImageWidth() > 128 or text:GetImageHeight() > 128 then
                        text:SetImage( nil )
                    end
                end
                self.playerlist.players[ v.id ] = text
                list:AddItem( text )
            end
        end
    elseif key == "return" then
        if not self.chatinput and not self.chatting then
            self.chatting = true
            BindSystem:toggleInput()
            self.chatinput = loveframes.Create( "textinput" )
            self.chatinput:SetPos( 0, love.graphics.getHeight()-self.chatinput:GetHeight() )
            self.chatinput:SetFocus( true )
            self.chatinput:SetWidth( 256 )
            self.chatinput.OnEnter = function( object, text )
                if object:GetText() ~= "" then
                    Network:addChatText( 0, object:GetText() )
                end
                State.listenserver.chatinput:Remove()
                State.listenserver.chatinput = nil
                BindSystem:toggleInput()
            end
        elseif self.chatting then
            self.chatting = false
        end
    end
end

function ListenServer:keyreleased( key )
    if key == "tab" and self.playerlist then
        self.playerlist:Remove()
        self.playerlist = nil
    end
    loveframes.keyreleased( key )
end

function ListenServer:textinput( text )
    loveframes.textinput( text )
end

function ListenServer:resize( w, h )
    Renderer:resize( w, h )
    World:resize( w, h )
    if self.chatinput then
        self.chatinput:SetPos( 0, love.graphics.getHeight()-self.chatinput:GetHeight() )
    end
end

return ListenServer
