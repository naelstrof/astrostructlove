-- System that handles physical objects.

local Physics = common.class( {
    meter = 64,
    gravity = 9.81,
    world = nil
} )

function Physics:load()
    love.physics.setMeter( self.meter )
    -- No gravity because our view is top-down
    self.world = love.physics.newWorld( 0, 0, true )
end

function Physics:update( dt )
    self.world:update( dt )
end

return Physics
