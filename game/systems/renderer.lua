-- System that handles drawing entities to the screen, uses a layer system to manage depth.
-- Adds several values to the entity that shouldn't be altered manually: rendererIndex, layer
-- The values are used to locate the entity within the table.

local Renderer = love.class( { layers = {} } )

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

function Renderer:removeEntity( e )
    table.remove( self.layers[ e.layer ], e.rendererIndex )
    -- Have to update all the rendererIndicies of all the other entities in the same layer.
    for i=e.rendererIndex, table.maxn( self.layers[ e.layer ] ), 1 do
        self.layers[ e.layer ][i].rendererIndex = self.layers[ e.layer ][i].rendererIndex - 1
    end
end

function Renderer:draw()
    -- FIXME: May not actually traverse layers alphanumerically
    for i,v in pairs( self.layers ) do
        for o,w in pairs( v ) do
            love.graphics.setColor( w.color )
            love.graphics.draw( w.drawable, w.pos.x, w.pos.y, w.rot, w.scale.x, w.scale.y, w.originoffset.x, w.originoffset.y )
        end
    end
end

return Renderer