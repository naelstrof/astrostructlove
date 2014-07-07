-- Just a messy function trying to be OOP.
-- Offscreen is a boolean suggesting it needs to place the star offscreen
-- It will only work properly if the star has already moved offscreen (that's why the function is called respawnStar)
-- xaxis is to suggest which axis the star went offscreen on.
-- maxwidth is used to simplify calculations to tell how large a star could possibly be
local respawnStar = function( e, i, offscreen, xaxis, maxwidth )
    if e.stars[ i ] == nil then
        -- There's no need for this to be glowable, due to it being drawn to the space layer
        e.stars[i] = game.entity:new( "star" )
    end
    -- god the math for this is retarded because lua tables start at 1...
    e.stars[i]:setDrawable( e.starImages[ math.floor( love.math.random()*(table.maxn( e.starImages )-1) + 0.5 ) + 1 ] )
    e.stars[i]:setLayer( 1 )

    local w,h = love.graphics.getDimensions()
    -- Space layer isn't affected by camera, as such it doesn't need to take camera into account.
    if not offscreen then
        e.stars[i]:setPos( game.vector( w * love.math.random(), h * love.math.random() ) )
    else
        -- Place it off-screen in the way of our velocity
        if xaxis then
            e.stars[i]:setPos( game.vector( math.abs( e.stars[i]:getPos().x - ( e.width + maxwidth ) ), e.height * love.math.random() ) )
        else
            e.stars[i]:setPos( game.vector( e.width * love.math.random(), math.abs( e.stars[i]:getPos().y - ( e.height + maxwidth ) ) ) )
        end
    end
    local s = e.size + love.math.random() * e.sizeDeviation - love.math.random() * e.sizeDeviation
    e.stars[i]:setScale( game.vector( s, s ) )
end

local createStarfield = function( e )
    for i, v in pairs( e.stars ) do
        v:remove()
        e.stars[i] = nil
    end
    for i=1,e.maxStars,1 do
        e:respawnStar( i )
    end
    e.width = love.graphics.getWidth()
    e.height = love.graphics.getHeight()
end

local update = function( e, dt )
    -- Maxwidth is the max size of the stars, used to simplify calculations to detect if a star is offscreen
    local maxwidth = 30
    for i, v in pairs( e.stars ) do
        v:setPos( v:getPos() + ( e.vel * dt * v:getScale().x ) )
        -- Respawn stars that go off-screen
        local maxwidth = 30
        if v:getPos().x > e.width + maxwidth or v:getPos().x < -maxwidth then
            e:respawnStar( i, true, true, maxwidth )
        elseif v:getPos().y > e.height + maxwidth or v:getPos().y < -maxwidth then
            e:respawnStar( i, true, false, maxwidth )
        end
    end
end

local resize = function( e, w, h )
    -- Get the multipliers to change the star positions
    local xdiff =  w / e.width
    local ydiff =  h / e.height
    local multi = game.vector( xdiff, ydiff )
    for i, v in pairs( e.stars ) do
        v:setPos( v:getPos():permul( multi ) )
    end
    e.width = w
    e.height = h
end

local init = function( e )
    e:createStarfield()
end

local deinit = function( e )
    for i, v in pairs( e.stars ) do
        v:remove()
        e.stars[i] = nil
    end
end

local Starfield = {
    __name = "Starfield",
    stars = {},
    maxStars = 128,
    width = nil,
    height = nil,
    vel = game.vector( 25, 50 ),
    size = 0.5,
    sizeDeviation = 0.5,
    init = init,
    deinit = deinit,
    respawnStar = respawnStar,
    createStarfield = createStarfield,
    update = update,
    resize = resize,
    starImages = { love.graphics.newImage( "data/textures/star.png" ),
                   love.graphics.newImage( "data/textures/star2.png" ) }
}

return Starfield
