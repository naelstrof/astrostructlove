
local updateShadowVolumes = function( e )
    if e.oldpos == e:getPos() then
        return
    end
    local allverticies = {}
    e.oldpos = e:getPos()
    local ents = game.entities:getNearby( e:getPos(), e.radius )
    for i,v in pairs( ents ) do
        if v:hasComponent( compo.blockslight ) then
            local verts = v:getShadowVolume( e:getPos(), e.radius )
            for j,w in pairs( verts ) do
                table.insert( allverticies, w )
            end
        end
    end
    if table.maxn( allverticies ) > 1 then
        e.shadowmeshdraw = love.graphics.newMesh( allverticies, nil, "triangles" )
    end
end

local update = function( e, dt )
    e.time = e.time + ( dt * 10 )
    local pos = math.floor( e.time % #e.lightflickermap ) + 1
    local char = string.sub( e.lightflickermap, pos, pos )
    local npos = pos + 1
    if npos > #e.lightflickermap then
        npos = 1
    end
    local nchar = string.sub( e.lightflickermap, npos, npos )
    --local nchar = string.sub( e.lightflickermap, npos+1, npos+1 )
    -- 0 = a, 1 = z, m = 0.5
    local flickera = ( string.byte( char ) - 97 ) / 24
    local flickerb = ( string.byte( nchar ) - 97 ) / 24

    local func = e.time - math.floor( e.time )

    local flicker =  flickera * (1-func) + flickerb * func
    e.lightintensity = e.baselightintensity * flicker
    --e.lightscale = e.baselightscale * flicker
end

local init = function( e )
    e.lightrot = math.random()*math.pi*2
    e.lightoriginoffset = game.vector( e.lightdrawable:getWidth() / 2, e.lightdrawable:getHeight() / 2 )
    -- ONLY SCALE WIDTH, so we can have some light shafts and shit.
    e.lightscale = game.vector( e.radius*2/e.lightdrawable:getWidth(), e.radius*2/e.lightdrawable:getWidth() )

    e.baselightintensity = e.lightintensity
    e.baselightscale = e.lightscale
    e.time = math.random() * #e.lightflickermap
    game.renderer:addLight( e )
end

local deinit = function( e )
    game.renderer:removeLight( e )
end

local EmitsLight = {
    __name = "EmitsLight",
    shadowmeshdraw = nil,
    oldpos = nil,
    radius = 256,
    lightsize = 32,
    lightdrawable = love.graphics.newImage( "data/textures/point.png" ),
    lightrot = 0,
    lightoriginoffset = game.vector( 0, 0 ),
    lightscale = game.vector( 1, 1 ),
    lightintensity = 1,
    lightflickermap = "mmnmmommommnonmmonqnmmo",
    updateShadowVolumes = updateShadowVolumes,
    update = update,
    init = init,
    deinit = deinit
}

return EmitsLight
