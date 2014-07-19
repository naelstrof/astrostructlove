local update = function( e, dt, tick )
    local controls = e:getControls( tick )
    local direction = 0
    local up, down, left, right
    up, down, left, right = controls.up, controls.down, controls.left, controls.right

    if up - down == 0 and right - left == 0 then
        direction = Vector( 0, 0 )
    else
        direction = Vector( right - left, down - up ):normalized()
    end
    -- There's no need for rotation adjustment, because players can't rotate.
    --local force = direction:rotated( e:getRot() ) * e:getSpeed()
    local force = direction * e:getSpeed()
    e:applyForce( force )
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

local setLocalPlayer = function( e, bool )
    e.localplayer = bool
end

local getRotSpeed = function( e )
    return e.rotspeed
end

local addControlSnapshot = function( e, controls, tick )
    e.controlsnapshots[ tick ] = controls
    -- We hold 1 second of snapshots in memory
    -- We should be really safe to remove old snapshots in this
    -- fashion
    e.controlsnapshots[ tick - 33 ] = nil
end

local getControls = function( e, tick )
    if not tick then
        return BindSystem.getEmpty()
    end
    if not e.controlsnapshots[ tick ] then
        local lastcontroltick = nil
        for i,v in pairs( e.controlsnapshots ) do
            if i > tick then
                break
            end
            if lastcontroltick == nil or lastcontroltick < i then
                lastcontroltick = i
            end
        end
        if e.controlsnapshots[ lastcontroltick ] == nil then
            return BindSystem.getEmpty()
        end
        return e.controlsnapshots[ lastcontroltick ]
    end
    return e.controlsnapshots[ tick ]
end

-- Returns true given a control went from 0 to 1 between two ticks.
local getControlClicked  = function( e, control, tick )
    if not tick then
        return false
    end
    local past = e:getControls( tick - 1 )[ control ]
    local present = e:getControls( tick )[ control ]
    if past == 0 and present == 1 then
        return true
    end
    return false
end

local isLocalPlayer = function( e )
    return e.localplayer
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
    localplayer = false,
    isLocalPlayer = isLocalPlayer,
    setLocalPlayer = setLocalPlayer,
    update = update,
    setActive = setActive,
    setVelocity = setVelocity,
    setSpeed = setSpeed,
    getSpeed = getSpeed,
    addControlSnapshot = addControlSnapshot,
    getControls = getControls,
    getControlClicked = getControlClicked,
    setPlayerID = setPlayerID,
    controlsnapshots = {},
    networkinfo = {
        setPlayerID = "playerid"
    },
    setRotSpeed = setRotSpeed,
    getRotSpeed = getRotSpeed
}

return Controllable
