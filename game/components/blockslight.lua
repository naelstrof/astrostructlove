-- Component that blocks light, contains functions to generate shadow volumes

local getShadowVolume = function( e, lightpos, lightradius )
    --TODO: verify lightpos is an actual vector
    local volumeverticies = {}
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
            local v1extrude = v1 - game.vector( math.cos( lightangle ), math.sin( lightangle ) ) * lightradius
            lightangle = lightpos:angleTo( v2 )
            local v2extrude = v2 - game.vector( math.cos( lightangle ), math.sin( lightangle ) ) * lightradius
            table.insert( volumeverticies, { v1.x, v1.y, 0, 0, 255, 255, 255 } )
            table.insert( volumeverticies, { v1extrude.x, v1extrude.y, 0, 0, 255, 255, 255 } )
            table.insert( volumeverticies, { v2.x, v2.y, 0, 0, 255, 255, 255 } )

            table.insert( volumeverticies, { v2extrude.x, v2extrude.y, 0, 0, 255, 255, 255 } )
            table.insert( volumeverticies, { v2.x, v2.y, 0, 0, 255, 255, 255 } )
            table.insert( volumeverticies, { v1extrude.x, v1extrude.y, 0, 0, 255, 255, 255 } )
        end
    end
    return volumeverticies
end

local setPos = function( e, x, y )
    game.renderer:updateLights()
end

local setRot = function( e, rot )
    game.renderer:updateLights()
end

local setDrawable = function( e, obj )
    local w = obj:getWidth() / 2
    local h = obj:getHeight() / 2
    e.shadowmesh = {
        game.vector( -w, -h ),
        game.vector( -w, h ),
        game.vector( w, h ),
        game.vector( w, -h )
    }
end

local init = function( e )
    if e.drawable ~= nil then
        local w = e.drawable:getWidth() / 2
        local h = e.drawable:getHeight() / 2
        e.shadowmesh = {
            game.vector( -w, -h ),
            game.vector( -w, h ),
            game.vector( w, h ),
            game.vector( w, -h )
        }
    end
    game.renderer:updateLights()
end

local deinit = function( e )
end

local BlocksLight = {
    __name = "BlocksLight",
    -- Default to a 64 by 64 box shadow mesh
    -- Shadow meshes go clockwise
    shadowmesh = {
        game.vector( -32, -32 ),
        game.vector( -32, 32 ),
        game.vector( 32, 32 ),
        game.vector( 32, -32 )
    },
    init = init,
    deinit = deinit,
    setDrawable = setDrawable,
    setPos = setPos,
    setRot = setRot,
    getShadowVolume = getShadowVolume
}

return BlocksLight
