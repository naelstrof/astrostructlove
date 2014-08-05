local Physics = {
    world = nil,
    time = 0,
    timestep = 10/1000,
    null = nil
}

function Physics:setCurrentTime( time )
    self.time = time % self.timestep
end

function Physics:update( dt )
    --self.time = self.time + dt
    --while self.time >= self.timestep do
        --self.world:update( self.timestep )
        --self.time = self.time - self.timestep
    --end
    self.world:update( dt )
end

function Physics:load()
    love.physics.setMeter( 64 )
    self.world = love.physics.newWorld( 0, 0, true )
    self.null = love.physics.newBody( self.world, 0, 0, "static" )
end

return Physics
