local setGlowDrawable = function( e, object )
    e.glowdrawable = object
    e.gloworiginoffset = Vector( e.glowdrawable:getWidth() / 2, e.glowdrawable:getHeight() / 2 )
end

local getGlowDrawable = function( e )
    return e.glowdrawable
end

local init = function( e )
    e.gloworiginoffset = Vector( e.glowdrawable:getWidth() / 2, e.glowdrawable:getHeight() / 2 )
    Renderer:addGlowable( e )
end

local deinit = function( e )
    Renderer:removeGlowable( e )
end

local Glows = {
    __name = "Glows",
    glowdrawable = love.graphics.newImage( PackLocation .. "textures/null.png" ),
    gloworiginoffset = nil,
    init = init,
    deinit = deinit,
    setGlowDrawable = setGlowDrawable,
    getGlowDrawable = getGlowDrawable
}

return Glows
