local Controllable = {
    __name = "Controllable",
    speed = 5,
    maxspeed = 500,
    rotvelocity = 0,
    playerid = 0,
    localplayer = false,
    controlsnapshots = {},
    networkinfo = {
        setPlayerID = "playerid"
    }
}

function Controllable:update( dt, totaltime )
    if dt < 0 then
        return
    end
    local controls = self:getControls( totaltime )
    local direction = 0
    local up, down, left, right
    up, down, left, right = controls.up, controls.down, controls.left, controls.right

    if up - down == 0 and right - left == 0 then
        direction = Vector( 0, 0 )
    else
        direction = Vector( right - left, down - up ):normalized()
    end
    -- There's no need for rotation adjustment, because players can't rotate.
    --local force = direction:rotated( self:getRot() ) * self:getSpeed()
    local force = direction * self:getSpeed()
    -- We can't run faster than our max speed.
    if ( self:getLinearVelocity() + force / self:getMass() ):len() < self.maxspeed then
        self:applyForce( force * dt )
    end
end

function Controllable:setSpeed( speed )
    self.speed = speed
end

function Controllable:getSpeed()
    return self.speed
end

function Controllable:setRotSpeed( rotspeed )
    self.rotspeed = rotspeed
end

function Controllable:setLocalPlayer( bool )
    self.localplayer = bool
end

function Controllable:getRotSpeed()
    return self.rotspeed
end

function Controllable:addControlSnapshot( controls, time )
    -- We need to keep our control snapshots very organized and flexible,
    -- so we package up the controls and the time together
    -- for a more orderly array of snapshots.
    local t = {
        controls=controls,
        time=time
    }
    -- We insert it into the table
    table.insert( self.controlsnapshots, t )
    -- Then we sort it
    table.sort( self.controlsnapshots, function( a, b )
        return a.time<b.time
    end )
    -- Then we clean up any useless snapshots. Ones that are later than
    -- our update rate of 100ms shouldn't ever be used, but to be safe
    -- we'll store up to 300ms of player controls.
    if #self.controlsnapshots > 0 then
        while( self.controlsnapshots[1].time < World:getCurrentTime() - 0.3 ) do
            table.remove( self.controlsnapshots, 1 )
        end
    end
end

function Controllable:getControls( time )
    if not time or #self.controlsnapshots == 0 then
        return BindSystem.getEmpty(), nil
    end
    for i,v in pairs( self.controlsnapshots ) do
        if v.time > time and self.controlsnapshots[ i - 1 ] then
            return self.controlsnapshots[ i - 1 ].controls, i - 1
        elseif v.time == time then
            return v.controls, i
        end
    end
    return self.controlsnapshots[ #self.controlsnapshots ].controls, #self.controlsnapshots
end

-- Returns true given a control went from 0 to 1 between two ticks.
function Controllable:getControlClicked ( control, time )
    if not time then
        return false
    end
    local presentcontrols, presentindex = self:getControls( time )
    if not presentindex then
        return false
    end
    local pastcontrols = self.controlsnapshots[ presentindex - 1 ]
    if not pastcontrols then
        return false
    end
    if pastcontrols.controls[ control ] == 0 and presentcontrols[ control ] == 1 then
        return true
    end
    return false
end

function Controllable:isLocalPlayer()
    return self.localplayer
end

function Controllable:init()
    -- If we don't have the required components we disable ourselves
    if not self:hasComponent( Components.physical ) and not self:hasComponent( Components.intangible ) then
        self.update = nil
        return
    end
    self.speed = self.speed * self.mass
    self:setFixedRotation( true )
end

function Controllable:setPlayerID( id )
    self.playerid = id
end

return Controllable
