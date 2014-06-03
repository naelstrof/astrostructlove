local Drawable = compo.component:extends()

function Drawable:init( e )
    -- Set the default drawable to the classic purple and black
    -- checkerboard found in source games.
    e.drawable = love.graphics.newImage( "data/textures/null.png" )
    e.originoffset = game.vector( e.drawable:getWidth() / 2, e.drawable:getHeight() / 2 )
    e.scale = game.vector( 1, 1 )
    e.color = { 255, 255, 255, 255 }
    e.layer = 0

    e.setDrawable = function( e, object )
        e.drawable = object
        e.originoffset = game.vector( e.drawable:getWidth() / 2, e.drawable:getHeight() / 2 )
    end

    e.getDrawable = function( e )
        return e.drawable
    end

    e.setScale = function( e, scale )
        e.scale = scale
    end

    e.getScale = function( e )
        return e.scale
    end

    e.setColor = function( e, color )
        --TODO: verify that this is a color
        e.color = color
    end

    e.getColor = function( e, color )
        return e.color
    end

    e.setLayer = function( e, l )
        game.renderer:removeEntity( e )
        e.layer = l
        game.renderer:addEntity( e )
    end

    e.getLayer = function( e )
        return e.layer
    end

    game.renderer:addEntity( e )
end

function Drawable:deinit( e )
    e.setDrawable = nil
    e.getDrawable = nil
    e.setScale = nil
    e.getScale = nil
    e.setColor = nil
    e.getColor = nil
    e.setLayer = nil
    e.getLayer = nil
    e.drawable = nil
    e.scale = nil
    e.color = nil
    game.renderer:removeEntity( e )
end

return Drawable
