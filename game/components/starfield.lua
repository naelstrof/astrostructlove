local Starfield = compo.component:extends()

function Starfield:init( e )
    e.stars = {}
    e.maxStars = 32
    e.vel = game.vector( 1, 0 )
    e.sizeDeviation = 2
    e.starImages = { love.graphics.newImage( "data/textures/star.png" ),
                     love.graphics.newImage( "data/textures/star2.png" ) }
    e.createStarfield = function( e )
        for i, v in pairs( e.stars ) do
            v:remove()
            e.stars[i] = nil
        end
        for i=1,e.maxStars,1 do
            e.stars[i] = game.entity( { compo.drawable } )
            -- god the math for this is retarded because lua tables start at 1...
            e.stars[i]:setDrawable( e.starImages[ math.floor( math.random()*(table.maxn( e.starImages )-1) + 0.5 ) + 1 ] )

            local w,h = love.graphics.getDimensions()
            e.stars[i]:setPos( game.vector( w * math.random(), h * math.random() ) + game.camerasystem:getPos() - game.vector( w/2, h/2 ) )
            local s = 1 + math.random() * e.sizeDeviation - math.random() * e.sizeDeviation
            e.stars[i]:setScale( game.vector( s, s ) )
        end
    end

    e.updateStarfield = function( e, dt )
        for i, v in pairs( e.stars ) do
            v:setPos( v:getPos() + ( e.vel * dt ) * v:getScale().x )
        end
    end
    game.starsystem:addStarfield( e )
end

function Starfield:deinit( e )
    game.starsystem:removeStarfield( e )
end

return Starfield
