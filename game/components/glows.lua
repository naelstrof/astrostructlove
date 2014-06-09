local Glows = compo.component:extends()

function Glows:init( e )
    e.glowdrawable = e.glowdrawable or love.graphics.newImage( "data/textures/null.png" )
    e.gloworiginoffset = game.vector( e.glowdrawable:getWidth() / 2, e.glowdrawable:getHeight() / 2 )

    e.setGlowDrawable = function( e, object )
        e.glowdrawable = object
        e.gloworiginoffset = game.vector( e.glowdrawable:getWidth() / 2, e.glowdrawable:getHeight() / 2 )
    end

    e.getGlowDrawable = function( e )
        return e.glowdrawable
    end

    game.renderer:addGlowable( e )
end

function Glows:deinit( e )
    e.glowdrawable = nil
    e.gloworiginoffset = nil
    e.setGlowDrawable = nil
    e.getGlowDrawable = nil
    game.renderer:removeGlowable( e )
end

return Glows
