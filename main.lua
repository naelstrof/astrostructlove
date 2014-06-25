--require( "luarocks.loader" )
--require( "luabins" )
--require( "zlib" )

-- Clamps a number to within a certain range, with optional rounding
function math.clamp( n, low, high )
    return math.min( math.max( n, low ), high )
end

function table.equals( t1, t2 )
    if #t1 ~= #t2 then return false end
    for i=1,#t1 do
        if t1[i] ~= t2[i] then return false end
    end
    return true
end

require( "lib/NikolaiResokav-LoveFrames" )
require( "lib/Tserial" )

game = {}

-- Addons
game.gamestate = require( "lib/hump/gamestate" )
game.vector = require( "lib/hump/vector" )
game.timer = require( "lib/hump/timer" )
game.camera = require( "lib/hump/camera" )

-- Class support
love.class = require( "lib/30log" )

compo = {}
-- Components
compo.drawable = require( "game/components/drawable" )
compo.glows = require( "game/components/glows" )
compo.camera = require( "game/components/camera" )
compo.controllable = require( "game/components/controllable" )
compo.blockslight = require( "game/components/blockslight" )
compo.emitslight = require( "game/components/emitslight" )
compo.starfield = require( "game/components/starfield" )
compo.networked = require( "game/components/networked" )
--

game.entity = require( "lib/entity" )

-- Systems
game.entities = require( "game/systems/entities" )
game.renderer = require( "game/systems/renderer" )
game.camerasystem = require( "game/systems/camerasystem" )
game.controlsystem = require( "game/systems/controlsystem" )
game.starsystem = require( "game/systems/starsystem" )
game.demosystem = require( "game/systems/demosystem" )
game.mapsystem = require( "game/systems/mapsystem" )
--

-- Current Gamemode
game.gamemode = require( "game/gamemodes/default" )
--

gamestates = {}
gamestates.menu = require( "game/states/menu" )
gamestates.options = require( "game/states/options" )
gamestates.mapeditor = require( "game/states/mapeditor/mapeditor" )
gamestates.demoplayback = require( "game/states/demoplayback" )

function love.load()
    love.window.setMode( 800, 600, { resizable=true, vsync=true } )
    game.renderer:load()
    game.gamestate.registerEvents()
    game.gamestate.switch( gamestates.menu )
end
