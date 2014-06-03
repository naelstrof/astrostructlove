local Controllable = compo.component:extends()

function Controllable:init( e )
    e.speed = 2048
    e.rotspeed = math.pi*3
    e.velocity = game.vector( 0, 0 )
    e.rotvelocity = 0
    e.friction = 0.01
    e.rotfriction = 0.01

    e.setSpeed = function( e, speed )
        e.speed = speed
    end

    e.getSpeed = function( e )
        return e.speed
    end

    e.setVel = function( e, velocity )
        e.velocity = velocity
    end

    e.getVel = function( e )
        return e.velocity
    end

    e.setRotSpeed = function( e, rotspeed )
        e.rotspeed = rotspeed
    end

    e.getRotSpeed = function( e )
        return e.rotspeed
    end
    e.setRotVel = function( e, rotvelocity )
        e.rotvelocity = rotvelocity
    end

    e.getRotVel = function( e )
        return e.rotvelocity
    end
    game.controlsystem:addEntity( e )
end

function Controllable:deinit( e )
    e.setSpeed = nil
    e.getSpeed = nil
    e.setVel = nil
    e.getVel = nil
    game.controlsystem:removeEntity( e )
end

return Controllable
