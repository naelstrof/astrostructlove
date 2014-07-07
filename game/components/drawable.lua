local setDrawable = function( e, object ) e.drawable = object
    e.originoffset = game.vector( e.drawable:getWidth() / 2, e.drawable:getHeight() / 2 )
end

local getDrawable = function( e )
    return e.drawable
end

local setScale = function( e, t )
    if t == nil or t.x == nil or t.y == nil then
        error( "Failed to set scale: Invalid parameters supplied!" )
    end
    e.scale = game.vector( t.x, t.y )
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
    game.renderer:removeEntity( e )
    e.layer = l
    game.renderer:addEntity( e )
end

local getLayer = function( e )
    return e.layer
end

local init = function( e )
    e.originoffset = game.vector( e.drawable:getWidth() / 2, e.drawable:getHeight() / 2 )
    game.renderer:addEntity( e )
end

local deinit = function( e )
    game.renderer:removeEntity( e )
end

local Drawable = {
    __name = "Drawable",
    -- Set the default drawable to the classic purple and black
    -- checkerboard found in source games.
    drawable = love.graphics.newImage( "data/textures/null.png" ),
    originoffset = nil,
    scale = game.vector( 1, 1 ),
    color = { 255, 255, 255, 255 },
    layer = 2,
    setDrawable = setDrawable,
    getDrawable = getDrawable,
    networkedvars = { "scale", "color" },
    networkedfunctions = { "setScale", "setColor" },
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
