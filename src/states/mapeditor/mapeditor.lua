local MapEditor = {}

MapEditor.titlebar = require( "src/states/mapeditor/titlebar" )
MapEditor.toolbox = require( "src/states/mapeditor/toolbox" )
MapEditor.grid = require( "src/states/mapeditor/grid" )
MapEditor.currenttool = nil

MapEditor.tools = {
    require( "src/states/mapeditor/nonetool" ),
    require( "src/states/mapeditor/createtool" ),
    require( "src/states/mapeditor/painttool" ),
    require( "src/states/mapeditor/deletetool" )
}

function MapEditor:setTool( tool )
    if self.currenttool ~= nil then
        self.currenttool:deinit()
    end
    self.currenttool = tool
    self.currenttool:init()
end

function MapEditor:enter()
    self.camera = Entity:new( "ghost" )
    self.camera:setActive( true )
    Renderer:setFullbright( true )

    self.toolbox:init( MapEditor.tools )
    self.titlebar:init()
end

function MapEditor:leave()
    Renderer:setFullbright( false )
    DemoSystem:leave()
    loveframes.util:RemoveAll()
    World:removeAll()
end

function MapEditor:draw()
    local mousepos = self.grid:getMouse()
    -- Draw debug
    Renderer:draw( Renderer:getFullbright() )

    if Renderer:getFullbright() then
        love.graphics.setColor( { 255, 255, 255, 155 } )
        love.graphics.print( "FULLBRIGHT (F to toggle)", 90, 30 )
        CameraSystem:attach()
        self.grid:draw()
        if self.currenttool ~= nil then
            self.currenttool:draw( mousepos.x, mousepos.y )
        end
        love.graphics.setColor( { 255, 255, 255, 155 } )
        love.graphics.line( -5, -5, 5, 5 )
        love.graphics.line( 5, -5, -5, 5 )
        love.graphics.print( "0, 0", 10, 10 )
        love.graphics.setColor( { 255, 255, 255, 255 } )
        CameraSystem:detach()
    end

    loveframes.draw()
end

function MapEditor:update( dt )
    BindSystem:update( dt )
    local mousepos = self.grid:getMouse()
    if self.currenttool ~= nil then
        self.currenttool:update( dt, mousepos.x, mousepos.y )
    end
    World:update( dt )
    DemoSystem:update( dt )
    loveframes.update( dt )
end

function MapEditor:mousepressed( x, y, button )
    local mousepos = self.grid:getMouse()
    -- Only use tools when we're not clicking on loveframe elements
    if #loveframes.util.GetCollisions() <= 1 then
        if self.currenttool ~= nil then
            self.currenttool:mousepressed( mousepos.x, mousepos.y, button )
        end
        if button == "wu" then
            CameraSystem:getActive():Zoom( 1.2 )
        elseif button == "wd" then
            CameraSystem:getActive():Zoom( 0.8 )
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
        Renderer:toggleFullbright()
    end
    if key == "escape" then
        self:setTool( self.tools[ 1 ] )
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
    Renderer:resize( w, h )
    World:resize( w, h )
end

return MapEditor
