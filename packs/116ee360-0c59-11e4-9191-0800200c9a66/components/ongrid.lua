local OnGrid = {
    __name = "OnGrid",
    gridsize = 64
}

-- If we ever try to move our thing around, we just remove ourselves from
-- the grid. OnGrid things should never move around.
function OnGrid:setPos( pos )
    World:removeFromGrid( self )
end

function OnGrid:init()
    local oldpos = self:getPos()
    -- Messy math to snap to the grid
    self:setPos( Vector( math.floor( (oldpos.x - self.gridsize / 2) / self.gridsize + 0.5 ) * self.gridsize, math.floor( ( oldpos.y - self.gridsize / 2 ) / self.gridsize + 0.5 ) * self.gridsize ) + Vector( self.gridsize, self.gridsize ) / 2 )
    World:addToGrid( self )
end

return OnGrid
