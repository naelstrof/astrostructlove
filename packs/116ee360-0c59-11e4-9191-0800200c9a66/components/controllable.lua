
local update = function( e, dt, tick )
    -- Active runs is true when we're the active player being
    -- controlled by the client.
    -- tick is not nil when we're being ran in a simulation
    local controls = Network:getControls( e.playerid, tick )
    if ( e.active and controls ~= nil ) or ( tick ~= nil and controls ~= nil ) then
        local direction = 0

        -- Id will be specified if we're updating a specific player's
        -- entity, otherwise we're just updating ourselves
        local up, down, left, right
        -- We use tick to get the correct instance of the controls
        up, down, left, right = controls.up, controls.down, controls.left, controls.right

        if up - down == 0 and right - left == 0 then
            direction = Vector( 0, 0 )
        else
            direction = Vector( right - left, down - up ):normalized()
        end
        -- position
        local force = direction:rotated( e:getRot() ) * e:getSpeed()
        e:applyForce( force )
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
    -- If we don't have the required components we disable ourselves
    if not e:hasComponent( Components.physical ) and not e:hasComponent( Components.intangible ) then
        e.update = nil
        return
    end
    e.speed = e.speed * e.mass
    --e:setFixedRotation( true )
end

local setPlayerID = function( e, id )
    e.playerid = id
end

local Controllable = {
    __name = "Controllable",
    speed = 600,
    rotvelocity = 0,
    init = init,
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
    },
    setRotSpeed = setRotSpeed,
    getRotSpeed = getRotSpeed
}

return Controllable
