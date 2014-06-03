local Controllable = compo.component:extends()

function Controllable:init( e )
    e.speed = 128
    e.velocity = game.vector( 0, 0 )
    e.friction = 0.00001

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
