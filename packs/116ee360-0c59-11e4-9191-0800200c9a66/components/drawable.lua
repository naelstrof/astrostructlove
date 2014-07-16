local setDrawable = function( e, object ) e.drawable = object
    e.originoffset = Vector( e.drawable:getWidth() / 2, e.drawable:getHeight() / 2 )
end

local getDrawable = function( e )
    return e.drawable
end

local setScale = function( e, t )
    if t == nil or t.x == nil or t.y == nil then
        error( "Failed to set scale: Invalid parameters supplied!" )
    end
    e.scale = Vector( t.x, t.y )
end

local getScale = function( e )
    return e.scale
end

local setColor = function( e, color )
    local r = color[ 1 ]
    local g = color[ 2 ]
    local b = color[ 3 ]
    local a = color[ 4 ]
    if r and g and b and not a then
        e.color = { r, g, b, 255 }
    elseif r and g and b and a then
        e.color = color
    else
        error( "Failed to set color: rgba components in a table required!" )
    end
end

local getColor = function( e )
    return e.color
end

local setLayer = function( e, l )
    if e.layer == l then
        return
    end
    Renderer:removeEntity( e )
    e.layer = l
    Renderer:addEntity( e )
end

local getLayer = function( e )
    return e.layer
end

local init = function( e )
    e.originoffset = Vector( e.drawable:getWidth() / 2, e.drawable:getHeight() / 2 )
    Renderer:addEntity( e )
end

local deinit = function( e )
    Renderer:removeEntity( e )
end

local Drawable = {
    __name = "Drawable",
    -- Set the default drawable to the classic purple and black
    -- checkerboard found in source games.
    drawable = love.graphics.newImage( PackLocation .. "textures/null.png" ),
    originoffset = nil,
    scale = Vector( 1, 1 ),
    color = { 255, 255, 255, 255 },
    layer = 2,
    setDrawable = setDrawable,
    getDrawable = getDrawable,
    networkinfo = {
        setScale = "scale",
        setColor = "color"
    },
    setScale = setScale,
    getScale = getScale,
    setColor = setColor,
    getColor = getColor,
    setLayer = setLayer,
    getLayer = getLayer,
    init = init,
    deinit = deinit
}

return Drawable
