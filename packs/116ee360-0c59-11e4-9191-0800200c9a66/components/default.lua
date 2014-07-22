local Default = {
    __name = "Default",
    pos = Vector( 0, 0 ),
    rot = 0,
    initialized = false,
    networkinfo = {
        setPos = "pos",
        setRot = "rot",
        setInitialized = "initialized"
    }
}

-- Since position is stored as a table
-- we must be able to set it as a table
-- so that it can be networked easily
function Default:setPos( t )
    if t == nil or t.x == nil or t.y == nil then
        error( "Failed to set position: Invalid parameters supplied! Got " .. t .. " instead." )
    end
    self.pos = Vector( t.x, t.y )
end

function Default:getPos()
    return self.pos
end

function Default:setRot( rot )
    self.rot = rot
end

function Default:getRot()
    return self.rot
end

-- Initialization/deinitialization can remove a entity from the world,
-- but keep it in play in some way or another
-- It's used right now for containers, and thus needs to be networked
function Default:setInitialized( i )
    if self.initialized == i then
        return
    end
    if i then
        self:init()
    else
        self:deinit()
    end
    -- We don't have to update self.initialized since
    -- init() and deinit() take care of it
    -- self.initialized = i
end

function Default:init()
    World:addEntity( self )
    self.initialized = true
end

function Default:deinit()
    World:removeEntity( self )
    self.initialized = false
end

return Default
