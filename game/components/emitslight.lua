local EmitsLight = compo.component:extends()

function EmitsLight:init( e )
    e.shadowmeshdraw = nil
    e.shadowfindraw = nil
    e.oldpos = nil
    e.radius = 1024
    e.lightsize = 32
    e.lightdrawable = love.graphics.newImage( "data/textures/point.png" )
    e.lightrot = 0
    e.lightoriginoffset = game.vector( e.lightdrawable:getWidth() / 2, e.lightdrawable:getHeight() / 2 )
    -- ONLY SCALE WIDTH, so we can have some light shafts and shit.
    e.lightscale = game.vector( e.radius*2/e.lightdrawable:getWidth(), e.radius*2/e.lightdrawable:getWidth() )
    e.lightintensity = 1
    e.updateShadowVolumes = function( e )
        if e.oldpos == e:getPos() then
            return
        end
        local allverticies = {}
        local allfinverticies = {}
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
    game.renderer:addLight( e )
end

function EmitsLight:deinit( e )
    e.shadowmeshdraw = nil
    e.oldpos = nil
    e.radius = nil
    e.lightdrawable = nil
    e.lightrot = nil
    e.lightoriginoffset = nil
    e.lightscale = nil
    e.lightintensity = nil
    e.updateShadowVolumes = nil
    game.renderer:removeLight( e )
end

return EmitsLight
