local setGlowDrawable = function( e, object )
    e.glowdrawable = object
    e.gloworiginoffset = game.vector( e.glowdrawable:getWidth() / 2, e.glowdrawable:getHeight() / 2 )
end

local getGlowDrawable = function( e )
    return e.glowdrawable
end

local init = function( e )
    e.glowdrawable = e.glowdrawable or love.graphics.newImage( "data/textures/null.png" )
    e.gloworiginoffset = game.vector( e.glowdrawable:getWidth() / 2, e.glowdrawable:getHeight() / 2 )
    game.renderer:addGlowable( e )
end

local deinit = function( e )
    game.renderer:removeGlowable( e )
end

local Glows = {
    __name = "Glows",
    glowdrawable = nil,
    gloworiginoffset = nil,
    init = init,
    deinit = deinit,
    setGlowDrawable = setGlowDrawable,
    getGlowDrawable = getGlowDrawable
}

return Glows
