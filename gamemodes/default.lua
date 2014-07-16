-- Gamemodes load most their data from "packs"
-- packs contain entity definitions, textures, and components used in the
-- gamemode. Packs can override eachother.
local Default = {}

Default.__name = "Default"
Default.map = "default"
Default.packs = {"116ee360-0c59-11e4-9191-0800200c9a66"}

function Default:spawnPlayer( id )
    -- Spawn player at a random playerspawn
    local ents = World:getAllNamed( "playerspawn" )
    -- Controllables need the playerid encoded with them
    local player = Entity:new( "player", { playerid=id } )
    if table.getn( ents ) <= 0 then
        player:setPos( Vector( 0, 0 ) )
    else
        local rand = 1+( math.floor( love.math.random() * ( table.getn( ents ) ) ) )
        player:setPos( ents[ rand ]:getPos() )
    end

    -- If we're in control of the player
    if id == 0 then
        player:setActive( true )
    end
    return player
end

return Default
