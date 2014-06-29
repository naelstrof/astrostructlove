-- So far all gamemodes do is have a spawnPlayer() hook, as well as have
-- a list of entities that are possible to spawn.
local Default = {}

Default.__name = "Default"

Default.map = "default"

Default.entities = {
    metalfloor = {
        __name="metalfloor",
        components={ compo.drawable, compo.networked },
        image="data/textures/metalfloor.png",
        attributes={ drawable=love.graphics.newImage( "data/textures/metalfloor.png" ) }
    },
    metalwall = {
        __name="metalwall",
        components={ compo.drawable, compo.blockslight, compo.networked },
        image="data/textures/metalwall.png",
        attributes={ drawable=love.graphics.newImage( "data/textures/metalwall.png" ), layer=3 }
    },
    lamp = {
        __name="lamp",
        components={ compo.drawable, compo.emitslight, compo.networked },
        image="data/textures/lamp.png",
        attributes={
            drawable=love.graphics.newImage( "data/textures/lamp.png" ),
            lightdrawable=love.graphics.newImage( "data/textures/lamp_point.png" ),
            layer=3
        }
    },
    controlpanel = {
        __name="controlpanel",
        components={ compo.drawable, compo.glows, compo.networked },
        image="data/textures/controlpanel.png",
        glowimage="data/textures/controlpanel_illumination.png",
        attributes={
                        drawable=love.graphics.newImage( "data/textures/controlpanel.png" ),
                        glowdrawable=love.graphics.newImage( "data/textures/controlpanel_illumination.png" ),
                        layer = 3
                   }
    },
    starfield = {
        __name="starfield",
        components={ compo.starfield, compo.networked, compo.debugdrawable },
        image="data/textures/logic.png",
        attributes={}
    },
    star= {
        __name="star",
        components={ compo.drawable },
        image="data/textures/star.png",
        attributes={ layer=1, drawable=love.graphics.newImage( "data/textures/star.png" ) }
    },
    ghost = {
        __name="ghost",
        components={ compo.camera, compo.controllable, compo.networked },
        image="data/textures/logic.png",
        attributes={}
    },
    playerspawn = {
        __name="playerspawn",
        components={ compo.debugdrawable, compo.networked },
        image="data/textures/logic.png",
        attributes={ }
    },
    player = {
        __name="player",
        components={ compo.drawable, compo.camera, compo.controllable, compo.networked },
        image="data/textures/human.png",
        attributes={ drawable=love.graphics.newImage( "data/textures/human.png" ), layer=3 }
    }
}

function Default:spawnPlayer( id )
    -- Spawn player at a random playerspawn
    local ents = game.entities:getAllNamed( "playerspawn" )
    local player = game.entity:new( "player" )
    if table.getn( ents ) <= 0 then
        player:setPos( game.vector( 0, 0 ) )
    else
        local rand = 1+( math.random() * ( table.getn( ents ) - 1 ) )
        player:setPos( ents[ rand ]:getPos() )
    end

    -- If we're in control of the player
    if id == 0 then
        player:setActive( true )
    end
    return player
end

return Default
