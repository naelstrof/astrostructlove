local Components = {}

function Components:load( dir, packlocation )
    local files = love.filesystem.getDirectoryItems( dir )
    for i,v in pairs( files ) do
        local s = string.find( v, "%.lua" )
        if s then
            local str = string.sub( v, 0, s - 1 )
            PackLocation = packlocation
            local component = require( dir .. str )
            if type( component ) == "boolean" then
                error( "Failed to load component " .. dir .. v .. " nothing was returned!" )
            elseif not component.__name then
                error( "Failed to load component " .. dir .. v .. " __name not supplied" )
            else
                if self[ str ] ~= nil then
                    print( "Overriden component " .. component.__name .. " with " .. v )
                end
                self[ str ] = component
            end
        else
            print( "Skipped " .. dir .. v .. " because it's not a lua file..." )
        end
    end
end

return Components
