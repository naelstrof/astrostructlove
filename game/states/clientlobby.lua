local Client = {
    ip = "50.77.44.41",
    port = 27020,
    client = nil
}

function Client:enter()
    game.client:startLobby( self.ip, self.port )
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
    container:SetHeight( 486 )
    container:SetWidth( 256 )
    container:SetDraggable( false )
    self.playerlist = loveframes.Create( "list", container )
    self.playerlist:SetPos( 0, 26 )
    self.playerlist:SetHeight( 460 )
    self.playerlist:SetWidth( 256 )
    self.playerlist:SetPadding( 4 )
    self.playerlist:SetSpacing( 16 )
end

function Client:clearPlayers()
    self.playerlist:Clear()
end

function Client:listPlayer( playerdata )
    local text = loveframes.Create( "imagebutton", self.playerlist )
    playerdata.ping = playerdata.ping or "Unknown"
    if playerdata.name then
        text:SetText( playerdata.name .. " Ping: " .. playerdata.ping )
    else
        text:SetText( playerdata.name .. " Ping: " .. playerdata.ping )
    end
    if playerdata.avatar then
        local filename = game.downloader.download( playerdata.avatar )
        text:SetImage( filename )
        if text:GetImageWidth() > 128 or text:GetImageHeight() > 128 then
            text:SetImage( nil )
        end
    end
    self.playerlist:AddItem( text )
end

function Client:leave()
    loveframes.util:RemoveAll()
    -- shouldn't disconnect the client in case we switch to the gamestate
    -- self.client:disconnect()
end

function Client:draw()
    loveframes.draw()
end

function Client:update( dt )
    game.client:update( dt )
    loveframes.update( dt )
end

function Client:mousepressed( x, y, button )
    loveframes.mousepressed( x, y, button )
end

function Client:mousereleased( x, y, button )
    loveframes.mousereleased( x, y, button )
end

function Client:keypressed( key, unicode )
    loveframes.keypressed( key, unicode )
end

function Client:keyreleased( key )
    loveframes.keyreleased( key )
end

function Client:textinput( text )
    loveframes.textinput( text )
end

function Client:resize( w, h )
    game.renderer:resize( w, h )
    game.entities:resize( w, h )
end

return Client
