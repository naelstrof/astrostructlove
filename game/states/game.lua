local Game = {}

function Game:enter()
    Game.gridsize = 64
    Game.rotstepsize = math.pi / 2
    Game.tool = "create"
    Game.floorentities = { { name="metalfloor", components={ game.drawable }, image="data/textures/metalfloor.png" } }

    Game.wallentities = { { name="metalwall", components={ game.drawable }, image="data/textures/tile.png" } }
    Game.furnitureentities = {
        { name="table", components={ game.drawable }, image="data/textures/tile.png" },
        { name="chair", components={ game.drawable }, image="data/textures/tile.png" }
    }
    Game.highlight = game.entity( { game.drawable } )
    Game.highlight:setColor( { 255, 255, 255, 155 } )
    Game.highlight:setLayer( 1 )
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
        Game.tool = "create"
        Game.highlight = game.entity( { game.drawable } )
        Game.highlight:setColor( { 255, 255, 255, 155 } )
        Game.highlight:setLayer( 1 )
    end
    local tooltip = loveframes.Create( "tooltip" )
    tooltip:SetObject( create )
    tooltip:SetPadding( 10 )
    tooltip:SetText( "Create Tool" )
    local delete = loveframes.Create( "button" ):SetSize( 25, 25 ):SetText( "D" )
    delete.OnClick = function( object, x, y )
        Game.tool = "delete"
        Game.highlight:remove()
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
    for i,v in pairs( Game.floorentities ) do
        local temp = loveframes.Create( "imagebutton", floors ):SetImage( v.image ):SizeToImage():SetText( v.name )
        temp.OnClick = function()
            Game.currentEntity = v
            if Game.tool == "create" then
                Game.highlight:setDrawable( love.graphics.newImage( Game.currentEntity.image ) )
            end
        end
        floors:AddItem( temp )
    end
    local walls = loveframes.Create( "list" ):SetPadding( 5 ):SetSpacing( 5 )
    for i,v in pairs( Game.wallentities ) do
        local temp = loveframes.Create( "imagebutton", walls ):SetImage( v.image ):SizeToImage():SetText( v.name )
        temp.OnClick = function()
            Game.currentEntity = v
            if Game.tool == "create" then
                Game.highlight:setDrawable( love.graphics.newImage( Game.currentEntity.image ) )
            end
        end
        walls:AddItem( temp )
    end

    local furniture = loveframes.Create( "list" ):SetPadding( 5 ):SetSpacing( 5 )
    for i,v in pairs( Game.furnitureentities ) do
        local temp = loveframes.Create( "imagebutton", furniture ):SetImage( v.image ):SizeToImage():SetText( v.name )
        temp.OnClick = function()
            Game.currentEntity = v
            if Game.tool == "create" then
                Game.highlight:setDrawable( love.graphics.newImage( Game.currentEntity.image ) )
            end
        end
        furniture:AddItem( temp )
    end

    panel:AddTab( "Floors", floors )
    panel:AddTab( "Walls", walls )
    panel:AddTab( "Furniture", furniture )

    Game.snap = loveframes.Create( "checkbox", frame ):SetText( "Snap to grid" ):SetPos( 220, 30 )
    local text = loveframes.Create( "text", frame ):SetText( "Grid size" ):SetPos( 220, 65 )
    local gridsize = loveframes.Create( "textinput", frame ):SetText( tostring( Game.gridsize ) ):SetPos( 290, 60 ):SetWidth( 64 )
    gridsize.OnFocusLost = function( object )
        Game.gridsize = tonumber( object:GetText() )
        if Game.gridsize == nil or Game.gridsize == 0 then
            Game.gridsize = 1
            object:SetText( "1" )
        end
    end
    gridsize.OnEnter = gridsize.OnFocusLost
    gridsize:SetUsable( { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.' } )
    Game.snaprot = loveframes.Create( "checkbox", frame ):SetText( "Rotation snapping" ):SetPos( 220, 90 )
    local text = loveframes.Create( "text", frame ):SetText( "Snap step" ):SetPos( 220, 125 )
    local rotstepsize = loveframes.Create( "textinput", frame ):SetText( tostring( Game.rotstepsize / math.pi * 180 ) ):SetPos( 290, 120 ):SetWidth( 64 )
    rotstepsize.OnFocusLost = function( object )
        Game.rotstepsize = tonumber( object:GetText() ) * math.pi / 180
        if Game.rotstepsize == nil or Game.rotstepsize == 0 then
            Game.rotstepsize = 1
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

function Game:leave()
    frame:Remove()
    topbar:Remove()
    for i,v in pairs( game.entities:getAll() ) do
        v:remove()
    end
end

function Game:draw()
    game.renderer:draw()
    love.graphics.setColor( { 255, 255, 255, 155 } )
    if Game.snap:GetChecked() then
        for x=0,love.graphics.getWidth(),Game.gridsize do
            love.graphics.line( x, 0, x, love.graphics.getHeight() )
        end
        for y=0,love.graphics.getHeight(),Game.gridsize do
            love.graphics.line( 0, y, love.graphics.getWidth(), y )
        end
    end

    if Game.tool == "delete" then
        ent = game.entities:getClicked()
        if ent ~= nil then
            love.graphics.setColor( { 255, 0, 0, 155 } )
            love.graphics.line( ent:getPos().x-5, ent:getPos().y-5, ent:getPos().x+5, ent:getPos().y+5 )
            love.graphics.line( ent:getPos().x+5, ent:getPos().y-5, ent:getPos().x-5, ent:getPos().y+5 )
        end
    end

    if Game.placer ~= nil and Game.startplace:dist( game.vector( love.mouse.getX(), love.mouse.getY() ) ) > 10 then
        love.graphics.setColor( { 255, 0, 0, 155 } )
        love.graphics.line( Game.startplace.x-5, Game.startplace.y-5, Game.startplace.x+5, Game.startplace.y+5 )
        love.graphics.line( Game.startplace.x+5, Game.startplace.y-5, Game.startplace.x-5, Game.startplace.y+5 )
        love.graphics.print( tostring( Game.placer:getRot() / math.pi * 180 ), Game.startplace.x + 10, Game.startplace.y + 10 )
        love.graphics.setColor( { 0, 255, 0, 155 } )
        love.graphics.line( Game.startplace.x, Game.startplace.y, love.mouse.getX(), love.mouse.getY() )
        love.graphics.setColor( { 0, 0, 255, 155 } )
        love.graphics.line( love.mouse.getX()-5, love.mouse.getY()-5, love.mouse.getX()+5, love.mouse.getY()+5 )
        love.graphics.line( love.mouse.getX()+5, love.mouse.getY()-5, love.mouse.getX()-5, love.mouse.getY()+5 )
    end
    love.graphics.setColor( { 255, 255, 255, 255 } )
    loveframes.draw()
end

function Game:update( dt )
    if ( Game.snap:GetChecked() ) then
        Game.highlight:setPos( game.vector( math.floor( (love.mouse.getX() - Game.gridsize / 2) / Game.gridsize + 0.5 ) * Game.gridsize, math.floor( (love.mouse.getY() - Game.gridsize / 2) / Game.gridsize + 0.5 ) * Game.gridsize ) + game.vector( Game.gridsize, Game.gridsize ) / 2 )
    else
        Game.highlight:setPos( game.vector( love.mouse.getX(), love.mouse.getY() ) )
    end
    if Game.placer ~= nil and Game.startplace:dist( game.vector( love.mouse.getX(), love.mouse.getY() ) ) > 10 then
        if ( Game.snaprot:GetChecked() ) then
            Game.placer:setRot( math.floor( Game.startplace:angleTo( game.vector( love.mouse.getX(), love.mouse.getY() ) ) / Game.rotstepsize + 0.5 ) * Game.rotstepsize )
        else
            Game.placer:setRot( Game.startplace:angleTo( game.vector( love.mouse.getX(), love.mouse.getY() ) ) )
        end
    elseif Game.placer ~= nil then
        Game.placer:setRot( 0 )
    end
    loveframes.update( dt )
end

function Game:mousepressed( x, y, button )
    if button == 'l' then
        if y > 22 and y < love.graphics.getHeight() - 200 then
            if Game.tool == "create" then
                if Game.currentEntity ~= nil then
                    Game.placer = game.entity( Game.currentEntity.components )
                    Game.placer:setPos( Game.highlight:getPos() )
                    Game.placer:setDrawable( love.graphics.newImage( Game.currentEntity.image ) )
                    Game.startplace = game.vector( love.mouse.getX(), love.mouse.getY() )
                    Game.highlight:setColor( { 255, 255, 255, 0 } )
                end
            elseif Game.tool == "delete" then
            end
        end
    end
    loveframes.mousepressed( x, y, button )
end

function Game:mousereleased( x, y, button )
    if button == 'l' then
        if Game.tool == "create" then
            if Game.placer ~= nil then
                Game.highlight:setColor( { 255, 255, 255, 155 } )
                Game.placer = nil
            end
        elseif Game.tool == "delete" then
            if y > 22 and y < love.graphics.getHeight() - 200 then
                ent = game.entities:getClicked()
                if ent ~= nil then
                    ent:remove()
                end
            end
        end
    end
    loveframes.mousereleased( x, y, button )
end

function Game:keypressed( key, unicode )
    loveframes.keypressed( key, unicode )
end

function Game:keyreleased( key )
    loveframes.keyreleased( key )
end

function Game:textinput( text )
    loveframes.textinput( text )
end

function Game:resize( w, h )
    frame:SetWidth( love.graphics.getWidth() )
    frame:SetPos( 0, love.graphics.getHeight()-frame:GetHeight() )
    topbar:SetWidth( love.graphics.getWidth() )
end

return Game
