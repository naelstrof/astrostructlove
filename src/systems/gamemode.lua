local Gamemode = {}

function Gamemode:setGamemode( name )
    if self.packs then
        for i,v in pairs( self.packs ) do
            love.filesystem.unmount( v )
        end
    end
    local xs = require( "gamemodes/" .. name )
    self.__name =       xs.__name
    self.map =          xs.map
    self.packs =        xs.packs
    self.spawnPlayer =  xs.spawnPlayer
    local mountdir = "game"
    for i,v in pairs( self.packs ) do
        love.filesystem.createDirectory( mountdir )
        assert( love.filesystem.mount( "downloads/" .. v, mountdir ) )
        Components:load( mountdir .. "/" .. v .. "/components/" )
        Entities:load( mountdir .. "/" .. v .. "/entities/" )
    end
    return self
end

function Gamemode:getGamemodes()
    local gamemodes = love.filesystem.getDirectoryItems( "gamemodes/" )
    local t = {}
    for i,v in pairs( gamemodes ) do
        -- default.lua --> default
        local s = string.find( v, "%.lua" )
        local str = string.sub( v, 0, s - 1 )
        table.insert( t, str )
    end
    return t
end

return Gamemode
