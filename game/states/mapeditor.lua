local MapEditor = {}

function MapEditor:enter()
    MapEditor.camera = game.entity( { compo.camera, compo.controllable, compo.networked } )
    game.camerasystem:setActive( MapEditor.camera )
    game.renderer:setFullbright( true )
    game.demosystem:record( "test" )

    MapEditor.gridsize = 64
    MapEditor.gridoffsetx = 0
    MapEditor.gridoffsety = 0
    MapEditor.rotstepsize = math.pi / 2
    MapEditor.tool = "create"
    MapEditor.floorentities = {
        {
            name="metalfloor",
            components={ compo.drawable, compo.networked },
            image="data/textures/metalfloor.png",
            attributes={ drawable=love.graphics.newImage( "data/textures/metalfloor.png" ) }
        }
    }
    MapEditor.wallentities = {
        {
            name="metalwall",
            components={ compo.drawable, compo.blockslight, compo.networked },
            image="data/textures/metalwall.png",
            attributes={ drawable=love.graphics.newImage( "data/textures/metalwall.png" ), layer=3 }
        }
    }
    MapEditor.furnitureentities = {
        {
            name="lamp",
            components={ compo.drawable, compo.emitslight, compo.controllable, compo.networked },
            image="data/textures/lamp.png",
            attributes={ drawable=love.graphics.newImage( "data/textures/lamp.png" ), layer=3 }
        },
        {
            name="controlpanel",
            components={ compo.drawable, compo.glows, compo.networked },
            image="data/textures/controlpanel.png",
            attributes={
                            drawable=love.graphics.newImage( "data/textures/controlpanel.png" ),
                            glowdrawable=love.graphics.newImage( "data/textures/controlpanel_illumination.png" ),
                            layer = 3
                       }
        }
    }
    MapEditor.logicentities = {
        {
            name="starfield",
            components={ compo.starfield, compo.networked },
            image="data/textures/logic.png",
            attributes={}
        }
    }
    MapEditor.highlight = game.entity( { compo.drawable } )
    MapEditor.highlight:setColor( { 255, 255, 255, 0 } )
    MapEditor.highlight:setLayer( 4 )
    frame = loveframes.Create( "frame" ):SetName( "Map Editor" ):ShowCloseButton( false ):SetHeight( 200 )
    frame:SetWidth( love.graphics.getWidth() )
    frame:SetPos( 0, love.graphics.getHeight()-frame:GetHeight() )
    frame:SetDraggable( false )

    local grid = loveframes.Create( "grid", frame )
    grid:SetPos( 5, 30 )
    grid:SetRows( 4 )
    grid:SetColumns( 2 )
    grid:SetCellWidth( 31 )
    grid:SetCellHeight( 31 )
    grid:SetCellPadding( 5 )
    grid:SetItemAutoSize( true )
    local create = loveframes.Create( "button" ):SetSize( 25, 25 ):SetText( "C" )
    create.OnClick = function( object, x, y )
        MapEditor.tool = "create"
        MapEditor.highlight = game.entity( { compo.drawable } )
        MapEditor.highlight:setColor( { 255, 255, 255, 0 } )
        MapEditor.highlight:setLayer( 4 )
        if MapEditor.currentEntity ~= nil then
            MapEditor.highlight:setDrawable( love.graphics.newImage( MapEditor.currentEntity.image ) )
        end
    end
    local tooltip = loveframes.Create( "tooltip" )
    tooltip:SetObject( create )
    tooltip:SetPadding( 10 )
    tooltip:SetText( "Create Tool" )
    local delete = loveframes.Create( "button" ):SetSize( 25, 25 ):SetText( "D" )
    delete.OnClick = function( object, x, y )
        MapEditor.tool = "delete"
        MapEditor.highlight:remove()
    end
    local tooltip = loveframes.Create( "tooltip" )
    tooltip:SetObject( delete )
    tooltip:SetPadding( 10 )
    tooltip:SetText( "Delete Tool" )
    grid:AddItem( create, 1, 1 )
    grid:AddItem( delete, 1, 2 )

    local panel = loveframes.Create( "tabs", frame ):SetHeight( 165 )
    panel:SetPos( 90, 30 )
    panel:SetWidth( 128 )
    local floors = loveframes.Create( "list" ):SetPadding( 5 ):SetSpacing( 5 )
    for i,v in pairs( MapEditor.floorentities ) do
        local temp = loveframes.Create( "imagebutton", floors ):SetImage( v.image ):SizeToImage():SetText( v.name )
        temp.OnClick = function()
            MapEditor.currentEntity = v
            if MapEditor.tool == "create" then
                MapEditor.highlight:setDrawable( love.graphics.newImage( v.image ) )
                MapEditor.highlight:setColor( { 255, 255, 255, 155 } )
            end
        end
        floors:AddItem( temp )
    end
    local walls = loveframes.Create( "list" ):SetPadding( 5 ):SetSpacing( 5 )
    for i,v in pairs( MapEditor.wallentities ) do
        local temp = loveframes.Create( "imagebutton", walls ):SetImage( v.image ):SizeToImage():SetText( v.name )
        temp.OnClick = function()
            MapEditor.currentEntity = v
            if MapEditor.tool == "create" then
                MapEditor.highlight:setDrawable( love.graphics.newImage( v.image ) )
                MapEditor.highlight:setColor( { 255, 255, 255, 155 } )
            end
        end
        walls:AddItem( temp )
    end

    local furniture = loveframes.Create( "list" ):SetPadding( 5 ):SetSpacing( 5 )
    for i,v in pairs( MapEditor.furnitureentities ) do
        local temp = loveframes.Create( "imagebutton", furniture ):SetImage( v.image ):SizeToImage():SetText( v.name )
        temp.OnClick = function()
            MapEditor.currentEntity = v
            if MapEditor.tool == "create" then
                MapEditor.highlight:setDrawable( love.graphics.newImage( v.image ) )
                MapEditor.highlight:setColor( { 255, 255, 255, 155 } )
            end
        end
        furniture:AddItem( temp )
    end

    local logic = loveframes.Create( "list" ):SetPadding( 5 ):SetSpacing( 5 )
    for i,v in pairs( MapEditor.logicentities ) do
        local temp = loveframes.Create( "imagebutton", logic ):SetImage( v.image ):SizeToImage():SetText( v.name )
        temp.OnClick = function()
            MapEditor.currentEntity = v
            if MapEditor.tool == "create" then
                MapEditor.highlight:setDrawable( love.graphics.newImage( v.image ) )
                MapEditor.highlight:setColor( { 255, 255, 255, 155 } )
            end
        end
        logic:AddItem( temp )
    end

    panel:AddTab( "Floors", floors )
    panel:AddTab( "Walls", walls )
    panel:AddTab( "Furniture", furniture )
    panel:AddTab( "Logic", logic )

    MapEditor.snap = loveframes.Create( "checkbox", frame ):SetText( "Snap to grid" ):SetPos( 220, 30 )
    local text = loveframes.Create( "text", frame ):SetText( "Grid size" ):SetPos( 220, 65 )
    local gridsize = loveframes.Create( "textinput", frame ):SetText( tostring( MapEditor.gridsize ) ):SetPos( 290, 60 ):SetWidth( 67 )
    gridsize.OnFocusLost = function( object )
        MapEditor.gridsize = tonumber( object:GetText() )
        if MapEditor.gridsize == nil or MapEditor.gridsize == 0 then
            MapEditor.gridsize = 1
            object:SetText( "1" )
        end
    end
    gridsize.OnEnter = gridsize.OnFocusLost
    gridsize:SetUsable( { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.' } )

    local text = loveframes.Create( "text", frame ):SetText( "Grid offset" ):SetPos( 220, 95 )
    local gridoffsetx = loveframes.Create( "textinput", frame ):SetText( tostring( MapEditor.gridoffsetx ) ):SetPos( 290, 90 ):SetWidth( 32 )
    gridoffsetx.OnFocusLost = function( object )
        MapEditor.gridoffsetx = tonumber( object:GetText() )
        if MapEditor.gridoffsetx == nil  then
            MapEditor.gridoffsetx = 0
            object:SetText( "0" )
        end
    end
    gridoffsetx.OnEnter = gridoffsetx.OnFocusLost
    gridoffsetx:SetUsable( { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.' } )

    local gridoffsety = loveframes.Create( "textinput", frame ):SetText( tostring( MapEditor.gridoffsety ) ):SetPos( 325, 90 ):SetWidth( 32 )
    gridoffsety.OnFocusLost = function( object )
        MapEditor.gridoffsety = tonumber( object:GetText() )
        if MapEditor.gridoffsety == nil  then
            MapEditor.gridoffsety = 0
            object:SetText( "0" )
        end
    end
    gridoffsety.OnEnter = gridoffsety.OnFocusLost
    gridoffsety:SetUsable( { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.' } )

    MapEditor.snaprot = loveframes.Create( "checkbox", frame ):SetText( "Rotation snapping" ):SetPos( 220, 130 )
    local text = loveframes.Create( "text", frame ):SetText( "Snap step" ):SetPos( 220, 165 )
    local rotstepsize = loveframes.Create( "textinput", frame ):SetText( tostring( MapEditor.rotstepsize / math.pi * 180 ) ):SetPos( 290, 160 ):SetWidth( 64 )
    rotstepsize.OnFocusLost = function( object )
        MapEditor.rotstepsize = tonumber( object:GetText() ) * math.pi / 180
        if MapEditor.rotstepsize == nil or MapEditor.rotstepsize == 0 then
            MapEditor.rotstepsize = 1
            object:SetText( "1" )
        end
    end
    rotstepsize.OnEnter = rotstepsize.OnFocusLost
    rotstepsize:SetUsable( { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.' } )

    topbar = loveframes.Create( "panel" ):SetWidth( love.graphics.getWidth() ):SetHeight( 24 ):SetPos( 0, 0 )
    local filebutton = loveframes.Create( "button", topbar ):SetText( "File" ):SetPos( 2, 2 ):SetWidth( 32 ):SetHeight( 20 )
    filebutton.OnClick = function()
        loveframes.Create( "menu" ):AddOption( "Quit", false, function() game.gamestate.switch( gamestates.menu ) end ):SetPos( 2, 20 )
    end


end

function MapEditor:leave()
    game.demosystem:leave()
    loveframes.util:RemoveAll()
    for i,v in pairs( game.entities:getAll() ) do
        v:remove()
    end
end

function MapEditor:draw()

    game.renderer:draw()

    if game.renderer:getFullbright() then
        love.graphics.print( "FULLBRIGHT (F to toggle)", 0, 30 )
    end
    game.camerasystem:attach()
    love.graphics.setColor( { 255, 255, 255, 155 } )
    love.graphics.line( -5, -5, 5, 5 )
    love.graphics.line( 5, -5, -5, 5 )
    love.graphics.print( "0, 0", 10, 10 )
    -- A bunch of complicated math to draw a grid, but only inside of the view.
    if MapEditor.snap:GetChecked() then
        local zoom = ( 1 / game.camerasystem:getActive():getZoom() )
        local max = math.max( love.graphics.getWidth(), love.graphics.getHeight() ) * zoom
        local min = math.min( love.graphics.getWidth(), love.graphics.getHeight() ) * zoom
        local difference = math.ceil( ( max - min ) / MapEditor.gridsize ) * MapEditor.gridsize
        local middle = game.camerasystem:getActive():getPos()
        local start = game.vector( middle.x - max / 2, middle.y - max / 2 )
        start = start * zoom
        start = game.vector( math.floor( start.x / MapEditor.gridsize + 0.5 ) * MapEditor.gridsize, math.floor( start.y / MapEditor.gridsize + 0.5 ) * MapEditor.gridsize )
        start = start + game.vector( MapEditor.gridoffsetx, MapEditor.gridoffsety )
        local endp = game.vector( middle.x + max / 2, middle.y + max / 2 )
        endp = endp * zoom
        endp = endp + game.vector( difference, difference )
        for x=start.x,endp.x,MapEditor.gridsize do
            love.graphics.line( x, middle.y + max / 2 + difference, x, middle.y - max / 2 - difference )
        end
        for y=start.y,endp.y,MapEditor.gridsize do
            love.graphics.line( middle.x + max / 2 + difference, y, middle.x - max / 2 - difference, y )
        end
    end

    if MapEditor.tool == "delete" then
        ent = game.entities:getClicked()
        if ent ~= nil then
            love.graphics.setColor( { 255, 0, 0, 155 } )
            love.graphics.line( ent:getPos().x-5, ent:getPos().y-5, ent:getPos().x+5, ent:getPos().y+5 )
            love.graphics.line( ent:getPos().x+5, ent:getPos().y-5, ent:getPos().x-5, ent:getPos().y+5 )
        end
    end

    local mousepos = game.camerasystem:getWorldMouse()
    if MapEditor.placer ~= nil and MapEditor.startplace:dist( mousepos ) > 10 then
        love.graphics.setColor( { 255, 0, 0, 155 } )
        love.graphics.line( MapEditor.startplace.x-5, MapEditor.startplace.y-5, MapEditor.startplace.x+5, MapEditor.startplace.y+5 )
        love.graphics.line( MapEditor.startplace.x+5, MapEditor.startplace.y-5, MapEditor.startplace.x-5, MapEditor.startplace.y+5 )
        love.graphics.print( tostring( MapEditor.placer:getRot() / math.pi * 180 ), MapEditor.startplace.x + 10, MapEditor.startplace.y + 10 )
        love.graphics.setColor( { 0, 255, 0, 155 } )
        love.graphics.line( MapEditor.startplace.x, MapEditor.startplace.y, mousepos.x, mousepos.y )
        love.graphics.setColor( { 0, 0, 255, 155 } )
        love.graphics.line( mousepos.x-5, mousepos.y-5, mousepos.x+5, mousepos.y+5 )
        love.graphics.line( mousepos.x+5, mousepos.y-5, mousepos.x-5, mousepos.y+5 )
    end
    love.graphics.setColor( { 255, 255, 255, 255 } )
    game.camerasystem:detach()
    loveframes.draw()
end

function MapEditor:update( dt )
    local mousepos = game.camerasystem:getWorldMouse()
    if MapEditor.snap:GetChecked() then
        mousepos = mousepos - game.vector( MapEditor.gridoffsetx, MapEditor.gridoffsety )
    end
    game.controlsystem:update( dt )
    if ( MapEditor.snap:GetChecked() ) then
        MapEditor.highlight:setPos( game.vector( math.floor( (mousepos.x - MapEditor.gridsize / 2) / MapEditor.gridsize + 0.5 ) * MapEditor.gridsize, math.floor( (mousepos.y - MapEditor.gridsize / 2) / MapEditor.gridsize + 0.5 ) * MapEditor.gridsize ) + game.vector( MapEditor.gridsize, MapEditor.gridsize ) / 2 )
        MapEditor.highlight:setPos( MapEditor.highlight:getPos() + game.vector( MapEditor.gridoffsetx, MapEditor.gridoffsety ) )
    else
        MapEditor.highlight:setPos( mousepos )
    end
    if MapEditor.placer ~= nil and MapEditor.startplace:dist( mousepos ) > 10 then
        if ( MapEditor.snaprot:GetChecked() ) then
            MapEditor.placer:setRot( math.floor( MapEditor.startplace:angleTo( mousepos ) / MapEditor.rotstepsize + 0.5 ) * MapEditor.rotstepsize )
        else
            MapEditor.placer:setRot( MapEditor.startplace:angleTo( mousepos ) )
        end
    elseif MapEditor.placer ~= nil then
        MapEditor.placer:setRot( 0 )
    end
    game.starsystem:update( dt )
    game.renderer:update( dt )
    game.demosystem:update( dt )
    loveframes.update( dt )
end

function MapEditor:mousepressed( x, y, button )
    -- Only interpret input when we're not clicking on a loveframes
    -- element
    local mousepos = game.camerasystem:getWorldMouse()
    if table.maxn( loveframes.util.GetCollisions() ) <= 1 then
        if button == 'l' then
            if MapEditor.tool == "create" then
                if MapEditor.currentEntity ~= nil then
                    MapEditor.placer = game.entity( MapEditor.currentEntity.components, MapEditor.currentEntity.attributes )
                    if not MapEditor.snap:GetChecked() then
                        MapEditor.placer:setPos( mousepos )
                    else
                        MapEditor.placer:setPos( MapEditor.highlight:getPos() )
                    end
                    MapEditor.startplace = mousepos
                    MapEditor.highlight:setColor( { 255, 255, 255, 0 } )
                end
            end
        elseif button == "wu" then
            game.camerasystem:getActive():Zoom( 1.2 )
        elseif button == "wd" then
            game.camerasystem:getActive():Zoom( 0.8 )
        end
    end
    loveframes.mousepressed( x, y, button )
end

function MapEditor:mousereleased( x, y, button )
    if button == 'l' then
        if MapEditor.tool == "create" then
            if MapEditor.placer ~= nil then
                MapEditor.highlight:setColor( { 255, 255, 255, 155 } )
                MapEditor.placer = nil
            end
        elseif MapEditor.tool == "delete" then
            ent = game.entities:getClicked()
            if ent ~= nil then
                ent:remove()
            end
        end
    end
    loveframes.mousereleased( x, y, button )
end

function MapEditor:keypressed( key, unicode )
    if key == "f" then
        game.renderer:toggleFullbright()
    end
    loveframes.keypressed( key, unicode )
end

function MapEditor:keyreleased( key )
    loveframes.keyreleased( key )
end

function MapEditor:textinput( text )
    loveframes.textinput( text )
end

function MapEditor:resize( w, h )
    frame:SetWidth( love.graphics.getWidth() )
    frame:SetPos( 0, love.graphics.getHeight()-frame:GetHeight() )
    topbar:SetWidth( love.graphics.getWidth() )
    game.renderer:resize( w, h )
end

return MapEditor
