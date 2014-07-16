local Options = {}

function Options:load()
    -- TODO: error checking
    local data = love.filesystem.read( "config/init.txt" )
    if not data then
        return
    end
    local t = Tserial.unpack( data )
    -- Just copy everything over, things that use options just
    -- attempt to access the variable directly and should know to
    -- expect nil
    for i,v in pairs( t ) do
        self[i] = v
    end
end

function Options:save()
    love.filesystem.createDirectory( "config/" )
    -- We have to avoid copying __index
    local copy = {}
    for i,v in pairs( self ) do
        if i ~= "__index" then
            copy[i] = v
        end
    end
    -- Make sure to write it in a human readable fasion
    -- TODO: error checking
    love.filesystem.write( filename, Tserial.pack( copy, nil, true ) )
end

return Options
