
local update = function( e, dt, tick )
    -- Active runs is true when we're the active player being
    -- controlled by the client.
    -- tick is not nil when we're being ran in a simulation
    local controls = Network:getControls( e.playerid, tick )
    if ( e.active and controls ~= nil ) or ( tick ~= nil and controls ~= nil ) then
        local direction = 0
        local rotdir = 0

        -- Id will be specified if we're updating a specific player's
        -- entity, otherwise we're just updating ourselves
        local up, down, left, right, rotl, rotr
        -- We use tick to get the correct instance of the controls
        up, down, left, right = controls.up, controls.down, controls.left, controls.right
        rotl, rotr = controls.leanl, controls.leanr

        if up - down == 0 and right - left == 0 then
            direction = Vector( 0, 0 )
        else
            direction = Vector( right - left, down - up ):normalized()
        end
        local rotdir = rotr - rotl

        -- position
        local force = direction:rotated( e:getRot() ) * e:getSpeed()
        e.body:applyForce( force.x, force.y )
        -- rotation
        e.body:applyForce( rotdir * e:getRotSpeed(), 0, e.pos.x, e.pos.y-32 )
    end
    e.velocity = Vector( e.body:getLinearVelocity() )
end

local setVelocity = function( e, t )
    if not t.x or not t.y then
        error( "Cannot set velocity! Invalid arguments supplied." )
    end
    e.velocity = Vector( t.x, t.y )
    e.body:setLinearVelocity( t.x, t.y )
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
    e.velocity = Vector( e.velocity.x, e.velocity.y )
    -- If we don't have the required components we disable ourselves
    if not e:hasComponent( Components.physical ) and not e:hasComponent( Components.intangible ) then
        e.update = nil
        return
    end
    --e.body:setFixedRotation( true )
end

local setPlayerID = function( e, id )
    e.playerid = id
end

local Controllable = {
    __name = "Controllable",
    speed = 256,
    rotspeed = math.pi*8,
    velocity = Vector( 0, 0 ),
    rotvelocity = 0,
    init = init,
    friction = 0.02,
    rotfriction = 0.02,
    playerid = 0,
    update = update,
    setActive = setActive,
    setVelocity = setVelocity,
    setSpeed = setSpeed,
    getSpeed = getSpeed,
    setRotVel = setRotVel,
    getRotVel = getRotVel,
    setPlayerID = setPlayerID,
    networkinfo = {
        setActive = "active",
        setPlayerID = "playerid",
        setVelocity = "velocity"
    },
    setRotSpeed = setRotSpeed,
    getRotSpeed = getRotSpeed
}

return Controllable
