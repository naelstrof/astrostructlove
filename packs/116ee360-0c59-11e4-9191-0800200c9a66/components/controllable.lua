local Controllable = {
    __name = "Controllable",
    speed = 250,
    rotvelocity = 0,
    playerid = 0,
    localplayer = false,
    controlsnapshots = {},
    networkinfo = {
        setPlayerID = "playerid"
    }
}

function Controllable:update( dt, tick )
    local controls = self:getControls( tick )
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
    self:applyForce( force * dt )
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

function Controllable:addControlSnapshot( controls, tick )
    self.controlsnapshots[ tick ] = controls
    -- We hold 1 second of snapshots in memory
    -- We should be really safe to remove old snapshots in this
    -- fashion
    self.controlsnapshots[ tick - 33 ] = nil
end

function Controllable:getControls( tick )
    if not tick then
        return BindSystem.getEmpty()
    end
    if not self.controlsnapshots[ tick ] then
        local lastcontroltick = nil
        for i,v in pairs( self.controlsnapshots ) do
            if i > tick then
                break
            end
            if lastcontroltick == nil or lastcontroltick < i then
                lastcontroltick = i
            end
        end
        if self.controlsnapshots[ lastcontroltick ] == nil then
            return BindSystem.getEmpty()
        end
        return self.controlsnapshots[ lastcontroltick ]
    end
    return self.controlsnapshots[ tick ]
end

-- Returns true given a control went from 0 to 1 between two ticks.
function Controllable:getControlClicked ( control, tick )
    if not tick then
        return false
    end
    local past = self:getControls( tick - 1 )[ control ]
    local present = self:getControls( tick )[ control ]
    if past == 0 and present == 1 then
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
