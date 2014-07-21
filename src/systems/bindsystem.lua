local BindSystem = {
    enabled = true,
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
            throwmodifier   = { primary = { "keyboard", "lshift" } },
            dropmodifier   = { primary = { "keyboard", "lctrl" } },
            hand1   = { primary = { "mouse button", "l" } },
            hand2   = { primary = { "mouse button", "r" } },
            showplayers = { primary = { "keyboard", "tab" } }
        },
        default2 = {}
    }
    -- Global control
    control = Cock.new()
    control:setControls( controls )
    control:setDefault( "default_keyboard" )
end

function BindSystem:getControls()
    if not self.enabled then
        return self.getEmpty()
    end
    local copy = {}
    for i,v in pairs( control.current ) do
        copy[i] = v
    end
    local mousepos = CameraSystem:getWorldMouse()
    copy.x = mousepos.x
    copy.y = mousepos.y
    return copy
end

function BindSystem.getDiff( a, b )
    local copy = {}
    for i,v in pairs( b ) do
        if a[ i ] ~= v then
            copy[ i ] = v
        end
    end
    return copy
end

function BindSystem.getEmpty()
    local copy = {}
    for i,v in pairs( control.current ) do
        copy[i] = 0
    end
    copy.x = 0
    copy.y = 0
    return copy
end

function BindSystem:toggleInput()
    self.enabled = not self.enabled
end

function BindSystem:update( dt )
    if not self.enabled then
        return
    end
    Cock.updateAll()
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
