--require( "luarocks.loader" )
--require( "luabins" )
--require( "zlib" )

Class = require( "lib/30log" )

require( "lib/util" )
require( "lib/NikolaiResokav-LoveFrames" )
require( "lib/Tserial" )

Cock = require( "lib/cock" )

require 'enet'
Enet = {
    Client = require( "lib/client" ),
    Server = require( "lib/server" )
}

Game = {}
Game.version = "0.0.0"

-- Addons
StateMachine = require( "lib/hump/gamestate" )
Vector = require( "lib/hump/vector" )
Timer = require( "lib/hump/timer" )
Camera = require( "lib/hump/camera" )
MD5 = require( "lib/md5" )
HTTP = require( "socket.http" )
Downloader = require( "lib/downloader" )
Entity = require( "lib/entity" )

-- Systems
World = require( "src/systems/world" )
Renderer = require( "src/systems/renderer" )
CameraSystem = require( "src/systems/camerasystem" )
DemoSystem = require( "src/systems/demosystem" )
Physics = require( "src/systems/physics" )
MapSystem = require( "src/systems/mapsystem" )
BindSystem = require( "src/systems/bindsystem" )
Network = require( "src/systems/networksystem" )
ClientSystem = require( "src/systems/clientsystem" )
OptionSystem = require( "src/systems/optionsystem" )
Components = require( "src/systems/components" )
Entities = require( "src/systems/entities" )
Gamemode = require( "src/systems/gamemode" )
Gamemode:setGamemode( "default" )
--

State = {}
State.menu = require( "src/states/menu" )
State.options = require( "src/states/options" )
State.mapeditor = require( "src/states/mapeditor/mapeditor" )
State.demoplayback = require( "src/states/demoplayback" )
State.singleplayer = require( "src/states/singleplayer" )
State.listenserver = require( "src/states/listenserver" )
State.listenlobby = require( "src/states/listenlobby" )
State.client = require( "src/states/client" )
State.clientlobby = require( "src/states/clientlobby" )

function love.load()
    love.math.setRandomSeed( love.timer.getTime() )
    OptionSystem:load()
    love.window.setMode( 800, 600, { resizable=true, vsync=true } )
    Renderer:load()
    BindSystem:load()
    Physics:load()
    StateMachine.registerEvents()
    StateMachine.switch( State.menu )
end
