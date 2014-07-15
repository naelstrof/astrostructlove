local processHand = function( e, hand, controls )
    if controls[ "hand"..hand ] ~= 1 then
        return
    end
    -- If nothing is in the hand
    -- we try to pick something up. (Even if we have modifiers pressed)
    if not e.handitems[ hand ] then
        -- Make sure we don't have any modifiers held
        if controls.throwmodifier ~= 1 and controls.dropmodifier ~= 1 then
            local ents = game.entities:getNearby( game.vector( controls.x, controls.y ), e.handsize )
            -- If we found something we put it in our hand
            for i,v in pairs( ents ) do
                -- We can only pick up items
                if v:hasComponent( compo.isitem ) then
                    e.handitems[ hand ] = v.demoIndex
                    break
                    -- We don't have to move the entity around since updateItems is called shortly after this
                end
            end
        end
    else
        -- If we have something in our hand, check for modifiers
        if controls.throwmodifier == 1 then
            -- throw
        elseif controls.dropmodifier == 1 then
            -- drop
            e.handitems[ hand ] = nil
        else
            -- use
            local ent = game.demosystem.entities[ e.handitems[ hand ] ]
            ent:use( e )
        end
    end
end

local update = function( e, dt, tick )
    -- Active runs is true when we're the active player being
    -- controlled by the client.
    -- tick is not nil when we're being ran in a simulation
    local controls = game.network:getControls( e.playerid, tick )
    if ( e.active and controls ~= nil ) or ( tick ~= nil and controls ~= nil ) then
        -- We go and see if any hand binds are pressed
        for i=1, e.handcount do
            if controls[ "hand"..i ] ~= e.handmemory[ "hand"..i ] then
                e:processHand( i, controls )
                e.handmemory[ "hand"..i ] = controls[ "hand"..i ]
            end
        end
    end
    e.updateItems( e, dt, tick )
end

local updateItems = function( e, dt, tick )
    local controls = game.network:getControls( e.playerid, tick )
    if controls then
        for i,v in pairs( e.handitems ) do
            local ent = game.demosystem.entities[ v ]
            ent:setPos( e:getPos() + e.handpositions[ i ]:rotated( e:getRot() ) )
            ent:setRot( ( e:getPos() + e.handpositions[ i ] ):angleTo( game.vector( controls.x, controls.y ) ) + math.pi )
            e:updateItemGUI( i, ent )
        end
        for i=1, e.handcount do
            if not e.handitems[ i ] then
                e:updateItemGUI( i, nil )
            end
        end
    end
end

local updateItemGUI = function( e, i, ent )
    if not e.handgui then
        return
    end
    if not e.handguibuttons[ i ] or e.handguibuttons[ i ].obj ~= ent then
        if e.handguibuttons[ i ] then
            e.handguibuttons[ i ]:Remove()
        end
        if not ent then
            if e.handguibuttons[ i ] then
                e.handguibuttons[ i ].obj = nil
            end
            return
        end
        local panel = loveframes.Create( "panel", e.handgui )
        panel:SetSize( 62, 62 )
        panel:SetPos( 64*(i-1) + 1, 1 )
        e.handguibuttons[ i ] = loveframes.Create( "imagebutton", panel )
        local image = game.gamemode.entities[ ent.__name ].image
        e.handguibuttons[ i ]:SetImage( image )
        e.handguibuttons[ i ].obj = ent
        e.handguibuttons[ i ]:SetSize( 62, 62 )
        e.handguibuttons[ i ]:SetText( ent.__name )
        local tooltip = loveframes.Create( "tooltip", e.handguibuttons[ i ] )
        tooltip:SetObject( e.handguibuttons[ i ] )
        tooltip:SetFollowCursor( true )
        tooltip:SetText( game.gamemode.entities[ ent.__name ].description )
        tooltip:SetOffsetX( -256 )
        tooltip:SetTextMaxWidth( 256 )
    end
end

local resize = function( e, w, h )
    if e.handgui then
        local size = game.vector( 64*e.handcount, 64 )
        e.handgui:SetPos( w-size.x, h-size.y )
    end
end

local setHandItems = function( e, handitems )
    e.handitems = handitems
end

local init = function( e )
    -- Since complex types are lost when networked, we need to make sure
    -- handpositions contains actual vectors
    for i,v in pairs( e.handpositions ) do
        e.handpositions[ i ] = game.vector( v.x, v.y )
    end
    if game.network:isLocalPlayer( e.playerid ) then
        -- Create some simple GUI for the hands
        e.handgui = loveframes.Create( "panel" )
        local size = game.vector( 64*e.handcount, 64 )
        e.handgui:SetSize( size.x, size.y )
        e.handgui:SetPos( love.graphics.getWidth()-size.x, love.graphics.getHeight()-size.y )
        e.handguibuttons = {}
        for i=1,e.handcount do
            local text = loveframes.Create( "text", e.handgui )
            text:SetDefaultColor( 100, 100, 100, 100 )
            text:SetShadowColor( 0, 0, 0, 0 )
            text:SetText( "Hand " .. i )
            text:SetPos( (i-1)*64+10, 16 )
        end
    end
end

local deinit = function( e )
end

local HasHands = {
    __name = "HasHands",
    handcount = 2,
    -- Used for lenient clicks
    handsize = 5,
    handpositions = {
        game.vector( -20, 5 ),
        game.vector( 20, 5 )
    },
    handitems = {},
    handmemory = {},
    update = update,
    resize = resize,
    setHandItems = setHandItems,
    networkedvars = { "handitems" },
    networkedfunctions = { "setHandItems" },
    updateItems = updateItems,
    updateItemGUI = updateItemGUI,
    processHand = processHand,
    init = init,
    deinit = deinit
}

return HasHands
