local DebugDrawable = {}

local init = function( e )
    Renderer:addDebugEntity( e )
end

local deinit = function( e )
    Renderer:removeDebugEntity( e )
end

local DebugDrawable = {
    __name = "DebugDrawable",
    init = init,
    deinit = deinit
}

return DebugDrawable
