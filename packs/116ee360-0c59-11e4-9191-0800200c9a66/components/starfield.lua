local Starfield = {
    __name = "Starfield",
    stars = {},
    maxStars = 128,
    width = nil,
    height = nil,
    vel = Vector( 25, 50 ),
    size = 0.5,
    sizeDeviation = 0.5,
    starImages = { love.graphics.newImage( PackLocation .. "textures/star.png" ),
                   love.graphics.newImage( PackLocation .. "textures/star2.png" ) }
}

-- Just a messy function trying to be OOP.
-- Offscreen is a boolean suggesting it needs to place the star offscreen
-- It will only work properly if the star has already moved offscreen (that's why the function is called respawnStar)
-- xaxis is to suggest which axis the star went offscreen on.
-- maxwidth is used to simplify calculations to tell how large a star could possibly be
function Starfield:respawnStar( i, offscreen, xaxis, maxwidth )
    if self.stars[ i ] == nil then
        -- There's no need for this to be glowable, due to it being drawn to the space layer
        self.stars[i] = Entity:new( "star" )
    end
    -- god the math for this is retarded because lua tables start at 1...
    self.stars[i]:setDrawable( self.starImages[ math.floor( love.math.random()*(table.maxn( self.starImages )-1) + 0.5 ) + 1 ] )
    self.stars[i]:setLayer( "space" )

    local w,h = love.graphics.getDimensions()
    -- Space layer isn't affected by camera, as such it doesn't need to take camera into account.
    if not offscreen then
        self.stars[i]:setPos( Vector( w * love.math.random(), h * love.math.random() ) )
    else
        -- Place it off-screen in the way of our velocity
        if xaxis then
            self.stars[i]:setPos( Vector( math.abs( self.stars[i]:getPos().x - ( self.width + maxwidth ) ), self.height * love.math.random() ) )
        else
            self.stars[i]:setPos( Vector( self.width * love.math.random(), math.abs( self.stars[i]:getPos().y - ( self.height + maxwidth ) ) ) )
        end
    end
    local s = self.size + love.math.random() * self.sizeDeviation - love.math.random() * self.sizeDeviation
    self.stars[i]:setScale( Vector( s, s ) )
end

function Starfield:createStarfield()
    for i, v in pairs( self.stars ) do
        v:remove()
        self.stars[i] = nil
    end
    for i=1,self.maxStars,1 do
        self:respawnStar( i )
    end
    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()
end

function Starfield:update( dt )
    -- Maxwidth is the max size of the stars, used to simplify calculations to detect if a star is offscreen
    local maxwidth = 30
    for i, v in pairs( self.stars ) do
        v:setPos( v:getPos() + ( self.vel * dt * v:getScale().x ) )
        -- Respawn stars that go off-screen
        local maxwidth = 30
        if v:getPos().x > self.width + maxwidth or v:getPos().x < -maxwidth then
            self:respawnStar( i, true, true, maxwidth )
        elseif v:getPos().y > self.height + maxwidth or v:getPos().y < -maxwidth then
            self:respawnStar( i, true, false, maxwidth )
        end
    end
end

function Starfield:resize( w, h )
    -- Get the multipliers to change the star positions
    local xdiff =  w / self.width
    local ydiff =  h / self.height
    local multi = Vector( xdiff, ydiff )
    for i, v in pairs( self.stars ) do
        v:setPos( v:getPos():permul( multi ) )
    end
    self.width = w
    self.height = h
end

function Starfield:init()
    self:createStarfield()
end

function Starfield:deinit()
    for i, v in pairs( self.stars ) do
        v:remove()
        self.stars[i] = nil
    end
end

return Starfield
