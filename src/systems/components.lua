local Components = {}

function Components:load( dir )
    local files = love.filesystem.getDirectoryItems( dir )
    for i,v in pairs( files ) do
        local s = string.find( v, "%.lua" )
        local str = string.sub( v, 0, s - 1 )
        local component = require( dir .. str )
        if not component.__name then
            print( "Failed to load component " .. dir .. v .. " __name not supplied" )
        else
            if self[ str ] ~= nil then
                print( "Overriden component " .. component.__name .. " with " .. v )
            end
            self[ str ] = component
        end
    end
end

return Components
