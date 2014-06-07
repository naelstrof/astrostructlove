local EmitsLight = compo.component:extends()

function EmitsLight:init( e )
    e.shadowmeshdraw = nil
    e.oldpos = nil
    e.radius = 512
    e.updateShadowVolumes = function( e )
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
    game.renderer:addLight( e )
end

function EmitsLight:deinit( e )
    game.renderer:removeLight( e )
end

return EmitsLight
