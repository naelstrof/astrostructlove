local Glows = {
    __name = "Glows",
    glowdrawable = love.graphics.newImage( PackLocation .. "textures/null.png" ),
    gloworiginoffset = nil
}

function Glows:setGlowGlows( object )
    self.glowdrawable = object
    self.gloworiginoffset = Vector( self.glowdrawable:getWidth() / 2, self.glowdrawable:getHeight() / 2 )
end

function Glows:getGlowGlows()
    return self.glowdrawable
end

function Glows:init()
    self.gloworiginoffset = Vector( self.glowdrawable:getWidth() / 2, self.glowdrawable:getHeight() / 2 )
    Renderer:addGlowable( self )
end

function Glows:deinit()
    Renderer:removeGlowable( self )
end

return Glows
