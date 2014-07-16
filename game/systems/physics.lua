-- System that handles physical objects.

local Physics = common.class( {
    meter = 64,
    gravity = 9.81,
    surface = nil,
    world = nil
} )

function Physics:load()
    love.physics.setMeter( self.meter )
    -- No gravity because our view is top-down
    self.world = love.physics.newWorld( 0, 0, true )
    -- Used for friction joints
    self.surface = love.physics.newBody( self.world, 0, 0, "static" )
end

function Physics:update( dt )
    self.world:update( dt )
end

return Physics
