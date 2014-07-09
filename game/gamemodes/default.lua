-- So far all gamemodes do is have a spawnPlayer() hook, as well as have
-- a list of entities that are possible to spawn.
local Default = {}

Default.__name = "Default"

Default.map = "default"

Default.entities = {
    metalfloor = {
        __name="metalfloor",
        components={ compo.drawable, compo.floor, compo.networked, compo.default },
        image="data/textures/metalfloor.png",
        attributes={ drawable=love.graphics.newImage( "data/textures/metalfloor.png" ) }
    },
    metalwall = {
        __name="metalwall",
        components={ compo.drawable, compo.blockslight, compo.physical, compo.networked, compo.default },
        image="data/textures/metalwall.png",
        attributes={ drawable=love.graphics.newImage( "data/textures/metalwall.png" ), layer=3 }
    },
    lamp = {
        __name="lamp",
        components={ compo.drawable, compo.emitslight, compo.networked, compo.default },
        image="data/textures/lamp.png",
        attributes={
            drawable=love.graphics.newImage( "data/textures/lamp.png" ),
            lightdrawable=love.graphics.newImage( "data/textures/lamp_point.png" ),
            layer=3
        }
    },
    controlpanel = {
        __name="controlpanel",
        components={ compo.drawable, compo.glows, compo.networked, compo.default },
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
        components={ compo.starfield, compo.networked, compo.debugdrawable , compo.default },
        image="data/textures/logic.png",
        attributes={}
    },
    star= {
        __name="star",
        components={ compo.drawable, compo.default },
        image="data/textures/star.png",
        attributes={ layer=1, drawable=love.graphics.newImage( "data/textures/star.png" ) }
    },
    ghost = {
        __name="ghost",
        components={ compo.camera, compo.intangible, compo.controllable, compo.networked, compo.default },
        image="data/textures/logic.png",
        attributes={}
    },
    playerspawn = {
        __name="playerspawn",
        components={ compo.debugdrawable, compo.networked, compo.default },
        image="data/textures/logic.png",
        attributes={ }
    },
    player = {
        __name="player",
        components={ compo.drawable, compo.camera, compo.physical, compo.controllable, compo.networked, compo.default },
        image="data/textures/human.png",
        attributes={
            drawable=love.graphics.newImage( "data/textures/human.png" ),
            layer=3,
            shape=love.physics.newCircleShape( 10 ),
            static=false
        }
    }
}

function Default:merge( a, b )
    if b == nil then
        return
    end
    for i,v in pairs( b ) do
        local found = false
        for o,m in pairs( a ) do
            if v == m then
                found = true
                break
            end
        end
        if not found then
            table.insert( a, v )
        end
    end
end

-- This function fills out the entities' networking arrays so that
-- game.networksystem and game.demosystem can know what variables
-- matter
-- TODO: Probably should move this out of the gamemode itself.
function Default:generateNetworkedVars()
    for i,ent in pairs( self.entities ) do
        ent.networkedvars = {}
        ent.networkedfunctions = {}
        for o,comp in pairs( ent.components ) do
            self:merge( ent.networkedvars, comp.networkedvars )
            self:merge( ent.networkedfunctions, comp.networkedfunctions )
        end
    end
end

function Default:spawnPlayer( id )
    -- Spawn player at a random playerspawn
    local ents = game.entities:getAllNamed( "playerspawn" )
    -- Controllables need the playerid encoded with them
    local player = game.entity:new( "player", { playerid=id } )
    if table.getn( ents ) <= 0 then
        player:setPos( game.vector( 0, 0 ) )
    else
        local rand = 1+( math.floor( love.math.random() * ( table.getn( ents ) ) ) )
        player:setPos( ents[ rand ]:getPos() )
    end

    -- If we're in control of the player
    if id == 0 then
        player:setActive( true )
    end
    game.network:addPlayer( id, player )
    return player
end

return Default
