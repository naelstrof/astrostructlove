local MapSystem = {}

function MapSystem:save( filename )
    love.filesystem.createDirectory( "maps/" )
    filename = "maps/" .. filename .. ".txt"
    -- TODO: Error checking
    love.filesystem.write( filename, Tserial.pack( DemoSystem:generateSnapshot() ) )
end

function MapSystem:load( filename )
    filename = "maps/" .. filename .. ".txt"
    -- TODO: Error checking
    World:removeAll()
    local data = love.filesystem.read( filename )
    local snapshot = Tserial.unpack( data )
    for i,v in pairs( snapshot.entities ) do
        local ent = Entity:new( v.__name, { demoIndex=v.demoIndex } )
        for o,w in pairs( Entities.entities[ ent.__name ].networkinfo ) do
            local val = v[ w ]
            -- Call the coorisponding function to set the
            -- value
            if val ~= nil then
                if ent[ o ] == nil then
                    error( "Malformed networkinfo on entity " .. ent.__name .. "! Function " .. o .. " does not exist" )
                end
                ent[ o ]( ent, val )
            end
        end
    end
end

return MapSystem
