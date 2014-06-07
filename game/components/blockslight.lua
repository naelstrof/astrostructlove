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

    e.getShadowVolume = function( e, lightpos, dis )
        local verticies = {}
        local max = table.maxn( e.shadowmesh )
        -- Get a list of backfaces
        for i=1, max, 1 do
            local v1 = e:getPos() + e.shadowmesh[i]
            -- Shadow meshes are closed loops, so the modulus is nesessary
            local t = (i+1)%(max+1)
            if t == 0 then
                t = 1
            end
            local v2 = e:getPos() + e.shadowmesh[t]

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
                local v1extrude = v1 - game.vector( math.cos( lightangle ), math.sin( lightangle ) ) * dis
                lightangle = lightpos:angleTo( v2 )
                local v2extrude = v2 - game.vector( math.cos( lightangle ), math.sin( lightangle ) ) * dis
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
end

function BlocksLight:deinit( e )
    e.shadowmesh = nil
    e.getShadowVolume = nil
end

return BlocksLight
