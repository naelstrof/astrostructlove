local ControlSystem = common.class( { entities = {}, activecontrol = nil } )

function ControlSystem:setActive( e )
    self.activecontrol = e
end

function ControlSystem:addEntity( e )
    table.insert( self.entities, e )
    e.controlsystemIndex = table.maxn( self.entities )
end

function ControlSystem:removeEntity( e )
    table.remove( self.entities, e.controlsystemIndex )
    -- Have to update all the indicies of all the other entities.
    for i=e.controlsystemIndex, table.maxn( self.entities ), 1 do
        self.entities[i].controlsystemIndex = self.entities[i].controlsystemIndex - 1
    end
end

function ControlSystem:update( dt )
    direction = 0
    rotdir = 0

    -- Keyboard controls
    local up, down, left, right = control.current.up, control.current.down, control.current.left, control.current.right
    local rotl, rotr = control.current.leanl, control.current.leanr

    if up - down == 0 and right - left == 0 then
        direction = game.vector( 0, 0 )
    else
        direction = game.vector( right - left, down - up ):normalized()
    end
    local rotdir = rotr - rotl

    -- TODO: Gamepad controls
    for i,v in pairs( self.entities ) do
        if v == self.activecontrol then
            v:setRotVel( v:getRotVel() + rotdir * v:getRotSpeed() * dt )

            v:setVel( v:getVel() + direction:rotated( v:getRot() ) * v:getSpeed() * dt )
        end
        v:setPos( v:getPos() + v:getVel() * dt )
        v:setRot( v:getRot() + v:getRotVel() * dt )

        -- TODO: Ground-specific friction
        v:setVel( v:getVel() * math.pow( v.friction, dt ) )
        v:setRotVel( v:getRotVel() * math.pow( v.rotfriction, dt ) )

        -- FIXME: Need proper friction calculations
        if v:getVel():len() < 1 then
            v:setVel( game.vector( 0, 0 ) )
        end
    end

end


return ControlSystem
