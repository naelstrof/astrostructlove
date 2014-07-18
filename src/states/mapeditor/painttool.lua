local PaintTool = {
    __name = "Paint",
    __desc = "Left click and hold to \"Paint\" an entity. Best when used with the grid enabled.",
    selectedentity=nil,
    highlighter=nil,
    placer=nil,
    painting=false,
    posmem = nil,
    lastpos = nil
}

function PaintTool:init()
    self.selectedentity = nil
    self.frame = loveframes.Create( "frame" )
    if not self.widthmem and not self.heightmem then
        self.frame:SetWidth( 312 )
        self.frame:SetHeight( 312 )
    else
        self.frame:SetWidth( self.widthmem )
        self.frame:SetHeight( self.heightmem )
    end
    if not self.posmem then
        self.frame:SetPos( 88, love.graphics.getHeight() - 312 )
    else
        self.frame:SetPos( self.posmem.x, self.posmem.y )
    end
    self.frame:SetName( "Paint Tool" )
    self.tabs = loveframes.Create( "tabs", self.frame )
    self.tabs:SetPos( 3, 27 )
    self.tabs:SetWidth( self.frame:GetWidth()-5 )
    self.tabs:SetHeight( self.frame:GetHeight()-32 )
    local ents = loveframes.Create( "list", self.tabs )
    ents:SetPadding( 5 )
    ents:SetSpacing( 5 )
    for i,v in pairs( Entities.entities ) do
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
            self.highlighter = Entity:new( self.selectedentity )
            if self.highlighter:hasComponent( Components.drawable ) then
                self.highlighter:setColor( { 255, 255, 255, 155 } )
                self.highlighter:setLayer( 4 )
            end
        end
        ents:AddItem( temp )
    end
    self.tabs:AddTab( "Entities", ents )
    self.frame:SetResizable( true )
    self.frame.tabs = self.tabs
    self.frame.ents = ents
    self.frame.tool = self
    self.frame.OnResize = function( object, w, h )
        object.tabs:SetWidth( w-5 )
        object.tabs:SetHeight( h-32 )
        object.ents:SetWidth( w-14 )
        object.ents:SetHeight( h-64 )
        object.tool.widthmem = w
        object.tool.heightmem = h
    end
    self.frame:SetMinHeight( 100 )
    self.frame:SetMaxWidth( 2000 )
    self.frame:SetMaxHeight( 2000 )
end

function PaintTool:deinit()
    self.tabs:Remove()
    self.frame:Remove()
    if self.highlighter ~= nil then
        self.highlighter:remove()
        self.highlighter = nil
    end
end

function PaintTool:update( dt, x, y )
    self.posmem = Vector( self.frame:GetPos() )
    local mousepos = Vector( x, y )
    if self.highlighter ~= nil then
        self.highlighter:setPos( mousepos )
    end
    if self.painting and self.lastpos ~= Vector( x, y ) then
        self.lastpos = Vector( x, y )
        -- Here we check to make sure there's no nearby similar entites
        -- so we don't accidentally duplicate them
        local ents = World:getNearby( Vector( x, y ), 1 )
        for i,v in pairs( ents ) do
            if v.__name == self.selectedentity then
                return
            end
        end
        Entity:new( self.selectedentity, { pos=Vector( x, y ) } )
    end
end

function PaintTool:draw( x, y )
end

function PaintTool:mousepressed( x, y, button )
    if self.selectedentity == nil then
        return
    end
    if button == 'l' then
        self.painting = true
        if self.highlighter then
            self.highlighter:remove()
            self.highlighter = nil
        end
    end
end

function PaintTool:mousereleased( x, y, button )
    if self.selectedentity == nil then
        return
    end
    if button == 'l' then
        -- Respawn the highlighter
        if self.highlighter == nil then
            self.highlighter = Entity:new( self.selectedentity )
            if self.highlighter:hasComponent( Components.drawable ) then
                self.highlighter:setColor( { 255, 255, 255, 155 } )
                self.highlighter:setLayer( 4 )
            end
        end
        self.lastpos = nil
        self.painting = false
    end
end

return PaintTool
