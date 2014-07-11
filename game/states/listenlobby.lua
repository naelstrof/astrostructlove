local ListenLobby = {
    knownplayers = 0,
    port = 27020,
    server = nil
}

function ListenLobby:enter()
    game.network:startLobby( port )
    -- Add ourselves
    game.network:addPlayer( 0 )
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
    self.playerlist:SetSpacing( 4 )

    local button = loveframes.Create( "button", self.frame )
    button:SetPos( 32, 512-24 )
    button:SetText( "Start Game" )
    button.OnClick = function( object )
        game.network:startGame()
        game.gamestate.switch( gamestates.listenserver )
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
    local text = loveframes.Create( "text", self.playerlist )
    text:SetText( playerdata.id )
    self.playerlist:AddItem( text )
end

function ListenLobby:update( dt )
    game.network:update( dt )
    if self.knownplayers ~= game.network.playercount then
        self.playerlist:Clear()
        for i,v in pairs( game.network.players ) do
            self:listPlayer( v )
        end
        self.knownplayers = game.network.playercount
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
