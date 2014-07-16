local Entities = {}

function Entities:load( dir, packlocation )
    local files = love.filesystem.getDirectoryItems( dir )
    for i,v in pairs( files ) do
        local s = string.find( v, "%.lua" )
        local str = string.sub( v, 0, s - 1 )
        PackLocation = packlocation
        local entity = require( dir .. str )
        if not entity.__name then
            print( "Failed to load entity " .. dir .. v .. " __name not supplied" )
        else
            if self[ entity.__name ] ~= nil then
                print( "Overriden entity " .. entity.__name .. " with " .. v )
            end
            self[ entity.__name ] = entity
        end
    end
    self:generateNetworkInfo()
end

function Entities:generateNetworkInfo()
    for i,ent in pairs( self ) do
        if type( ent ) == "table" then
            ent.networkinfo = {}
            for o,comp in pairs( ent.components ) do
                table.merge( ent.networkinfo, comp.networkinfo )
            end
        end
    end
end

return Entities
