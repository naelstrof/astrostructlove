local BindSystem = {
    leftclickmemory = 0,
    rightclickmemory = 0
}

function BindSystem:load()
    -- TODO: Load binds from file.
    local controls = {
        default_keyboard = {
            up      = { primary = { "keyboard", "up" }, secondary = { "keyboard", "w" } },
            down    = { primary = { "keyboard", "down" }, secondary = { "keyboard", "s" } },
            left    = { primary = { "keyboard", "left" }, secondary = { "keyboard", "a" } },
            right   = { primary = { "keyboard", "right" }, secondary = { "keyboard", "d" } },
            leanl   = { primary = { "keyboard", "q" } },
            leanr   = { primary = { "keyboard", "e" } },
            throwmodifier   = { primary = { "keyboard", "lshift" } },
            dropmodifier   = { primary = { "keyboard", "lctrl" } },
            hand1   = { primary = { "mouse button", "l" } },
            hand2   = { primary = { "mouse button", "r" } }
        },
        default2 = {}
    }
    -- Global control
    control = cock.new()
    control:setControls( controls )
    control:setDefault( "default_keyboard" )
end

function BindSystem.getControls()
    local copy = {}
    for i,v in pairs( control.current ) do
        copy[i] = v
    end
    local mousepos = game.camerasystem:getWorldMouse()
    copy.x = mousepos.x
    copy.y = mousepos.y
    return copy
end

function BindSystem:update( dt )
    cock.updateAll()
    -- Disallow controls to update click events when we're clicking on
    -- loveframe elements
    if control.current.hand1 ~= self.leftclickmemory then
        if table.getn( loveframes.util.GetCollisions() ) > 1 then
            control.current.hand1 = self.leftclickmemory
        else
            self.leftclickmemory = control.current.hand1
        end
    end
    if control.current.hand2 ~= self.rightclickmemory then
        if table.getn( loveframes.util.GetCollisions() ) > 1 then
            control.current.hand2 = self.rightclickmemory
        else
            self.rightclickmemory = control.current.hand1
        end
    end
end

return BindSystem
