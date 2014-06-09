local Starfield = compo.component:extends()

function Starfield:init( e )
    e.stars = {}
    e.maxStars = 64
    e.vel = game.vector( 2.5, 0.5 )
    e.size = 0.5
    e.sizeDeviation = 0.5
    e.starImages = { love.graphics.newImage( "data/textures/star.png" ),
                     love.graphics.newImage( "data/textures/star2.png" ) }
    e.createStarfield = function( e )
        for i, v in pairs( e.stars ) do
            v:remove()
            e.stars[i] = nil
        end
        for i=1,e.maxStars,1 do
            -- There's no need for this to be glowable, due to it being drawn to the space layer
            e.stars[i] = game.entity( { compo.drawable } )
            -- god the math for this is retarded because lua tables start at 1...
            e.stars[i]:setDrawable( e.starImages[ math.floor( math.random()*(table.maxn( e.starImages )-1) + 0.5 ) + 1 ] )
            e.stars[i]:setLayer( 1 )

            local w,h = love.graphics.getDimensions()
            -- Space layer isn't affected by camera, as such it doesn't need to take camera into account.
            e.stars[i]:setPos( game.vector( w * math.random(), h * math.random() ) )
            local s = e.size + math.random() * e.sizeDeviation - math.random() * e.sizeDeviation
            e.stars[i]:setScale( game.vector( s, s ) )
        end
    end

    e.updateStarfield = function( e, dt )
        for i, v in pairs( e.stars ) do
            v:setPos( v:getPos() + ( e.vel * dt * v:getScale().x ) )
        end
    end
    game.starsystem:addStarfield( e )
end

function Starfield:deinit( e )
    game.starsystem:removeStarfield( e )
end

return Starfield
