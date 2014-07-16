local Titlebar = {
    savename = "default"
}

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
        menu:AddOption( "Load ...", false, function()
            State.mapeditor.titlebar:createLoadBox()
        end )
        menu:AddOption( "Save as ...", false, function()
            State.mapeditor.titlebar:createSaveAsBox()
        end )
        menu:AddOption( "Save as " .. State.mapeditor.titlebar.savename, false, function()
            MapSystem:save( State.mapeditor.titlebar.savename )
        end )
        menu:AddOption( "Quit", false, function()
            StateMachine.switch( State.menu )
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
            State.mapeditor.grid.enabled = not State.mapeditor.grid.enabled
        end )
        menu:AddOption( "Settings", false, function()
            State.mapeditor.titlebar:createGridSettings()
        end )
        menu:SetPos( 124, 20 )
    end

    local demo = loveframes.Create( "button", self.topbar )
    demo:SetText( "Demo" )
    demo:SetPos( 70, 2 )
    demo:SetWidth( 32 )
    demo:SetHeight( 20 )
    demo.OnClick = function()
        local menu = loveframes.Create( "menu" )
        menu:AddOption( "Toggle Recording", false, function()
            if DemoSystem.recording then
                DemoSystem:stop()
            else
                DemoSystem:record( "test" )
            end
        end )
        menu:SetPos( 156, 20 )
    end

end

function Titlebar:createLoadBox()
    if State.mapeditor.saveasbox ~= nil then
        State.mapeditor.saveasbox:Remove()
    end
    State.mapeditor.saveasbox = loveframes.Create( "frame" )
    local frame = State.mapeditor.saveasbox
    frame:SetWidth( 128 )
    frame:SetHeight( 256 )
    frame:SetName( "Load Map ..." )
    frame:Center()

    local list = loveframes.Create( "list", frame )
    list:SetPos( 4, 29 )
    list:SetSize( 120, 222 )
    list:SetPadding( 2 )
    list:SetSpacing( 2 )

    local files = love.filesystem.getDirectoryItems( "maps/" )
    local added = false
    for i, file in pairs( files ) do
        local button = loveframes.Create( "button" )
        button.file = string.sub( file, 1, -5 )
        button:SetText( button.file )
        button.OnClick = function( object )
            State.mapeditor.titlebar:createLoadConfirm( object.file )
        end
        added = true
        list:AddItem( button )
    end
    if not added then
        local text = loveframes.Create( "text", frame )
        text:SetText( "No maps found :(" )
        list:AddItem( text )
    end
end

function Titlebar:createLoadConfirm( file )
    if State.mapeditor.loadbox ~= nil then
        State.mapeditor.loadbox:Remove()
    end
    State.mapeditor.loadbox = loveframes.Create( "frame" )
    local frame = State.mapeditor.loadbox
    frame:SetWidth( 300 )
    frame:SetHeight( 110 )
    frame:SetName( "Load " .. file )
    frame:Center()
    local text = loveframes.Create( "text", frame )
    text:SetText( "Are you sure you want to load map " .. file .. "?\nAll unsaved progress will be lost!" )
    text:Center()
    text:SetY( 30 )
    local button = loveframes.Create( "button", frame )
    button:SetText( "Yes" )
    button.file = file
    button.frame = frame
    button:SetPos( 20, 70 )
    button.OnClick = function( object )
        MapSystem:load( object.file )
        object.frame:Remove()
        if State.mapeditor.saveasbox ~= nil then
            State.mapeditor.saveasbox:Remove()
        end
    end
    local button = loveframes.Create( "button", frame )
    button:SetText( "No" )
    button:SetPos( 200, 70 )
    button.frame = frame
    button.OnClick = function( object )
        object.frame:Remove()
    end
end

function Titlebar:createSaveAsBox()
    if State.mapeditor.saveasbox ~= nil then
        State.mapeditor.saveasbox:Remove()
    end
    State.mapeditor.saveasbox = loveframes.Create( "frame" )
    local frame = State.mapeditor.saveasbox
    frame:SetWidth( 128 )
    frame:SetHeight( 100 )
    frame:SetName( "Save Map As ..." )
    frame:Center()
    local text = loveframes.Create( "textinput", frame )
    text:SetX( 2 )
    text:SetY( 30 )
    text:SetWidth( 124 )
    text.OnEnter = function( object )
        object:Clear()
    end
    local button = loveframes.Create( "button", frame )
    button:Center()
    button:SetY( 60 )
    button:SetText( "Save" )
    button.input = text
    button.frame = frame
    button.OnClick = function( object )
        State.mapeditor.titlebar.savename = object.input:GetText()
        MapSystem:save( object.input:GetText() )
        object.frame:Remove()
    end
end

function Titlebar:createGridSettings()
    if State.mapeditor.gridsettings ~= nil then
        State.mapeditor.gridsettings:Remove()
    end
    State.mapeditor.gridsettings = loveframes.Create( "frame" )
    local frame = State.mapeditor.gridsettings
    frame:SetWidth( 128 )
    frame:SetHeight( 100 )
    frame:SetName( "Grid Settings" )
    frame:Center()
    local check = loveframes.Create( "checkbox", frame )
    check:SetText( "Enabled" )
    check:SetPos( 2, 26 )
    check:SetChecked( State.mapeditor.grid.enabled )
    check.OnChanged = function( obj, checked )
        State.mapeditor.grid.enabled = checked
    end
    local text = loveframes.Create( "text", frame )
    text:SetText( "Grid offset" )
    text:SetPos( 2, 50 )
    local gridoffsetx = loveframes.Create( "textinput", frame )
    gridoffsetx:SetText( tostring( State.mapeditor.grid.gridoffset.x ) )
    gridoffsetx:SetPos( 20, 65 )
    gridoffsetx:SetWidth( 32 )
    gridoffsetx.OnFocusLost = function( object )
        State.mapeditor.grid.gridoffset.x = tonumber( object:GetText() )
        if State.mapeditor.grid.gridoffset.x == nil  then
            State.mapeditor.grid.gridoffset.x = 0
            object:SetText( "0" )
        end
    end
    gridoffsetx.OnEnter = gridoffsetx.OnFocusLost
    gridoffsetx:SetUsable( { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.' } )

    local gridoffsety = loveframes.Create( "textinput", frame )
    gridoffsety:SetText( tostring( State.mapeditor.grid.gridoffset.y ) )
    gridoffsety:SetPos( 60, 65 )
    gridoffsety:SetWidth( 32 )
    gridoffsety.OnFocusLost = function( object )
        State.mapeditor.grid.gridoffset.y = tonumber( object:GetText() )
        if State.mapeditor.grid.gridoffset.y == nil  then
            State.mapeditor.grid.gridoffset.y = 0
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
