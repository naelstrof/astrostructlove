
local update = function( e, dt, tick )
    -- Active runs is true when we're the active player being
    -- controlled by the client.
    -- tick is not nil when we're being ran in a simulation
    if e.active or ( tick ~= nil and game.network:getControls( e.playerid, tick ) ~= nil ) then
        local direction = 0
        local rotdir = 0

        -- Id will be specified if we're updating a specific player's
        -- entity, otherwise we're just updating ourselves
        local up, down, left, right, rotl, rotr
        -- We use tick to get the correct instance of the controls
        up, down, left, right = game.network:getControls( e.playerid, tick ).up, game.network:getControls( e.playerid, tick ).down, game.network:getControls( e.playerid, tick ).left, game.network:getControls( e.playerid, tick ).right
        rotl, rotr = game.network:getControls( e.playerid, tick ).leanl, game.network:getControls( e.playerid, tick ).leanr

        if up - down == 0 and right - left == 0 then
            direction = game.vector( 0, 0 )
        else
            direction = game.vector( right - left, down - up ):normalized()
        end
        local rotdir = rotr - rotl

        -- position
        local force = direction:rotated( e:getRot() ) * e:getSpeed()
        e.body:applyForce( force.x, force.y )
        -- rotation
        e.body:applyForce( rotdir * e:getRotSpeed(), 0, e.pos.x, e.pos.y-32 )

        -- position friction
        local moveangle = game.vector( e.body:getLinearVelocity() ):normalized()
        local normal = e.body:getMass() * game.physics.gravity
        local ents = game.entities:getNearby( e:getPos(), 24 )
        local frictioncoefficient
        -- We want to keep ghosts from flying off into space
        if e:hasComponent( compo.intangible ) then
            frictioncoefficient = 0.8
            -- FIXME: By making compo.intangible be less dumb
            -- so we don't have to manually set values to abide by
            -- my bad physics calculations
            -- The only reason I override the normal value
            -- is because applying force at an angle on compo.intangible
            -- doesn't work the same way as applying force at an angle
            -- on a compo.physical
            normal = 90
        else
            frictioncoefficient = 0
        end
        -- FIXME: Maybe average the friction coefficients?
        for i,v in pairs( ents ) do
            if v:hasComponent( compo.floor ) then
                frictioncoefficient = v.frictioncoefficient
                break
            end
        end
        local frictionforce = ( -moveangle * normal * frictioncoefficient )
        e.body:applyForce( frictionforce.x, frictionforce.y )
        -- rotation friction
        e.body:applyForce( -e.body:getAngularVelocity() * (normal/4) * frictioncoefficient, 0, e.pos.x, e.pos.y-32 )
        --e.body:setAngularDamping( 5 )
    end
end

local setSpeed = function( e, speed )
    e.speed = speed
end

local getSpeed = function( e )
    return e.speed
end

local setRotSpeed = function( e, rotspeed )
    e.rotspeed = rotspeed
end

local getRotSpeed = function( e )
    return e.rotspeed
end

local setActive = function( e, active )
    e.active = active
end

local init = function( e )
    -- Since we aren't networking velocity, it can be overridden as a
    -- plain table. To fix this we just convert it back to a vector
    -- whenever we initialize.
    e.velocity = game.vector( e.velocity.x, e.velocity.y )
    -- If we don't have the required components we disable ourselves
    if not e:hasComponent( compo.physical ) and not e:hasComponent( compo.intangible ) then
        e.update = nil
        return
    end
end

local Controllable = {
    __name = "Controllable",
    speed = 256,
    rotspeed = math.pi*4,
    velocity = game.vector( 0, 0 ),
    rotvelocity = 0,
    init = init,
    friction = 0.02,
    rotfriction = 0.02,
    playerid = 0,
    --init = init,
    --deinit = deinit,
    update = update,
    setActive = setActive,
    setVel = setVel,
    getVel = getVel,
    setSpeed = setSpeed,
    getSpeed = getSpeed,
    setRotVel = setRotVel,
    getRotVel = getRotVel,
    networkedvars = { "active" },
    networkedfunctions = { "setActive" },
    setRotSpeed = setRotSpeed,
    getRotSpeed = getRotSpeed
}

return Controllable
