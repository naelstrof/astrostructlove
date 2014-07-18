local update = function( e, dt )
    if e.sleeping then
        return
    end
    -- Gravity force
    local gravity = e.mass * e.gravity
    -- Normal and Friction force
    local normal
    local friction
    if e.height <= 0 then
        normal = -gravity
        -- Try to find some floors
        -- Default friction coefficient is 0
        local frictioncoefficient = 0
        local ents = World:getNearby( e:getPos(), 24 )
        for i,v in pairs( ents ) do
            if v:hasComponent( Components.floor ) then
                frictioncoefficient = v.frictioncoefficient
                -- If we found a floor, make sure we didn't fall through it
                e.height = 0
                break
            end
        end
        -- Friction = μ*Normal force
        friction = normal * frictioncoefficient
    else
        normal = 0
        friction = 0
    end
    -- Friction applied in opposite movement direction
    e:applyForce( e.velocity:normalized() * friction )
    -- a = F/m
    e.accel = e.forces / e.mass
    e.haccel = e.hforces + ( gravity + normal ) / e.mass

    e.velocity = e.velocity + e.accel * dt
    e.hvelocity = e.hvelocity + e.haccel * dt

    -- Enforce max velocity
    if e.velocity:len() > e.maxvelocity then
        e.velocity = e.velocity:normalized() * e.maxvelocity
    end

    e:setPos( e:getPos() + e.velocity * dt )
    e.height = e.height + e.hvelocity * dt
    -- Reset any forces already applied
    e.forces = Vector( 0, 0 )
end

local applyForce = function( e, f, h )
    e.sleeping = false
    e.forces = e.forces + f
    h = h or 0
    e.hforces = e.hforces + h
end

local setVelocity = function( e, v )
    if not v.x and not v.y then
        error( "Wrong parameter supplied!" )
    end
    e.velocity = v
end

local Physical = {
    __name = "Physical",
    -- Units per second
    maxvelocity = 356,
    static = true,
    shape = nil,
    mass = 70,
    height = 0,
    hforces = 0,
    haccel = 0,
    velocity = Vector( 0, 0 ),
    hvelocity = 0,
    accel = Vector( 0, 0 ),
    gravity = 9.81,
    forces = Vector( 0, 0 ),
    sleeping = true,
    update = update,
    setVelocity = setVelocity,
    applyForce = applyForce,
    networkinfo = {
        setVelocity = "velocity"
    }
}

return Physical
