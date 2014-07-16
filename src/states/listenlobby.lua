local ListenLobby = {
    timer = 0,
    knownplayers = 0,
    port = 27020,
    server = nil
}

function ListenLobby:enter()
    Network:startLobby( port )
    -- Add ourselves
    Network:addPlayer( 0 )
    self.frame = loveframes.Create( "frame" )
    self.frame:SetName( "Game Lobby" )
    self.frame:ShowCloseButton( false )
    self.frame:SetHeight( 512 )
    self.frame:SetWidth( 512 )
    self.frame:Center()

    local container = loveframes.Create( "frame", self.frame )
    container:SetName( "Connected Players" )
    container:ShowCloseButton( false )
    container:SetPos( 256, 26 )
    container:SetHeight( 486 - 4 )
    container:SetWidth( 256 - 4 )
    container:SetDraggable( false )
    self.playerlist = loveframes.Create( "list", container )
    self.playerlist:SetPos( 0, 26 )
    self.playerlist:SetHeight( 460 - 4 )
    self.playerlist:SetWidth( 256 - 4 )
    self.playerlist:SetPadding( 4 )
    self.playerlist:SetSpacing( 16 )

    local button = loveframes.Create( "button", self.frame )
    button:SetPos( 64, 512-68 )
    button:SetWidth( 128 )
    button:SetHeight( 64 )
    button:SetText( "Start Game" )
    button.OnClick = function( object )
        StateMachine.switch( State.listenserver )
        Network:startGame()
    end
end

function ListenLobby:leave()
    loveframes.util:RemoveAll()
    -- We shouldn't stop the server if we're moving to the gamestate
    -- self.network:stop()
end

function ListenLobby:draw()
    loveframes.draw()
end

function ListenLobby:listPlayer( playerdata )
    local text = loveframes.Create( "imagebutton", self.playerlist )
    playerdata.ping = playerdata.ping or "Unknown"
    if playerdata.name then
        text:SetText( playerdata.name .. " Ping: " .. playerdata.ping )
    else
        text:SetText( playerdata.name .. " Ping: " .. playerdata.ping )
    end
    if playerdata.avatar then
        local filename = Downloader.download( playerdata.avatar )
        text:SetImage( filename )
        if text:GetImageWidth() > 128 or text:GetImageHeight() > 128 then
            text:SetImage( nil )
        end
    end
    self.playerlist:AddItem( text )
end

function ListenLobby:update( dt )
    self.timer = self.timer + dt
    -- We want to update the player list every second
    if self.timer > 1 then
        self.knownplayers = 0
    end
    Network:update( dt )
    if self.knownplayers ~= Network.playercount then
        self.playerlist:Clear()
        for i,v in pairs( Network.players ) do
            self:listPlayer( v )
        end
        self.knownplayers = Network.playercount
    end
    loveframes.update( dt )
end

function ListenLobby:mousepressed( x, y, button )
    loveframes.mousepressed( x, y, button )
end

function ListenLobby:mousereleased( x, y, button )
    loveframes.mousereleased( x, y, button )
end

function ListenLobby:keypressed( key, unicode )
    loveframes.keypressed( key, unicode )
end

function ListenLobby:keyreleased( key )
    loveframes.keyreleased( key )
end

function ListenLobby:textinput( text )
    loveframes.textinput( text )
end

function ListenLobby:resize( w, h )
    self.frame:Center()
end

return ListenLobby
