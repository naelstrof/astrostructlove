local Intangible = {
    __name = "Intangible",
    -- Units per second
    maxvelocity = 300,
    static = true,
    shape = nil,
    mass = 70,
    velocity = Vector( 0, 0 ),
    accel = Vector( 0, 0 ),
    gravity = 9.81,
    forces = Vector( 0, 0 ),
    sleeping = true,
    networkinfo = {
        setLinearVelocity = "velocity"
    }
}

function Intangible:update( dt )
    if self.sleeping then
        return
    end
    -- Gravity force
    local gravity = self.mass * self.gravity
    -- Normal and Friction force
    local normal
    local friction
    normal = -gravity
    -- Try to find some floors
    -- Default friction coefficient is 8 for intangibles
    local frictioncoefficient = 20
    local ents = World:getNearby( self:getPos(), 24 )
    for i,v in pairs( ents ) do
        if v:hasComponent( Components.floor ) then
            frictioncoefficient = v.frictioncoefficient
            -- If we found a floor, make sure we didn't fall through it
            self.height = 0
            break
        end
    end
    -- Friction = μ*Normal force
    friction = normal * frictioncoefficient
    -- Friction applied in opposite movement direction
    self:applyForce( self.velocity:normalized() * friction )
    -- a = F/m
    self.accel = self.forces / self.mass

    self.velocity = self.velocity + self.accel * dt

    -- Enforce max velocity
    if self.velocity:len() > self.maxvelocity then
        self.velocity = self.velocity:normalized() * self.maxvelocity
    end

    self:setPos( self:getPos() + self.velocity * dt )
    -- Reset any forces already applied
    self.forces = Vector( 0, 0 )
end

function Intangible:getMass()
    return self.mass
end

function Intangible:applyForce( f )
    self.sleeping = false
    self.forces = self.forces + f
end

function Intangible:getLinearVelocity()
    return self.velocity
end

function Intangible:setLinearVelocity( v )
    if not v.x and not v.y then
        error( "Wrong parameter supplied!" )
    end
    self.velocity = Vector( v.x, v.y )
end

function Intangible:setFixedRotation( fixed )
end

return Intangible
