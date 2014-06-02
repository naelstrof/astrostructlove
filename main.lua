require( "lib/NikolaiResokav-LoveFrames" )

love.class = require( "lib/30log" )
game = {}

-- Addons
game.gamestate = require( "lib/hump/gamestate" )
game.vector = require( "lib/hump/vector" )
game.timer = require( "lib/hump/timer" )

-- Components
game.component = require( "lib/component" )
game.drawable = require( "game/components/drawable" )
--

game.entity = require( "lib/entity" )

-- Systems
game.entities = require( "game/systems/entities" )
game.renderer = require( "game/systems/renderer" )
--

gamestates = {}
gamestates.menu = require( "game/states/menu" )
gamestates.options = require( "game/states/options" )
gamestates.game = require( "game/states/game" )

function love.load()
    love.window.setMode( 800, 600, { resizable=true, vsync=true } )
    game.gamestate.registerEvents()
    game.gamestate.switch( gamestates.menu )
end
