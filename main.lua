--require( "luarocks.loader" )
--require( "luabins" )
--require( "zlib" )

-- Clamps a number to within a certain range, with optional rounding
function math.clamp( n, low, high )
    return math.min( math.max( n, low ), high )
end

function table.equals( t1, t2 )
    if #t1 ~= #t2 then return false end
    for i,v in pairs( t1 ) do
        if v ~= t2[i] then return false end
    end
    return true
end

require( "lib/NikolaiResokav-LoveFrames" )
require( "lib/Tserial" )
-- Class support
common = {}
common.class = require( "lib/30log" )
-- Need some lube I guess.
require( "lib/LUBE" )
-- goddamnit
cock = require( "lib/cock" )

game = {}

game.version = "0.0.0"

-- Addons
game.gamestate = require( "lib/hump/gamestate" )
game.vector = require( "lib/hump/vector" )
game.timer = require( "lib/hump/timer" )
game.camera = require( "lib/hump/camera" )

compo = {}
-- Components
compo.drawable = require( "game/components/drawable" )
compo.debugdrawable = require( "game/components/debugdrawable" )
compo.glows = require( "game/components/glows" )
compo.camera = require( "game/components/camera" )
compo.controllable = require( "game/components/controllable" )
compo.blockslight = require( "game/components/blockslight" )
compo.starfield = require( "game/components/starfield" )
compo.emitslight = require( "game/components/emitslight" )
compo.networked = require( "game/components/networked" )
compo.default = require( "game/components/default" )
--

game.entity = require( "lib/entity" )

-- Systems
game.entities = require( "game/systems/entities" )
game.renderer = require( "game/systems/renderer" )
game.camerasystem = require( "game/systems/camerasystem" )
game.demosystem = require( "game/systems/demosystem" )
game.mapsystem = require( "game/systems/mapsystem" )
game.bindsystem = require( "game/systems/bindsystem" )
game.network = require( "game/systems/networksystem" )
--

-- Current Gamemode
game.gamemode = require( "game/gamemodes/default" )
game.gamemode:generateNetworkedVars()
game.gamemodes = { require( "game/gamemodes/default" ) }
--

gamestates = {}
gamestates.menu = require( "game/states/menu" )
gamestates.options = require( "game/states/options" )
gamestates.mapeditor = require( "game/states/mapeditor/mapeditor" )
gamestates.demoplayback = require( "game/states/demoplayback" )
gamestates.singleplayer = require( "game/states/singleplayer" )
gamestates.listenserver = require( "game/states/listenserver" )
gamestates.client = require( "game/states/client" )

function love.load()
    love.window.setMode( 800, 600, { resizable=true, vsync=true } )
    game.renderer:load()
    game.bindsystem:load()
    game.gamestate.registerEvents()
    game.gamestate.switch( gamestates.menu )
end
