local Physical = {
    __name = "Physical",
    velocity = Vector( 0, 0 ),
    physicstype = "static",
    networkinfo = {
        setLinearVelocity = "velocity"
    }
}

function Physical:init()
    self.mass = self.mass or 70
    self.body = self.body or love.physics.newBody( Physics.world, self.pos.x, self.pos.y, self.physicstype )
    self.shape = self.shape or love.physics.newRectangleShape( 64, 64 )
    if not self.body or not self.shape then
        error( "Whoa! Physical object was being created without a body, or maybe without a shape. Eitherway it's a fatal error." )
    end
    self.fixture = love.physics.newFixture( self.body, self.shape )
    self.velocity = Vector( self.velocity.x, self.velocity.y )
    self.body:setMass( self.mass )
    self.friction = self.friction or love.physics.newFrictionJoint( Physics.null, self.body, self.pos.x, self.pos.y, false )
    self.friction:setMaxForce( 2 * self.mass )
    self.friction:setMaxTorque( 0 )
end

function Physical:setPos( t, byme )
    if not t.x or not t.y then
        error( "Invalid parameters provided" )
    end
    -- We need to know who called it, because we could just be
    -- getting our positions updated by the body moving.
    if not byme then
        self.body:setPosition( t.x, t.y )
    end
end

function Physical:update( dt )
    if self.physicstype == "dynamic" then
        local x, y = self.body:getPosition()
        self:setPos( Vector( x, y ), true )
        local vx, vy = self.body:getLinearVelocity()
        self.velocity = Vector( vx, vy )
    end
end

function Physical:applyForce( f, p )
    if not p then
        self.body:applyForce( f.x, f.y )
    else
        self.body:applyForce( f.x, f.y, p.x, p.y )
    end
end

function Physical:setForces( v )
    error( "unimplemented" )
end

function Physical:setLinearVelocity( v )
    if not v.x or not v.y then
        error( "Invalid parameters provided" )
    end
    self.body:setLinearVelocity( v.x, v.y )
end

function Physical:setFixedRotation( fixed )
    self.body:setFixedRotation( fixed )
end

return Physical
