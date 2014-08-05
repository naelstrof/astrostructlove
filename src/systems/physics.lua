local Physics = {
    world = nil,
    null = nil
}

function Physics:update( dt )
    self.world:update( dt )
end

function Physics:load()
    love.physics.setMeter( 64 )
    self.world = love.physics.newWorld( 0, 0, true )
    self.null = love.physics.newBody( self.world, 0, 0, "static" )
end

return Physics
