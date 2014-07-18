local OptionSystem = { options = {} }

function OptionSystem:load()
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
        self.options[i] = v
    end
    for i,v in pairs( self.options ) do
        self:interpret( i, v )
    end
end

-- To the best of our abilities, interpret the options given.
function OptionSystem:interpret( i, v )
    -- Fullscreen option
    if i == "fullscreen" then
        if type( v ) ~= "boolean" then
            error( "Fullscreen option must be a boolean!" )
        end
        local width, height, flags = love.window.getMode()
        if flags.fullscreen ~= v then
            flags.fullscreen = v
            flags.fullscreentype = "desktop"
            love.window.setMode( width, height, flags )
        end
    end
end

function OptionSystem:setOption( i, v )
    self.options[ i ] = v
    self:interpret( i, v )
end

function OptionSystem:save()
    love.filesystem.createDirectory( "config" )
    -- We have to avoid copying __index
    local copy = {}
    for i,v in pairs( self.options ) do
        if i ~= "__index" then
            print("Index: " .. i)
            print(v)
            copy[i] = v
        end
    end
    -- Make sure to write it in a human readable fasion
    -- TODO: error checking
    love.filesystem.write( "config/init.txt" , Tserial.pack( copy, nil, true ) )
end

return OptionSystem
