
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

local init = function( e )
    e.lightoriginoffset = game.vector( e.lightdrawable:getWidth() / 2, e.lightdrawable:getHeight() / 2 )
    -- ONLY SCALE WIDTH, so we can have some light shafts and shit.
    e.lightscale = game.vector( e.radius*2/e.lightdrawable:getWidth(), e.radius*2/e.lightdrawable:getWidth() )
    game.renderer:addLight( e )
end

local deinit = function( e )
    game.renderer:removeLight( e )
end

local EmitsLight = {
    __name = "EmitsLight",
    shadowmeshdraw = nil,
    oldpos = nil,
    radius = 1024,
    lightsize = 32,
    lightdrawable = love.graphics.newImage( "data/textures/point.png" ),
    lightrot = 0,
    lightoriginoffset = game.vector( 0, 0 ),
    lightscale = game.vector( 1, 1 ),
    lightintensity = 1,
    updateShadowVolumes = updateShadowVolumes,
    init = init,
    deinit = deinit
}

return EmitsLight
