require( "lib/NikolaiResokav-LoveFrames" )

love.class = require( "lib/30log" )
game = {}

-- Addons
game.gamestate = require( "lib/hump/gamestate" )
game.vector = require( "lib/hump/vector" )
game.timer = require( "lib/hump/timer" )
game.camera = require( "lib/hump/camera" )

compo = {}
-- Components
compo.component = require( "lib/component" )
compo.drawable = require( "game/components/drawable" )
compo.camera = require( "game/components/camera" )
compo.controllable = require( "game/components/controllable" )
compo.blockslight = require( "game/components/blockslight" )
compo.emitslight = require( "game/components/emitslight" )
compo.starfield = require( "game/components/starfield" )
--

game.entity = require( "lib/entity" )

-- Systems
game.entities = require( "game/systems/entities" )
game.renderer = require( "game/systems/renderer" )
game.camerasystem = require( "game/systems/camerasystem" )
game.controlsystem = require( "game/systems/controlsystem" )
game.starsystem = require( "game/systems/starsystem" )
--

gamestates = {}
gamestates.menu = require( "game/states/menu" )
gamestates.options = require( "game/states/options" )
gamestates.game = require( "game/states/game" )

function love.load()
    love.window.setMode( 800, 600, { resizable=true, vsync=true } )
    game.renderer:load()
    game.gamestate.registerEvents()
    game.gamestate.switch( gamestates.menu )
end
