local setGlowDrawable = function( e, object )
    self.glowdrawable = object
    self.gloworiginoffset = game.vector( self.glowdrawable:getWidth() / 2, self.glowdrawable:getHeight() / 2 )
end

local getGlowDrawable = function( e )
    return self.glowdrawable
end

local init = function( e )
    game.renderer:addGlowable( e )
end

local deinit = function( e )
    game.renderer:removeGlowable( e )
end

local Glows = {
    __name = "Glows",
    glowdrawable = love.graphics.newImage( "data/textures/null.png" ),
    gloworiginoffset = game.vector( 0, 0 ),
    init = init,
    deinit = deinit,
    setGlowDrawable = setGlowDrawable,
    getGlowDrawable = getGlowDrawable
}

return Glows
