local CreateTool = {
    __name = "Create",
    __desc = "Left click to create selected entity, left click and drag to create and rotate.",
    selectedentity=nil,
    highlighter=nil,
    placer=nil,
    -- Max distance between the placer and the mouse before it starts rotating.
    maxdist=15
}

function CreateTool:init()
    self.frame = loveframes.Create( "frame" )
    self.frame:SetWidth( 256 )
    self.frame:SetHeight( 256 )
    self.frame:Center()
    self.frame:SetName( "Create Tool" )
    self.tabs = loveframes.Create( "tabs", self.frame )
    self.tabs:SetPos( 3, 27 )
    self.tabs:SetWidth( 250 )
    self.tabs:SetHeight( 224 )
    local ents = loveframes.Create( "list" )
    ents:SetPadding( 5 )
    ents:SetSpacing( 5 )
    for i,v in pairs( game.gamemode.entities ) do
        local temp = loveframes.Create( "imagebutton", ents )
        temp:SetImage( v.image )
        temp:SizeToImage()
        temp:SetText( v.__name )
        temp.OnClick = function()
            self.selectedentity = v.__name
            -- Spawn the highlighter if it doesn't exist
            if self.highlighter ~= nil then
                self.highlighter:remove()
                self.highlighter = nil
            end
            self.highlighter = game.entity:new( self.selectedentity )
            if self.highlighter:hasComponent( compo.drawable ) then
                self.highlighter:setColor( { 255, 255, 255, 155 } )
                self.highlighter:setLayer( 4 )
            end
        end
        ents:AddItem( temp )
    end
    self.tabs:AddTab( "Entities", ents )
end

function CreateTool:deinit()
    self.tabs:Remove()
    self.frame:Remove()
    if self.highlighter ~= nil then
        self.highlighter:remove()
        self.highlighter = nil
    end
end

function CreateTool:update( dt, x, y )
    local mousepos = game.vector( x, y )
    if self.highlighter ~= nil then
        self.highlighter:setPos( mousepos )
    end
    if self.placer ~= nil and self.placer:getPos():dist( mousepos ) > self.maxdist then
        self.placer:setRot( self.placer:getPos():angleTo( mousepos ) )
    elseif self.placer ~= nil then
        self.placer:setRot( 0 )
    end
end

function CreateTool:draw( x, y )
    -- Draw some extra angle information
    local mousepos = game.vector( x, y )
    if self.placer ~= nil and self.placer:getPos():dist( mousepos ) > self.maxdist then
        local startpos = self.placer:getPos()
        love.graphics.setColor( { 255, 0, 0, 155 } )
        -- Draw an x at the startpos
        love.graphics.line( startpos.x-5, startpos.y-5, startpos.x+5, startpos.y+5 )
        love.graphics.line( startpos.x+5, startpos.y-5, startpos.x-5, startpos.y+5 )
        -- Draw some text indicating the angle in degrees
        love.graphics.print( tostring( self.placer:getRot() / math.pi * 180 ), startpos.x + 10, startpos.y + 10 )
        love.graphics.setColor( { 0, 255, 0, 155 } )
        love.graphics.line( startpos.x, startpos.y, mousepos.x, mousepos.y )
        love.graphics.setColor( { 0, 0, 255, 155 } )
        -- Draw an x at the mousepos
        love.graphics.line( mousepos.x-5, mousepos.y-5, mousepos.x+5, mousepos.y+5 )
        love.graphics.line( mousepos.x+5, mousepos.y-5, mousepos.x-5, mousepos.y+5 )
        love.graphics.setColor( { 255, 255, 255, 255 } )
    end
end

function CreateTool:mousepressed( x, y, button )
    if self.selectedentity == nil then
        return
    end
    if button == 'l' then
        self.highlighter:remove()
        self.highlighter = nil
        self.placer = game.entity:new( self.selectedentity )
        self.placer:setPos( game.vector( x, y ) )
    end
end

function CreateTool:mousereleased( x, y, button )
    if self.selectedentity == nil then
        return
    end
    if button == 'l' then
        -- Respawn the highlighter
        if self.highlighter == nil then
            self.highlighter = game.entity:new( self.selectedentity )
            if self.highlighter:hasComponent( compo.drawable ) then
                self.highlighter:setColor( { 255, 255, 255, 155 } )
                self.highlighter:setLayer( 4 )
            end
        end
        -- Unreference the placer so that we don't continue rotating it
        self.placer = nil
    end
end

return CreateTool
