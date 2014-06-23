local Titlebar = { }

function Titlebar:init()

    self.topbar = loveframes.Create( "panel" )
    self.topbar:SetWidth( love.graphics.getWidth() - 88 )
    self.topbar:SetHeight( 24 )
    self.topbar:SetPos( 88, 0 )

    local filebutton = loveframes.Create( "button", self.topbar )
    filebutton:SetText( "File" )
    filebutton:SetPos( 2, 2 )
    filebutton:SetWidth( 32 )
    filebutton:SetHeight( 20 )
    filebutton.OnClick = function()
        local menu = loveframes.Create( "menu" )
        menu:AddOption( "Quit", false, function()
            game.gamestate.switch( gamestates.menu )
        end )
        menu:SetPos( 90, 20 )
    end

    local grid = loveframes.Create( "button", self.topbar )
    grid:SetText( "Grid" )
    grid:SetPos( 36, 2 )
    grid:SetWidth( 32 )
    grid:SetHeight( 20 )
    grid.OnClick = function()
        local menu = loveframes.Create( "menu" )
        menu:AddOption( "Toggle", false, function()
            gamestates.mapeditor.grid.enabled = not gamestates.mapeditor.grid.enabled
        end )
        menu:AddOption( "Settings", false, function()
            gamestates.mapeditor.titlebar:createGridSettings()
        end )
        menu:SetPos( 124, 20 )
    end

end

function Titlebar:createGridSettings()
    if gamestates.mapeditor.gridsettings ~= nil then
        gamestates.mapeditor.gridsettings:Remove()
    end
    gamestates.mapeditor.gridsettings = loveframes.Create( "frame" )
    local frame = gamestates.mapeditor.gridsettings
    frame:SetWidth( 128 )
    frame:SetHeight( 100 )
    frame:SetName( "Grid Settings" )
    frame:Center()
    local check = loveframes.Create( "checkbox", frame )
    check:SetText( "Enabled" )
    check:SetPos( 2, 26 )
    check:SetChecked( gamestates.mapeditor.grid.enabled )
    check.OnChanged = function( obj, checked )
        gamestates.mapeditor.grid.enabled = checked
    end
    local text = loveframes.Create( "text", frame )
    text:SetText( "Grid offset" )
    text:SetPos( 2, 50 )
    local gridoffsetx = loveframes.Create( "textinput", frame )
    gridoffsetx:SetText( tostring( gamestates.mapeditor.grid.gridoffset.x ) )
    gridoffsetx:SetPos( 20, 65 )
    gridoffsetx:SetWidth( 32 )
    gridoffsetx.OnFocusLost = function( object )
        gamestates.mapeditor.grid.gridoffset.x = tonumber( object:GetText() )
        if gamestates.mapeditor.grid.gridoffset.x == nil  then
            gamestates.mapeditor.grid.gridoffset.x = 0
            object:SetText( "0" )
        end
    end
    gridoffsetx.OnEnter = gridoffsetx.OnFocusLost
    gridoffsetx:SetUsable( { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.' } )

    local gridoffsety = loveframes.Create( "textinput", frame )
    gridoffsety:SetText( tostring( gamestates.mapeditor.grid.gridoffset.y ) )
    gridoffsety:SetPos( 60, 65 )
    gridoffsety:SetWidth( 32 )
    gridoffsety.OnFocusLost = function( object )
        gamestates.mapeditor.grid.gridoffset.y = tonumber( object:GetText() )
        if gamestates.mapeditor.grid.gridoffset.y == nil  then
            gamestates.mapeditor.grid.gridoffset.y = 0
            object:SetText( "0" )
        end
    end
    gridoffsety.OnEnter = gridoffsety.OnFocusLost
    gridoffsety:SetUsable( { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.' } )
end

function Titlebar:resize( w, h )
    self.topbar:SetWidth( w - 88 )
end

return Titlebar
