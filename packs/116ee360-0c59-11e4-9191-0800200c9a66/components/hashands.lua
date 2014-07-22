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
    networkinfo = {
        setHandItems = "handitems"
    }
}

function HasHands:processHand( hand, controls )
    -- If nothing is in the hand
    -- we try to pick something up. (Even if we have modifiers pressed)
    if not self.handitems[ hand ] then
        -- Make sure we don't have any modifiers held
        if controls.throwmodifier ~= 1 and controls.dropmodifier ~= 1 then
            local ents = World:getNearby( Vector( controls.x, controls.y ), self.handsize )
            -- If we found something we put it in our hand
            for i,v in pairs( ents ) do
                -- We can only pick up items
                if v:hasComponent( Components.isitem ) then
                    self.handitems[ hand ] = v.demoIndex
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
            self.handitems[ hand ] = nil
        else
            -- use
            local ent = DemoSystem.entities[ self.handitems[ hand ] ]
            ent:use( self )
        end
    end
end

function HasHands:update( dt, tick )
    if dt < 0 then
        return
    end
    -- We go and see if any hand binds were freshly pressed
    for i=1, self.handcount do
        if self:getControlClicked( "hand" .. i, tick ) then
            self:processHand( i, self:getControls( tick ) )
        end
    end
    self.updateItems( self, dt, tick )
end

function HasHands:updateItems( dt, tick )
    local controls = self:getControls( tick )
    for i,v in pairs( self.handitems ) do
        local ent = DemoSystem.entities[ v ]
        ent:setPos( self:getPos() + self.handpositions[ i ]:rotated( self:getRot() ) )
        if ent.rotatecarry then
            ent:setRot( ( self:getPos() + self.handpositions[ i ] ):angleTo( Vector( controls.x, controls.y ) ) + math.pi )
        else
            ent:setRot( self:getRot() )
        end
    end
    if self:isLocalPlayer() then
        for i=1, self.handcount do
            self:updateItemGUI( i, self.handitems[ i ] )
        end
    end
end

function HasHands:updateItemGUI( i, ent )
    if not self.handgui then
        return
    end
    ent = DemoSystem.entities[ ent ] or nil
    if ( not self.handguibuttons[ i ] and ent ) or ( self.handguibuttons[ i ] and self.handguibuttons[ i ].ent ~= ent and ent ) then
        if self.handguibuttons[ i ] then
            self.handguibuttons[ i ]:Remove()
        end
        self.handguibuttons[ i ] = loveframes.Create( "panel", self.handgui )
        self.handguibuttons[ i ]:SetSize( 62, 62 )
        self.handguibuttons[ i ]:SetPos( 64*(i-1) + 1, 1 )
        self.handguibuttons[ i ].ent = ent
        local image = loveframes.Create( "imagebutton", self.handguibuttons[ i ] )
        image:SetImage( Entities.entities[ ent.__name ].image )
        image:SetSize( 62, 62 )
        image:SetText( ent.__name )
        local tooltip = loveframes.Create( "tooltip", self.handguibuttons[ i ] )
        tooltip:SetObject( image )
        tooltip:SetFollowCursor( true )
        tooltip:SetText( Entities.entities[ ent.__name ].description )
        tooltip:SetOffsetX( -256 )
        tooltip:SetTextMaxWidth( 256 )
    elseif not ent then
        if self.handguibuttons[ i ] then
            self.handguibuttons[ i ]:Remove()
            self.handguibuttons[ i ].ent = nil
        end
    end
end

function HasHands:resize( w, h )
    if self.handgui then
        local size = Vector( 64*self.handcount, 64 )
        self.handgui:SetPos( w-size.x, h-size.y )
    end
end

function HasHands:setHandItems( handitems )
    self.handitems = handitems
    if self:isLocalPlayer() then
        for i=1, self.handcount do
            self:updateItemGUI( i, self.handitems[ i ] )
        end
    end
end

function HasHands:setLocalPlayer( bool )
    if bool then
        if self.handgui then
            self.handgui:Remove()
        end
        -- Create some simple GUI for the hands
        self.handgui = loveframes.Create( "panel" )
        local size = Vector( 64*self.handcount, 64 )
        self.handgui:SetSize( size.x, size.y )
        self.handgui:SetPos( love.graphics.getWidth()-size.x, love.graphics.getHeight()-size.y )
        self.handguibuttons = {}
        for i=1,self.handcount do
            local text = loveframes.Create( "text", self.handgui )
            text:SetDefaultColor( 100, 100, 100, 100 )
            text:SetShadowColor( 0, 0, 0, 0 )
            text:SetText( "Hand " .. i )
            text:SetPos( (i-1)*64+10, 16 )
        end
    end
end

function HasHands:init()
    if self:isLocalPlayer() then
        if self.handgui then
            self.handgui:Remove()
        end
        -- Create some simple GUI for the hands
        self.handgui = loveframes.Create( "panel" )
        local size = Vector( 64*self.handcount, 64 )
        self.handgui:SetSize( size.x, size.y )
        self.handgui:SetPos( love.graphics.getWidth()-size.x, love.graphics.getHeight()-size.y )
        self.handguibuttons = {}
        for i=1,self.handcount do
            local text = loveframes.Create( "text", self.handgui )
            text:SetDefaultColor( 100, 100, 100, 100 )
            text:SetShadowColor( 0, 0, 0, 0 )
            text:SetText( "Hand " .. i )
            text:SetPos( (i-1)*64+10, 16 )
        end
    end
end

return HasHands
