local setDrawable = function( e, object )
    e.drawable = object
    e.originoffset = game.vector( e.drawable:getWidth() / 2, e.drawable:getHeight() / 2 )
end

local getDrawable = function( e )
    return e.drawable
end

local setScale = function( e, x, y )
    if game.vector.isvector( x ) and y == nil then
        e.scale = x
    elseif x ~= nil and y ~= nil then
        e.scale = game.vector( x, y )
    else
        error( "Failed to set scale: Invalid parameters supplied!" )
    end
end

local getScale = function( e )
    return e.scale
end

local setColor = function( e, color )
    -- TODO: verify that this is a color
    e.color = color
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
    originoffset = game.vector( 32, 32 ),
    scale = game.vector( 1, 1 ),
    color = { 255, 255, 255, 255 },
    layer = 2,
    setDrawable = setDrawable,
    getDrawable = getDrawable,
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
