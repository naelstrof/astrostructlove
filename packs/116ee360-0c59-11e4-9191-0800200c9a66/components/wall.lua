local updateWallConfig = function( e, safe )
    e.wallconfig = ""
    local pos = e:getPos()
    local ents = World:getEntitiesAtGrid( pos.x-64, pos.y )
    for i,v in pairs( ents ) do
        if v:hasComponent( Components.wall ) then
            if not safe then
                v:updateWallConfig( true )
            end
            e.wallconfig = e.wallconfig .. "L"
            break
        end
    end
    ents = World:getEntitiesAtGrid( pos.x+64, pos.y )
    for i,v in pairs( ents ) do
        if v:hasComponent( Components.wall ) then
            if not safe then
                v:updateWallConfig( true )
            end
            e.wallconfig = e.wallconfig .. "R"
            break
        end
    end
    ents = World:getEntitiesAtGrid( pos.x, pos.y-64 )
    for i,v in pairs( ents ) do
        if v:hasComponent( Components.wall ) then
            if not safe then
                v:updateWallConfig( true )
            end
            e.wallconfig = e.wallconfig .. "U"
            break
        end
    end
    ents = World:getEntitiesAtGrid( pos.x, pos.y+64 )
    for i,v in pairs( ents ) do
        if v:hasComponent( Components.wall ) then
            if not safe then
                v:updateWallConfig( true )
            end
            e.wallconfig = e.wallconfig .. "D"
            break
        end
    end
    if e.wallconfig == "" then
        e.wallconfig = "None"
    end
    e.drawable = e.drawablelookup[ e.wallconfig ]
    e.shadowmesh = e.shadowmeshlookup[ e.wallconfig ]
end

local setWallConfig = function( e, conf )
    e.wallconfig = conf
    e.drawable = e.drawablelookup[ e.wallconfig ]
    e.shadowmesh = e.shadowmeshlookup[ e.wallconfig ]
end

local init = function( e )
    if not e:hasComponent( Components.drawable ) or not e:hasComponent( Components.blockslight ) or not e:hasComponent( Components.ongrid ) then
        error( "An entity containing the wall component MUST contain the drawable, blockslight, and ongrid component as well!" )
    end
    for i,v in pairs( e.components ) do
        if v == Components.ongrid then
            break
        end
        if v == Components.wall then
            error( "The wall component must be included after the ongrid component! This is so that the wall can exist within the world before it updates other nearby walls." )
        end
    end
    if e.wallconfig == "" then
        e:updateWallConfig()
    end
end

local Wall = {
    __name = "Wall",
    wallconfig = "",
    -- We network over the wall configuration, but just so that
    -- loading the map isn't as processor intensive
    -- Since it hardly ever changes it should hardly ever be networked
    setWallConfig = setWallConfig,
    networkinfo = {
        setWallConfig = "wallconfig"
    },
    drawablelookup = {
        None = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        L = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        LD = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        R = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        LR = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        LRD = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        LRU = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        LRUD = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        LU = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        LUD = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        RD = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        RU = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        RUD = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        U = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        D = love.graphics.newImage( PackLocation .. "textures/null.png" ),
        UD = love.graphics.newImage( PackLocation .. "textures/null.png" )
    },
    init = init,
    updateWallConfig = updateWallConfig,
    -- This ugly thing describes possible configuration of shadow mesh,
    -- and indicates where walls would touch if they're touching so
    -- that specific faces can be removed.
    shadowmeshlookup = {
        None = {
            { Vector( -32, -8 ), Vector( -8, -8 ) },
            { Vector( -8, -8 ), Vector( -8, -32 ) },
            { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, -8 ) },
            { Vector( 8, -8 ), Vector( 32, -8 ) },
            { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( 8, 8 ) },
            { Vector( 8, 8 ), Vector( 8, 32 ) },
            { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, 8 ) },
            { Vector( -8, 8 ), Vector( -32, 8 ) },
            { Vector( -32, 8 ), Vector( -32, -8 ) }
        },
        L = {
            { Vector( -32, -8 ), Vector( 32, -8 ) },
            { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( -32, 8 ) }
            -- L = { Vector( -32, 8 ), Vector( -32, 8 ) }
        },
        LD = {
            { Vector( -32, -8 ), Vector( 8, -8 ) },
            { Vector( 8, -8 ), Vector( 8, 32 ) },
            -- D = { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, 8 ) },
            { Vector( -8, 8 ), Vector( -32, 8 ) }
            -- L = { Vector( -32, 8 ), Vector( -32, -8 ) }
        },
        LR = {
            { Vector( -32, -8 ), Vector( 32, -8 ) },
            -- R = { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( -32, 8 ) }
            -- L = { Vector( -32, 8 ), Vector( -32, 8 ) }
        },
        LRD = {
            { Vector( -32, -8 ), Vector( 32, -8 ) },
            -- R = { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( 8, 8 ) },
            { Vector( 8, 8 ), Vector( 8, 32 ) },
            -- D = { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, 8 ) },
            { Vector( -8, 8 ), Vector( -32, 8 ) }
            -- L = { Vector( -32, 8 ), Vector( -32, -8 ) }
        },
        LRU = {
            { Vector( -32, -8 ), Vector( -8, -8 ) },
            { Vector( -8, -8 ), Vector( -8, -32 ) },
            -- U = { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, -8 ) },
            { Vector( 8, -8 ), Vector( 32, -8 ) },
            -- R = { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( -32, 8 ) }
            -- L = { Vector( -32, 8 ), Vector( -32, -8 ) }
        },
        LRUD = {
            { Vector( -32, -8 ), Vector( -8, -8 ) },
            { Vector( -8, -8 ), Vector( -8, -32 ) },
            -- U = { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, -8 ) },
            { Vector( 8, -8 ), Vector( 32, -8 ) },
            -- R = { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( 8, 8 ) },
            { Vector( 8, 8 ), Vector( 8, 32 ) },
            -- D = { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, 8 ) },
            { Vector( -8, 8 ), Vector( -32, 8 ) }
            -- L = { Vector( -32, 8 ), Vector( -32, -8 ) }
        },
        LU = {
            { Vector( -32, -8 ), Vector( -8, -8 ) },
            { Vector( -8, -8 ), Vector( -8, -32 ) },
            -- U = { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, 8 ) },
            { Vector( 8, 8 ), Vector( -32, 8 ) }
            -- L = { Vector( -32, 8 ), Vector( -32, -8 ) }
        },
        LUD = {
            { Vector( -32, -8 ), Vector( -8, -8 ) },
            { Vector( -8, -8 ), Vector( -8, -32 ) },
            -- U = { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, 32 ) },
            -- D = { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, 8 ) },
            { Vector( -8, 8 ), Vector( -32, 8 ) }
            -- L = { Vector( -32, 8 ), Vector( -32, -8 ) }
        },
        R = {
            { Vector( -32, -8 ), Vector( 32, -8 ) },
            -- R = { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( -32, 8 ) },
            { Vector( -32, 8 ), Vector( -32, 8 ) }
        },
        RD = {
            { Vector( -8, -8 ), Vector( 32, -8 ) },
            -- R = { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( 8, 8 ) },
            { Vector( 8, 8 ), Vector( 8, 32 ) },
            -- D = { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, -8 ) }
        },
        RU = {
            -- U = { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, -8 ) },
            { Vector( 8, -8 ), Vector( 32, -8 ) },
            -- R = { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( -8, 8 ) },
            { Vector( -8, 8 ), Vector( -8, -32 ) }
        },
        RUD = {
            -- U = { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, -8 ) },
            { Vector( 8, -8 ), Vector( 32, -8 ) },
            -- R = { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( 8, 8 ) },
            { Vector( 8, 8 ), Vector( 8, 32 ) },
            -- D = { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, -32 ) }
        },
        U = {
            -- U = { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, 32 ) },
            { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, -32 ) }
        },
        D = {
            { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, 32 ) },
            -- D = { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, -32 ) }
        },
        UD = {
            -- U = { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, 32 ) },
            -- D = { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, -32 ) }
        }
    }
}

return Wall
