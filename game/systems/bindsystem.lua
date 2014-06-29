local BindSystem = {}

function BindSystem:load()
    -- TODO: Load binds from file.
    local controls = {
        default_keyboard = {
            up      = { primary = { "keyboard", "up" }, secondary = { "keyboard", "w" } },
            down    = { primary = { "keyboard", "down" }, secondary = { "keyboard", "s" } },
            left    = { primary = { "keyboard", "left" }, secondary = { "keyboard", "a" } },
            right   = { primary = { "keyboard", "right" }, secondary = { "keyboard", "d" } },
            leanl   = { primary = { "keyboard", "q" } },
            leanr   = { primary = { "keyboard", "e" } }
        },
        default2 = {}
    }
    -- Global control
    control = cock.new()
    control:setControls( controls )
    control:setDefault( "default_keyboard" )
end

function BindSystem:update( dt )
    cock.updateAll()
end

return BindSystem
