local DebugDrawable = {
    __name = "DebugDrawable"
}

function DebugDrawable:init()
    Renderer:addDebugEntity( self )
end

function DebugDrawable:deinit()
    Renderer:removeDebugEntity( self )
end

return DebugDrawable
