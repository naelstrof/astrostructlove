local MapSystem = love.class( { } )

function MapSystem:save( filename )
    love.filesystem.createDirectory( "maps/" )
    filename = "maps/" .. filename .. ".txt"
    -- TODO: Error checking
    love.filesystem.write( filename, Tserial.pack( game.demosystem:generateFullSnapshot( false ) ) )
end

function MapSystem:load( filename )
    filename = "maps/" .. filename .. ".txt"
    -- TODO: Error checking
    game.entities:removeAll()
    local data = love.filesystem.read( filename )
    local snapshot = Tserial.unpack( data )
    for i,v in pairs( snapshot.added ) do
        local ent = game.entity:new( v.__name )
        for o,w in pairs( ent.networkedvars ) do
            local val = v[w]
            -- Call the coorisponding function to set the
            -- value
            if val ~= nil then
                ent[ ent.networkedfunctions[ o ] ]( ent, val )
            end
        end
    end
end

return MapSystem
