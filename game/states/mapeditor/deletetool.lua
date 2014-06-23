local DeleteTool = {
    __name = "Delete",
    __desc = "Left click to delete selected entity."
}

function DeleteTool:init()
end

function DeleteTool:deinit()
end

function DeleteTool:update( dt, x, y )
end

function DeleteTool:draw()
    local ent = game.entities:getClicked()
    if ent ~= nil then
        love.graphics.setColor( { 255, 0, 0, 155 } )
        love.graphics.line( ent:getPos().x-5, ent:getPos().y-5, ent:getPos().x+5, ent:getPos().y+5 )
        love.graphics.line( ent:getPos().x+5, ent:getPos().y-5, ent:getPos().x-5, ent:getPos().y+5 )
        love.graphics.setColor( { 255, 255, 255, 255 } )
    end
end

function DeleteTool:mousepressed( x, y, button )
end

function DeleteTool:mousereleased( x, y, button )
    if button == 'l' then
        local ent = game.entities:getClicked()
        if ent ~= nil then
            ent:remove()
        end
    end
end

return DeleteTool
