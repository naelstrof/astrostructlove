-- System that handles drawing entities to the screen, uses a layer system to manage depth.
-- Adds several values to the entity that shouldn't be altered manually: rendererIndex, layer
-- The values are used to locate the entity within the table.

local Renderer = love.class( { layers = {}, lights={}, glowables={}, worldcanvas=nil, lightcanvas=nil, fullbright=false, maskshader=nil } )

function Renderer:addEntity( e )
    if e.layer == nil then
        startlayer = 2
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

function Renderer:addGlowable( e )
    table.insert( self.glowables, e )
    e.glowableIndex = table.maxn( self.glowables )
end

function Renderer:removeGlowable( e )
    table.remove( self.glowables, e.glowableIndex )
    for i=e.glowableIndex, table.maxn( self.glowables ), 1 do
        self.glowables[i].glowableIndex = self.glowables[i].glowableIndex - 1
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
    self.maskshader = love.graphics.newShader( [[
        vec4 effect ( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
            // a discarded fragment will fail the stencil test.
            if ( Texel( texture, texture_coords ).a == 0.0)
                discard;
            return vec4(1.0);
        }
    ]] )
    self.lightcanvas = love.graphics.newCanvas( love.graphics.getDimensions() )
    self.worldcanvas = love.graphics.newCanvas( love.graphics.getDimensions() )
    -- Space layer
    self.layers[ 1 ] = {}
    -- Ground layer
    self.layers[ 2 ] = {}
    -- Everything else layer
    self.layers[ 3 ] = {}
    -- Special fullbright layer
    self.layers[ 4 ] = {}
end

function Renderer:resize( w, h )
    self.lightcanvas = love.graphics.newCanvas( w, h )
    self.worldcanvas = love.graphics.newCanvas( w, h )
end

function Renderer:update( dt )
    for i,v in pairs( self.lights ) do
        v:updateShadowVolumes()
    end
end

function Renderer:draw()
    -- Draw world to world canvas
    game.camerasystem:attach()
    love.graphics.setCanvas( self.worldcanvas )
    self.worldcanvas:clear()
    for i=2,3 do
        for o,w in pairs( self.layers[i] ) do
            love.graphics.setColor( w.color )
            love.graphics.draw( w.drawable, w.pos.x, w.pos.y, w.rot, w.scale.x, w.scale.y, w.originoffset.x, w.originoffset.y )
            love.graphics.setColor( 255, 255, 255, 255 )
        end
    end
    love.graphics.setCanvas()
    game.camerasystem:detach()

    -- Draw lights to light canvas
    if not self.fullbright then
        love.graphics.setBlendMode( "additive" )
        love.graphics.setCanvas( self.lightcanvas )
        self.lightcanvas:clear()
        game.camerasystem:attach()
        for i,v in pairs( self.lights ) do
            -- Use stencils to create shadows
            if v.shadowmeshdraw ~= nil then
                love.graphics.setInvertedStencil( function()
                    love.graphics.draw( v.shadowmeshdraw )
                end )
            end
            love.graphics.setColor( 255, 255, 255, 255 * v.lightintensity )
            love.graphics.draw( v.lightdrawable, v.pos.x, v.pos.y, v.lightrot, v.lightscale.x, v.lightscale.y, v.lightoriginoffset.x, v.lightoriginoffset.y )
            love.graphics.setColor( 255, 255, 255, 255 )
        end
        love.graphics.setInvertedStencil()

        -- Draw glowables to the light canvas
        for i,v in pairs( self.glowables ) do
            love.graphics.draw( v.glowdrawable, v.pos.x, v.pos.y, v.rot, v.scale.x, v.scale.y, v.gloworiginoffset.x, v.gloworiginoffset.y )
        end

        love.graphics.setCanvas()
        game.camerasystem:detach()
    end
    -- Draw world to screen
    love.graphics.setBlendMode( "alpha" )
    love.graphics.draw( self.worldcanvas )

    -- Multiply the light canvas to the world, but only if we have fullbright disabled
    if not self.fullbright then
        love.graphics.setBlendMode( "multiplicative" )
        love.graphics.draw( self.lightcanvas )
        love.graphics.setBlendMode( "alpha" )
    end

    -- Now draw the space layer behind everything using stencils
    -- Things drawn in space are always fullbright
    love.graphics.setInvertedStencil( function()
        -- Shader is required to discard completely transparent fragments
        love.graphics.setShader( self.maskshader )
        love.graphics.draw( self.worldcanvas )
        love.graphics.setShader()
    end )
    for i,v in pairs( self.layers[1] ) do
        love.graphics.setColor( v.color )
        love.graphics.draw( v.drawable, v.pos.x, v.pos.y, v.rot, v.scale.x, v.scale.y, v.originoffset.x, v.originoffset.y )
        love.graphics.setColor( 255, 255, 255, 255 )
    end
    love.graphics.setInvertedStencil()

    game.camerasystem:attach()
    -- Draw special top-layer that's always fullbright, for things like ghosts and such
    for i,v in pairs( self.layers[4] ) do
        love.graphics.setColor( v.color )
        love.graphics.draw( v.drawable, v.pos.x, v.pos.y, v.rot, v.scale.x, v.scale.y, v.originoffset.x, v.originoffset.y )
        love.graphics.setColor( 255, 255, 255, 255 )
    end
    game.camerasystem:detach()
end

return Renderer
