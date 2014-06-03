local ControlSystem = love.class( { entities = {}, activecontrol = nil } )

function ControlSystem:setActive( e )
    self.activecontrol = e
end

function ControlSystem:addEntity( e )
    table.insert( self.entities, e )
    e.controlsystemIndex = table.maxn( self.entities )
end

function ControlSystem:removeEntity( e )
    table.remove( self.entities, e.entitiesIndex )
    -- Have to update all the indicies of all the other entities.
    for i=e.controlsystemIndex, table.maxn( self.entities ), 1 do
        self.entities[i].controlsystemIndex = self.entities[i].controlsystemIndex - 1
    end
end

function ControlSystem:update( dt )
    moving = false
    direction = 0

    -- Keyboard controls
    up, down, left, right = love.keyboard.isDown( "w" ) and 1 or 0, love.keyboard.isDown( "s" ) and 1 or 0, love.keyboard.isDown( "a" ) and 1 or 0, love.keyboard.isDown( "d" ) and 1 or 0
    if up - down == 0 and right - left == 0 then
        direction = game.vector( 0, 0 )
    else
        moving = true
        direction = game.vector( right - left, down - up ):normalized()
    end

    -- TODO: Gamepad controls

    for i,v in pairs( self.entities ) do
        v:setVel( v:getVel() + direction * v:getSpeed() * dt )
        v:setPos( v:getPos() + v:getVel() )

        -- TODO: Ground-specific friction
        v:setVel( v:getVel() * math.pow( v.friction, dt ) )

        -- FIXME: Need proper friction calculations
        if v:getVel():len() < 1 then
            v:setVel( game.vector( 0, 0 ) )
        end

    end
end


return ControlSystem
