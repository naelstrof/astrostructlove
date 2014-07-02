local createStarfield = function( e )
    -- We grab any stars that exist still
    local stars = game.entities:getAllNamed( "star" )
    if table.getn( stars ) ~= nil then
        e.stars = stars
    end
    --for i, v in pairs( e.stars ) do
        --v:remove()
        --e.stars[i] = nil
    --end
    for i=1,e.maxStars,1 do
        if e.stars[i] == nil then
            -- There's no need for this to be glowable, due to it being drawn to the space layer
            e.stars[i] = game.entity:new( "star" )
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
    e.width = love.graphics.getWidth()
    e.height = love.graphics.getHeight()
end

local update = function( e, dt )
    for i, v in pairs( e.stars ) do
        v:setPos( v:getPos() + ( e.vel * dt * v:getScale().x ) )
        -- Respawn stars that go off-screen
        local maxwidth = 30
        if v:getPos().x > e.width + maxwidth or v:getPos().x < -maxwidth then
            v:setDrawable( e.starImages[ math.floor( math.random()*(table.maxn( e.starImages )-1) + 0.5 ) + 1 ] )
            local s = e.size + math.random() * e.sizeDeviation - math.random() * e.sizeDeviation
            v:setScale( game.vector( s, s ) )
            v:setPos( game.vector( math.abs( v:getPos().x - ( e.width + maxwidth ) ), e.height * math.random() ) )
        elseif v:getPos().y > e.height + maxwidth or v:getPos().y < -maxwidth then
            v:setDrawable( e.starImages[ math.floor( math.random()*(table.maxn( e.starImages )-1) + 0.5 ) + 1 ] )
            local s = e.size + math.random() * e.sizeDeviation - math.random() * e.sizeDeviation
            v:setScale( game.vector( s, s ) )
            v:setPos( game.vector( e.width * math.random(), math.abs( v:getPos().y - ( e.height + maxwidth ) ) ) )
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
    e.vel = game.vector( e.vel.x, e.vel.y )
    local t = {}
    for i,v in pairs( e.starImages ) do
        table.insert( t, love.graphics.newImage( v ) )
    end
    e.starImages = t
    e:createStarfield()
end

local deinit = function( e )
    -- To allow for recreation (networking) of this entity without affecting
    -- the stars, we simply leave the stars out.
    -- createStarfield() will pick them back up when the entity
    -- is created again.
    -- for i, v in pairs( e.stars ) do
        -- v:remove()
        -- e.stars[i] = nil
    -- end
end

local Starfield = {
    __name = "Starfield",
    stars = {},
    maxStars = 128,
    width = nil,
    height = nil,
    vel = { x=25, y=50 },
    size = 0.5,
    sizeDeviation = 0.5,
    init = init,
    deinit = deinit,
    createStarfield = createStarfield,
    update = update,
    resize = resize,
    starImages = { "data/textures/star.png",
                   "data/textures/star2.png" }
}

return Starfield
