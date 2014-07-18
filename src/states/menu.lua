local Menu = {}

function Menu:enter()
    self.frame = loveframes.Create( "frame" )
    self.frame:SetName( "Main Menu" )
    self.frame:ShowCloseButton( false )
    self.frame:SetHeight( 250 )
    self.frame:Center()

    local list = loveframes.Create( "list", self.frame )
    list:SetPos( 0, 26 )
    list:SetHeight( 224 )
    list:SetPadding( 4 )
    list:SetSpacing( 4 )

    local join = loveframes.Create( "button", self.frame )
    join:SetText( "Join Server" )
    list:AddItem( join )

    local hostlisten = loveframes.Create( "button", self.frame )
    hostlisten:SetText( "Host Listen Server" )
    list:AddItem( hostlisten )

    local playsingle = loveframes.Create( "button", self.frame )
    playsingle:SetText( "Play Singleplayer" )
    list:AddItem( playsingle )

    local playdemo = loveframes.Create( "button", self.frame )
    playdemo:SetText( "Play Demo" )
    list:AddItem( playdemo )

    local mapeditor = loveframes.Create( "button", self.frame )
    mapeditor:SetText( "Map Editor" )
    list:AddItem( mapeditor )

    local options = loveframes.Create( "button", self.frame )
    options:SetText( "Options" )
    list:AddItem( options )

    local quit = loveframes.Create( "button", self.frame )
    quit:SetText( "Quit" )
    list:AddItem( quit )

    join.OnClick = function( object, x, y )
        self:createJoinBox()
    end
    hostlisten.OnClick = function( object, x, y )
        StateMachine.switch( State.listenlobby )
    end
    playsingle.OnClick = function( object, x, y )
        self:createPlaySingleplayerBox()
    end
    playdemo.OnClick = function( object, x, y )
        self:createPlayDemoBox()
    end
    mapeditor.OnClick = function( object, x, y )
        StateMachine.switch( State.mapeditor )
    end
    options.OnClick = function( object, x, y )
        StateMachine.switch( State.options )
    end
    quit.OnClick = function( object, x, y )
        love.event.quit()
    end
end

function Menu:createJoinBox()
    if self.playdemobox ~= nil then
        self.playdemobox:Remove()
    end
    self.playdemobox = loveframes.Create( "frame" )
    local frame = self.playdemobox
    frame:SetWidth( 256 )
    frame:SetHeight( 128 )
    frame:SetName( "Join Server ..." )
    frame:Center()

    local text = loveframes.Create( "textinput", frame )
    text:SetText( "50.77.44.41:27020" )
    text:Center()

    local button = loveframes.Create( "button", frame )
    button:CenterX()
    button:SetText( "Join" )
    button:SetY( 90 )
    button.txt = text

    button.OnClick = function( object, x, y )
        local text = object.txt:GetText()
        local ip, port = text:match("^(.-):(%d+)$")
        State.client.ip = ip
        State.client.port = tonumber( port )
        StateMachine.switch( State.clientlobby )
    end
end

function Menu:createPlayDemoBox()
    if self.playdemobox ~= nil then
        self.playdemobox:Remove()
    end
    self.playdemobox = loveframes.Create( "frame" )
    local frame = self.playdemobox
    frame:SetWidth( 128 )
    frame:SetHeight( 256 )
    frame:SetName( "Load Demo ..." )
    frame:Center()

    local list = loveframes.Create( "list", frame )
    list:SetPos( 4, 29 )
    list:SetSize( 120, 222 )
    list:SetPadding( 2 )
    list:SetSpacing( 2 )

    local files = love.filesystem.getDirectoryItems( "demos/" )
    local added = false
    for i, file in pairs( files ) do
        local button = loveframes.Create( "button" )
        button.file = string.sub( file, 1, -5 )
        button:SetText( button.file )
        button.OnClick = function( object )
            State.demoplayback.demoname = object.file
            StateMachine.switch( State.demoplayback )
        end
        added = true
        list:AddItem( button )
    end
    if not added then
        local text = loveframes.Create( "text", frame )
        text:SetText( "No demos found :(" )
        list:AddItem( text )
    end
end

function Menu:createPlaySingleplayerBox()
    if self.createsingleplayerbox ~= nil then
        self.createsingleplayerbox:Remove()
    end
    self.createsingleplayerbox = loveframes.Create( "frame" )
    local frame = self.createsingleplayerbox
    frame:SetWidth( 128 )
    frame:SetHeight( 256 )
    frame:SetName( "Load Gamemode ..." )
    frame:Center()

    local list = loveframes.Create( "list", frame )
    list:SetPos( 4, 29 )
    list:SetSize( 120, 222 )
    list:SetPadding( 2 )
    list:SetSpacing( 2 )

    local added = false
    for i, gamemode in pairs( Gamemode:getGamemodes() ) do
        local button = loveframes.Create( "button" )
        button.gamemode = gamemode
        button:SetText( button.gamemode )
        button.OnClick = function( object )
            Gamemode:setGamemode( object.gamemode )
            StateMachine.switch( State.singleplayer )
        end
        added = true
        list:AddItem( button )
    end
    if not added then
        local text = loveframes.Create( "text", frame )
        text:SetText( "No gamemodes found :(" )
        list:AddItem( text )
    end
end

function Menu:leave()
    loveframes.util:RemoveAll()
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
    self.frame:Center()
end

return Menu
