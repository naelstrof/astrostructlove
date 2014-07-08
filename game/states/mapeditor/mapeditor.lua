local MapEditor = {}

MapEditor.titlebar = require( "game/states/mapeditor/titlebar" )
MapEditor.toolbox = require( "game/states/mapeditor/toolbox" )
MapEditor.grid = require( "game/states/mapeditor/grid" )
MapEditor.currenttool = nil

MapEditor.tools = {
    require( "game/states/mapeditor/nonetool" ),
    require( "game/states/mapeditor/createtool" ),
    require( "game/states/mapeditor/deletetool" )
}

function MapEditor:setTool( tool )
    if self.currenttool ~= nil then
        self.currenttool:deinit()
    end
    self.currenttool = tool
    self.currenttool:init()
end

function MapEditor:enter()
    self.camera = game.entity:new( "ghost" )
    self.camera:setActive( true )
    game.renderer:setFullbright( true )

    self.toolbox:init( MapEditor.tools )
    self.titlebar:init()
end

function MapEditor:leave()
    game.renderer:setFullbright( false )
    game.demosystem:leave()
    loveframes.util:RemoveAll()
    game.entities:removeAll()
end

function MapEditor:draw()
    local mousepos = self.grid:getMouse()
    -- Draw debug
    game.renderer:draw( game.renderer:getFullbright() )

    if game.renderer:getFullbright() then
        love.graphics.setColor( { 255, 255, 255, 155 } )
        love.graphics.print( "FULLBRIGHT (F to toggle)", 90, 30 )
        game.camerasystem:attach()
        self.grid:draw()
        if self.currenttool ~= nil then
            self.currenttool:draw( mousepos.x, mousepos.y )
        end
        love.graphics.setColor( { 255, 255, 255, 155 } )
        love.graphics.line( -5, -5, 5, 5 )
        love.graphics.line( 5, -5, -5, 5 )
        love.graphics.print( "0, 0", 10, 10 )
        love.graphics.setColor( { 255, 255, 255, 255 } )
        game.camerasystem:detach()
    end

    loveframes.draw()
end

function MapEditor:update( dt )
    game.bindsystem:update( dt )
    local mousepos = self.grid:getMouse()
    if self.currenttool ~= nil then
        self.currenttool:update( dt, mousepos.x, mousepos.y )
    end
    game.entities:update( dt )
    game.demosystem:update( dt )
    loveframes.update( dt )
end

function MapEditor:mousepressed( x, y, button )
    local mousepos = self.grid:getMouse()
    -- Only use tools when we're not clicking on loveframe elements
    if table.getn( loveframes.util.GetCollisions() ) <= 1 then
        if self.currenttool ~= nil then
            self.currenttool:mousepressed( mousepos.x, mousepos.y, button )
        end
        if button == "wu" then
            game.camerasystem:getActive():Zoom( 1.2 )
        elseif button == "wd" then
            game.camerasystem:getActive():Zoom( 0.8 )
        end
    end
    loveframes.mousepressed( x, y, button )
end

function MapEditor:mousereleased( x, y, button )
    local mousepos = self.grid:getMouse()
    if self.currenttool ~= nil then
        self.currenttool:mousereleased( mousepos.x, mousepos.y, button )
    end
    loveframes.mousereleased( x, y, button )
end

function MapEditor:keypressed( key, unicode )
    if key == "f" then
        game.renderer:toggleFullbright()
    end
    loveframes.keypressed( key, unicode )
end

function MapEditor:keyreleased( key )
    loveframes.keyreleased( key )
end

function MapEditor:textinput( text )
    loveframes.textinput( text )
end

function MapEditor:resize( w, h )
    self.titlebar:resize( w, h )
    self.toolbox:resize( w, h )
    game.renderer:resize( w, h )
    game.entities:resize( w, h )
end

return MapEditor
