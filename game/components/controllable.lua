
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

    -- TODO: Gamepad controls
        --e:setRotVel( e:getRotVel() + rotdir * e:getRotSpeed() * dt )

        --e:setVel( e:getVel() + direction:rotated( e:getRot() ) * e:getSpeed() * dt )
        e:setRotVel( rotdir * e:getRotSpeed() )

        e:setVel( direction:rotated( e:getRot() ) * e:getSpeed() )
    end
    e:setPos( e:getPos() + e:getVel() * dt )
    e:setRot( e:getRot() + e:getRotVel() * dt )

    -- TODO: Ground-specific friction
    --e:setVel( e:getVel() * math.pow( e.friction, dt ) )
    --e:setRotVel( e:getRotVel() * math.pow( e.rotfriction, dt ) )

    -- FIXME: Need proper friction calculations
    --if e:getVel():len() < 1 then
        --e:setVel( game.vector( 0, 0 ) )
    --end
end

local setSpeed = function( e, speed )
    e.speed = speed
end

local getSpeed = function( e )
    return e.speed
end

local setVel = function( e, velocity )
    e.velocity = velocity
end

local getVel = function( e )
    return e.velocity
end

local setRotSpeed = function( e, rotspeed )
    e.rotspeed = rotspeed
end

local getRotSpeed = function( e )
    return e.rotspeed
end

local setRotVel = function( e, rotvelocity )
    e.rotvelocity = rotvelocity
end

local setActive = function( e, active )
    e.active = active
end

local getRotVel = function( e )
    return e.rotvelocity
end

local init = function( e )
    e.velocity = game.vector( e.velocity.x, e.velocity.y )
end

local Controllable = {
    __name = "Controllable",
    speed = 256,
    rotspeed = math.pi,
    velocity = { x = 0, y = 0 },
    rotvelocity = 0,
    init = init,
    friction = 0.01,
    rotfriction = 0.01,
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
