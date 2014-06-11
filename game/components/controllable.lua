
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

local getRotVel = function( e )
    return e.rotvelocity
end

local init = function( e )
    game.controlsystem:addEntity( e )
end

local deinit = function( e )
    game.controlsystem:removeEntity( e )
end

local Controllable = {
    __name = "Controllable",
    speed = 2048,
    rotspeed = math.pi*3,
    velocity = game.vector( 0, 0 ),
    rotvelocity = 0,
    friction = 0.01,
    rotfriction = 0.01,
    init = init,
    deinit = deinit,
    setVel = setVel,
    getVel = getVel,
    setSpeed = setSpeed,
    getSpeed = getSpeed,
    setRotVel = setRotVel,
    getRotVel = getRotVel,
    setRotSpeed = setRotSpeed,
    getRotSpeed = getRotSpeed
}

return Controllable
