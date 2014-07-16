local NoneTool = {
    __name = "None",
    __desc = "Does nothing!"
}

function NoneTool:init()
end

function NoneTool:deinit()
end

function NoneTool:update( dt, x, y )
end

function NoneTool:draw( x, y )
end

function NoneTool:mousepressed( x, y, button )
end

function NoneTool:mousereleased( x, y, button )
end

return NoneTool
