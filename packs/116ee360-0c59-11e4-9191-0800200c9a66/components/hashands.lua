local processHand = function( e, hand, controls )
    -- If nothing is in the hand
    -- we try to pick something up. (Even if we have modifiers pressed)
    if not e.handitems[ hand ] then
        -- Make sure we don't have any modifiers held
        if controls.throwmodifier ~= 1 and controls.dropmodifier ~= 1 then
            local ents = World:getNearby( Vector( controls.x, controls.y ), e.handsize )
            -- If we found something we put it in our hand
            for i,v in pairs( ents ) do
                -- We can only pick up items
                if v:hasComponent( Components.isitem ) then
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
            local ent = DemoSystem.entities[ e.handitems[ hand ] ]
            ent:use( e )
        end
    end
end

local update = function( e, dt, tick )
    if dt < 0 then
        return
    end
    -- We go and see if any hand binds were freshly pressed
    for i=1, e.handcount do
        if e:getControlClicked( "hand" .. i, tick ) then
            e:processHand( i, e:getControls( tick ) )
        end
    end
    e.updateItems( e, dt, tick )
end

local updateItems = function( e, dt, tick )
    local controls = e:getControls( tick )
    for i,v in pairs( e.handitems ) do
        local ent = DemoSystem.entities[ v ]
        ent:setPos( e:getPos() + e.handpositions[ i ]:rotated( e:getRot() ) )
        if ent.rotatecarry then
            ent:setRot( ( e:getPos() + e.handpositions[ i ] ):angleTo( Vector( controls.x, controls.y ) ) + math.pi )
        else
            ent:setRot( e:getRot() )
        end
    end
    if e:isLocalPlayer() then
        for i=1, e.handcount do
            e:updateItemGUI( i, e.handitems[ i ] )
        end
    end
end

local updateItemGUI = function( e, i, ent )
    if not e.handgui then
        return
    end
    ent = DemoSystem.entities[ ent ] or nil
    if ( not e.handguibuttons[ i ] and ent ) or ( e.handguibuttons[ i ] and e.handguibuttons[ i ].ent ~= ent and ent ) then
        if e.handguibuttons[ i ] then
            e.handguibuttons[ i ]:Remove()
        end
        e.handguibuttons[ i ] = loveframes.Create( "panel", e.handgui )
        e.handguibuttons[ i ]:SetSize( 62, 62 )
        e.handguibuttons[ i ]:SetPos( 64*(i-1) + 1, 1 )
        e.handguibuttons[ i ].ent = ent
        local image = loveframes.Create( "imagebutton", e.handguibuttons[ i ] )
        image:SetImage( Entities.entities[ ent.__name ].image )
        image:SetSize( 62, 62 )
        image:SetText( ent.__name )
        local tooltip = loveframes.Create( "tooltip", e.handguibuttons[ i ] )
        tooltip:SetObject( image )
        tooltip:SetFollowCursor( true )
        tooltip:SetText( Entities.entities[ ent.__name ].description )
        tooltip:SetOffsetX( -256 )
        tooltip:SetTextMaxWidth( 256 )
    elseif not ent then
        if e.handguibuttons[ i ] then
            e.handguibuttons[ i ]:Remove()
            e.handguibuttons[ i ].ent = nil
        end
    end
end

local resize = function( e, w, h )
    if e.handgui then
        local size = Vector( 64*e.handcount, 64 )
        e.handgui:SetPos( w-size.x, h-size.y )
    end
end

local setHandItems = function( e, handitems )
    e.handitems = handitems
    if e:isLocalPlayer() then
        for i=1, e.handcount do
            e:updateItemGUI( i, e.handitems[ i ] )
        end
    end
end

local setLocalPlayer = function( e, bool )
    if bool then
        if e.handgui then
            e.handgui:Remove()
        end
        -- Create some simple GUI for the hands
        e.handgui = loveframes.Create( "panel" )
        local size = Vector( 64*e.handcount, 64 )
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

local init = function( e )
    if e:isLocalPlayer() then
        if e.handgui then
            e.handgui:Remove()
        end
        -- Create some simple GUI for the hands
        e.handgui = loveframes.Create( "panel" )
        local size = Vector( 64*e.handcount, 64 )
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
        Vector( -20, 5 ),
        Vector( 20, 5 )
    },
    handitems = {},
    update = update,
    resize = resize,
    setHandItems = setHandItems,
    setLocalPlayer = setLocalPlayer,
    networkinfo = {
        setHandItems = "handitems"
    },
    updateItems = updateItems,
    updateItemGUI = updateItemGUI,
    processHand = processHand,
    init = init,
    deinit = deinit
}

return HasHands
