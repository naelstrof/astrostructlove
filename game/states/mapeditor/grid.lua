local Grid = {
    enabled = false,
    gridsize = 64,
    gridoffset = game.vector( 0, 0 )
}

function Grid:draw()
    -- I hope this isn't some kind of tumbler slang
    if not self.enabled then
        return
    end
    -- Mumbo jumbo to draw a grid to the screen, without drawing outside of it.
    local zoom = ( 1 / game.camerasystem:getActive():getZoom() )
    local max = math.max( love.graphics.getWidth(), love.graphics.getHeight() ) * zoom
    local min = math.min( love.graphics.getWidth(), love.graphics.getHeight() ) * zoom
    local difference = math.ceil( ( max - min ) / self.gridsize ) * self.gridsize
    local middle = game.camerasystem:getActive():getPos()
    local start = game.vector( middle.x - max / 2, middle.y - max / 2 )
    start = start * zoom
    start = game.vector( math.floor( start.x / self.gridsize + 0.5 ) * self.gridsize, math.floor( start.y / self.gridsize + 0.5 ) * self.gridsize )
    start = start + game.vector( self.gridoffset.x, self.gridoffset.y )
    local endp = game.vector( middle.x + max / 2, middle.y + max / 2 )
    endp = endp * zoom
    endp = endp + game.vector( difference, difference )
    for x=start.x,endp.x,self.gridsize do
        love.graphics.line( x, middle.y + max / 2 + difference, x, middle.y - max / 2 - difference )
    end
    for y=start.y,endp.y,self.gridsize do
        love.graphics.line( middle.x + max / 2 + difference, y, middle.x - max / 2 - difference, y )
    end
end

function Grid:getMouse()
    local mousepos = game.camerasystem:getWorldMouse()
    if not self.enabled then
        return mousepos
    end
    mousepos = mousepos - self.gridoffset
    -- Some messy math to snap to the center of pieces of the grid
    local snappedpos = game.vector( math.floor( (mousepos.x - self.gridsize / 2) / self.gridsize + 0.5 ) * self.gridsize, math.floor( ( mousepos.y - self.gridsize / 2 ) / self.gridsize + 0.5 ) * self.gridsize ) + game.vector( self.gridsize, self.gridsize ) / 2
    return snappedpos + self.gridoffset
end

return Grid
