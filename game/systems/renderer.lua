-- System that handles drawing entities to the screen, uses a layer system to manage depth.
-- Adds several values to the entity that shouldn't be altered manually: rendererIndex, layer
-- The values are used to locate the entity within the table.

local Renderer = love.class( { layers = {}, lights={}, canvas=nil, fullbright=false } )

function Renderer:addEntity( e )
    if e.layer == nil then
        startlayer = 0
    else
        startlayer = e.layer
    end

    if self.layers[ startlayer ] == nil then
        self.layers[ startlayer ] = {}
    end
    table.insert( self.layers[ startlayer ], e )
    e.rendererIndex = table.maxn( self.layers[ startlayer] )
    e.layer = startlayer
end

function Renderer:setFullbright( fullbright )
    self.fullbright = fullbright
end

function Renderer:getFullbright()
    return self.fullbright
end

function Renderer:toggleFullbright()
    self.fullbright = not self.fullbright
end

function Renderer:removeEntity( e )
    table.remove( self.layers[ e.layer ], e.rendererIndex )
    -- Have to update all the rendererIndicies of all the other entities in the same layer.
    for i=e.rendererIndex, table.maxn( self.layers[ e.layer ] ), 1 do
        self.layers[ e.layer ][i].rendererIndex = self.layers[ e.layer ][i].rendererIndex - 1
    end
end

function Renderer:addLight( e )
    table.insert( self.lights, e )
    e.lightIndex = table.maxn( self.lights )
end

function Renderer:removeLight( e )
    table.remove( self.lights, e.lightIndex )
    for i=e.lightIndex, table.maxn( self.lights ), 1 do
        self.lights[i].lightIndex = self.lights[i].lightIndex - 1
    end
end

function Renderer:updateLights( e )
    for i,v in pairs( self.lights ) do
        v.oldpos = nil
    end
end

function Renderer:load()
    self.canvas = love.graphics.newCanvas( love.graphics.getDimensions() )
end

function Renderer:resize( w, h )
    self.canvas = love.graphics.newCanvas( love.graphics.getDimensions() )
end

function Renderer:update( dt )
    for i,v in pairs( self.lights ) do
        v:updateShadowVolumes()
    end
end

function Renderer:draw()
    -- Draw world
    game.camerasystem:attach()
    -- FIXME: May not actually traverse layers alphanumerically
    for i,v in pairs( self.layers ) do
        for o,w in pairs( v ) do
            love.graphics.setColor( w.color )
            love.graphics.draw( w.drawable, w.pos.x, w.pos.y, w.rot, w.scale.x, w.scale.y, w.originoffset.x, w.originoffset.y )
        end
    end

    -- Draw lights
    if not self.fullbright then
        love.graphics.setCanvas( self.canvas )
        self.canvas:clear()
        for i,v in pairs( self.lights ) do
            if v.shadowmeshdraw ~= nil then
                love.graphics.setInvertedStencil( function()
                    love.graphics.draw( v.shadowmeshdraw )
                end )
            end
            love.graphics.setColor( 255, 255, 255, 255 * v.lightintensity )
            love.graphics.draw( v.lightdrawable, v.pos.x, v.pos.y, v.lightrot, v.lightscale.x, v.lightscale.y, v.lightoriginoffset.x, v.lightoriginoffset.y )
            love.graphics.setColor( 255, 255, 255, 255 )
            love.graphics.setInvertedStencil( nil )
        end
        love.graphics.setInvertedStencil( nil )
        love.graphics.setCanvas()
        game.camerasystem:detach()
        love.graphics.setBlendMode( "multiplicative" )
        love.graphics.draw( self.canvas )
        love.graphics.setBlendMode( "alpha" )
    else
        game.camerasystem:detach()
    end
end

return Renderer
