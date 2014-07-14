--require( "luarocks.loader" )
--require( "luabins" )
--require( "zlib" )

-- Clamps a number to within a certain range, with optional rounding
function math.clamp( n, low, high )
    return math.min( math.max( n, low ), high )
end

function table.copy( t )
    local copy = {}
    for i,v in pairs( t ) do
        if type( v ) == "table" then
            copy[i] = table.copy( v )
        else
            copy[i] = v
        end
    end
    return copy
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
game.md5 = require( "lib/md5" )
game.http = require( "socket.http" )
game.downloader = require( "lib/downloader" )

compo = {}
-- Components
compo.drawable = require( "game/components/drawable" )
compo.debugdrawable = require( "game/components/debugdrawable" )
compo.glows = require( "game/components/glows" )
compo.camera = require( "game/components/camera" )
compo.controllable = require( "game/components/controllable" )
compo.isitem = require( "game/components/isitem" )
compo.blockslight = require( "game/components/blockslight" )
compo.starfield = require( "game/components/starfield" )
compo.emitslight = require( "game/components/emitslight" )
compo.networked = require( "game/components/networked" )
compo.physical = require( "game/components/physical" )
compo.intangible = require( "game/components/intangible" )
compo.floor = require( "game/components/floor" )
compo.default = require( "game/components/default" )
compo.container = require( "game/components/container" )
compo.hashands = require( "game/components/hashands" )
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
game.client = require( "game/systems/clientsystem" )
game.physics = require( "game/systems/physics" )
game.options = require( "game/systems/options" )
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
gamestates.listenlobby = require( "game/states/listenlobby" )
gamestates.client = require( "game/states/client" )
gamestates.clientlobby = require( "game/states/clientlobby" )

function love.load()
    love.math.setRandomSeed( love.timer.getTime() )
    game.options:load()
    love.window.setMode( 800, 600, { resizable=true, vsync=true } )
    game.physics:load()
    game.renderer:load()
    game.bindsystem:load()
    game.gamestate.registerEvents()
    game.gamestate.switch( gamestates.menu )
end
