local ClientLobby = {
    ip = "50.77.44.41",
    port = 27020,
    client = nil
}

function ClientLobby:enter()
    ClientSystem:startLobby( self.ip, self.port )
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

    local quit = loveframes.Create( "button", self.frame )
    quit:SetPos( 5, 512-69 )
    quit:SetWidth( 247 )
    quit:SetHeight( 64 )
    quit:SetText( "Quit" )
    quit.OnClick = function( object )
        ClientSystem:stop()
        StateMachine.switch( State.menu )
    end
end

function ClientLobby:clearPlayers()
    self.playerlist:Clear()
end

function ClientLobby:listPlayer( playerdata )
    local text = loveframes.Create( "imagebutton", self.playerlist )
    playerdata.ping = playerdata.ping or "Unknown"
    if playerdata.name then
        text:SetText( playerdata.name )
    else
        text:SetText( "Nobody" )
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

function ClientLobby:leave()
    loveframes.util:RemoveAll()
    -- shouldn't disconnect the client in case we switch to the gamestate
    -- self.client:disconnect()
end

function ClientLobby:draw()
    loveframes.draw()
end

function ClientLobby:update( dt )
    ClientSystem:update( dt )
    loveframes.update( dt )
end

function ClientLobby:mousepressed( x, y, button )
    loveframes.mousepressed( x, y, button )
end

function ClientLobby:mousereleased( x, y, button )
    loveframes.mousereleased( x, y, button )
end

function ClientLobby:keypressed( key, unicode )
    loveframes.keypressed( key, unicode )
end

function ClientLobby:keyreleased( key )
    loveframes.keyreleased( key )
end

function ClientLobby:textinput( text )
    loveframes.textinput( text )
end

function ClientLobby:resize( w, h )
    Renderer:resize( w, h )
    World:resize( w, h )
end

return ClientLobby
