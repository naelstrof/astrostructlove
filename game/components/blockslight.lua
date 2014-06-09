local BlocksLight = compo.component:extends()

function BlocksLight:init( e )
    -- Default to a 64 by 64 box shadow mesh
    -- Shadow meshes go clockwise
    e.shadowmesh = {
        game.vector( -32, -32 ),
        game.vector( -32, 32 ),
        game.vector( 32, 32 ),
        game.vector( 32, -32 )
    }

    if e:hasComponent( compo.drawable ) then
        -- override the setDrawable function to generate a more accurate shadowmesh
        e.setDrawableBackup = e.setDrawable
        e.setDrawable = function( e, object )
            e.drawable = object
            local w = e.drawable:getWidth() / 2
            local h = e.drawable:getHeight() / 2
            e.originoffset = game.vector( w, h )
            e.shadowmesh = {
                game.vector( -w, -h ),
                game.vector( -w, h ),
                game.vector( w, h ),
                game.vector( w, -h )
            }
        end
        local w = e.drawable:getWidth() / 2
        local h = e.drawable:getHeight() / 2
        e.shadowmesh = {
            game.vector( -w, -h ),
            game.vector( -w, h ),
            game.vector( w, h ),
            game.vector( w, -h )
        }
    end

    e.getShadowVolume = function( e, lightpos, radius )
        local verticies = {}
        local max = table.maxn( e.shadowmesh )
        -- Get a list of backfaces
        for i=1, max, 1 do
            local v1 = e:getPos() + e.shadowmesh[i]:rotated( e:getRot() )
            -- Shadow meshes are closed loops, so the modulus is nesessary
            local t = i+1
            if t > max then
                t = 1
            end
            local v2 = e:getPos() + e.shadowmesh[t]:rotated( e:getRot() )

            -- The dot product of the face's normal with the vector
            -- from the face to the light distiguishes if the face is
            -- facing the light.
            local facenormal = v1:angleTo( v2 ) - math.pi/2
            local facecenter = ( v1 + v2 ) / 2
            local facetolight = lightpos - facecenter

            local faceunitvector = game.vector( math.cos( facenormal ), math.sin( facenormal ) )
            local facing = faceunitvector * facetolight > 0
            if not facing then
                local lightangle = lightpos:angleTo( v1 )
                local v1extrude = v1 - game.vector( math.cos( lightangle ), math.sin( lightangle ) ) * radius
                lightangle = lightpos:angleTo( v2 )
                local v2extrude = v2 - game.vector( math.cos( lightangle ), math.sin( lightangle ) ) * radius
                table.insert( verticies, { v1.x, v1.y, 0, 0, 255, 255, 255 } )
                table.insert( verticies, { v1extrude.x, v1extrude.y, 0, 0, 255, 255, 255 } )
                table.insert( verticies, { v2.x, v2.y, 0, 0, 255, 255, 255 } )

                table.insert( verticies, { v2extrude.x, v2extrude.y, 0, 0, 255, 255, 255 } )
                table.insert( verticies, { v2.x, v2.y, 0, 0, 255, 255, 255 } )
                table.insert( verticies, { v1extrude.x, v1extrude.y, 0, 0, 255, 255, 255 } )
            end
        end
        return verticies
    end
    game.renderer:updateLights()

    e.setPosBlocksLightBackup = e.setPos
    e.setPos = function( e, pos )
        e:setPosBlocksLightBackup( pos )
        game.renderer:updateLights()
    end

    e.setRotBlocksLightBackup = e.setRot
    e.setRot = function( e, rot )
        e:setRotBlocksLightBackup( rot )
        game.renderer:updateLights()
    end
end

function BlocksLight:deinit( e )
    e.shadowmesh = nil
    e.getShadowVolume = nil
    e.setPos = e.setPosBlocksLightBackup
    e.setRot = e.setRotBlocksLightBackup
    e.setPosBlocksLightBackup = nil
    e.setRotBlocksLightBackup = nil
    if e:hasComponent( compo.drawable ) then
        e.setDrawable = e.setDrawableBackup
    else
        e.setDrawable = nil
    end
    e.setDrawableBackup = nil
end

return BlocksLight
