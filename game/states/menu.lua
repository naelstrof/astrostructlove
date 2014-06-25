local Menu = {}

function Menu:enter()
    frame = loveframes.Create( "frame" )
    frame:SetName( "Main Menu" )
    frame:Center()
    frame:ShowCloseButton( false )
    frame:SetHeight( 200 )

    playsingle = loveframes.Create( "button", frame )
    playsingle:SetWidth( 100 )
    playsingle:CenterX()
    playsingle:SetY( 34 )
    playsingle:SetText( "Play Singleplayer" )

    playdemo = loveframes.Create( "button", frame )
    playdemo:CenterX()
    playdemo:SetY( 64 )
    playdemo:SetText( "Play Demo" )

    mapeditor = loveframes.Create( "button", frame )
    mapeditor:CenterX()
    mapeditor:SetY( 94 )
    mapeditor:SetText( "Map Editor" )

    options = loveframes.Create( "button", frame )
    options:CenterX()
    options:SetY( 124 )
    options:SetText( "Options" )

    quit = loveframes.Create( "button", frame )
    quit:CenterX()
    quit:SetY( 154 )
    quit:SetText( "Quit" )

    playsingle.OnClick = function( object, x, y )
        self:createPlaySingleplayerBox()
    end
    playdemo.OnClick = function( object, x, y )
        self:createPlayDemoBox()
    end
    mapeditor.OnClick = function( object, x, y )
        game.gamestate.switch( gamestates.mapeditor )
    end
    options.OnClick = function( object, x, y )
        game.gamestate.switch( gamestates.options )
    end
    quit.OnClick = function( object, x, y )
        love.event.quit()
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
            gamestates.demoplayback.demoname = object.file
            game.gamestate.switch( gamestates.demoplayback )
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
    for i, gamemode in pairs( game.gamemodes ) do
        local button = loveframes.Create( "button" )
        button.gamemode = gamemode
        button:SetText( button.gamemode.__name )
        button.OnClick = function( object )
            game.gamemode = object.gamemode
            game.gamestate.switch( gamestates.singleplayer )
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
    frame:Center()
end

return Menu
