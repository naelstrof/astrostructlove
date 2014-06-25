local DebugDrawable = {}

local init = function( e )
    game.renderer:addDebugEntity( e )
end

local deinit = function( e )
    game.renderer:removeDebugEntity( e )
end

local DebugDrawable = {
    __name = "DebugDrawable",
    init = init,
    deinit = deinit
}

return DebugDrawable
