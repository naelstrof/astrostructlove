local Drawable = {
    __name = "Drawable",
    -- Set the default drawable to the classic purple and black
    -- checkerboard found in source games.
    drawable = love.graphics.newImage( PackLocation .. "textures/null.png" ),
    originoffset = nil,
    scale = Vector( 1, 1 ),
    color = { 255, 255, 255, 255 },
    layer = "normal",
    networkinfo = {
        setScale = "scale",
        setColor = "color"
    }
}

function Drawable:setDrawable( object )
    self.drawable = object
    self.originoffset = Vector( self.drawable:getWidth() / 2, self.drawable:getHeight() / 2 )
end

function Drawable:getDrawable()
    return self.drawable
end

function Drawable:setScale( t )
    if t == nil or t.x == nil or t.y == nil then
        error( "Failed to set scale: Invalid parameters supplied!" )
    end
    self.scale = Vector( t.x, t.y )
end

function Drawable:getScale()
    return self.scale
end

function Drawable:setColor( color )
    local r = color[ 1 ]
    local g = color[ 2 ]
    local b = color[ 3 ]
    local a = color[ 4 ]
    if r and g and b and not a then
        self.color = { r, g, b, 255 }
    elseif r and g and b and a then
        self.color = color
    else
        error( "Failed to set color: rgba components in a table required!" )
    end
end

function Drawable:getColor()
    return self.color
end

function Drawable:setLayer( l )
    if self.layer == l then
        return
    end
    Renderer:removeEntity( self )
    self.layer = l
    Renderer:addEntity( self )
end

function Drawable:getLayer()
    return self.layer
end

function Drawable:init()
    self.originoffset = self.originoffset or Vector( self.drawable:getWidth() / 2, self.drawable:getHeight() / 2 )
    Renderer:addEntity( self )
end

function Drawable:deinit()
    Renderer:removeEntity( self )
end

return Drawable
