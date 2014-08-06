local Wall = {
    __name = "Wall",
    wallconfig = "",
    -- We network over the wall configuration, but just so that
    -- loading the map isn't as processor intensive
    -- Since it hardly ever changes it should hardly ever be networked
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
    -- This ugly thing describes possible configuration of shadow mesh,
    -- and indicates where walls would touch if they're touching so
    -- that specific faces can be removed.
    shapelookup = {
        None = {
            love.physics.newRectangleShape( 30, 8 ),
            love.physics.newRectangleShape( 8, 30 )
        },
        L = { love.physics.newRectangleShape( 30, 8 ) },
        LD = {
            love.physics.newRectangleShape( -5.5, 0, 19, 8, 0 ),
            love.physics.newRectangleShape( 0, 5.5, 8, 19, 0 )
        },
        R = { love.physics.newRectangleShape( 30, 8 ) },
        LR = { love.physics.newRectangleShape( 30, 8 ) },
        LRD = {
            love.physics.newRectangleShape( 30, 8 ),
            love.physics.newRectangleShape( 0, 5.5, 8, 19, 0 )
        },
        LRU = {
            love.physics.newRectangleShape( 30, 8 ),
            love.physics.newRectangleShape( 0, -5.5, 8, 19, 0 )
        },
        LRUD = {
            love.physics.newRectangleShape( 30, 8 ),
            love.physics.newRectangleShape( 8, 30 )
        },
        LU = {
            love.physics.newRectangleShape( -5.5, 0, 19, 8, 0 ),
            love.physics.newRectangleShape( 0, -5.5, 8, 19, 0 )
        },
        LUD = {
            love.physics.newRectangleShape( -5.5, 0, 19, 8, 0 ),
            love.physics.newRectangleShape( 8, 30 )
        },
        RD = {
            love.physics.newRectangleShape( 5.5, 0, 19, 8, 0 ),
            love.physics.newRectangleShape( 0, 5.5, 8, 19, 0 )
        },
        RU = {
            love.physics.newRectangleShape( 5.5, 0, 19, 8, 0 ),
            love.physics.newRectangleShape( 0, -5.5, 8, 19, 0 )
        },
        RUD = {
            love.physics.newRectangleShape( 5.5, 0, 19, 8, 0 ),
            love.physics.newRectangleShape( 8, 30 )
        },
        U = { love.physics.newRectangleShape( 8, 30 ) },
        D = { love.physics.newRectangleShape( 8, 30 ) },
        UD = { love.physics.newRectangleShape( 8, 30 ) }
    },
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
            { Vector( 32, 8 ), Vector( -32, 8 ) },
            { Vector( -32, 8 ), Vector( -32, -8 ) }
        },
        LD = {
            { Vector( -32, -8 ), Vector( 8, -8 ) },
            { Vector( 8, -8 ), Vector( 8, 32 ) },
            { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, 8 ) },
            { Vector( -8, 8 ), Vector( -32, 8 ) },
            { Vector( -32, 8 ), Vector( -32, -8 ) }
        },
        LR = {
            { Vector( -32, -8 ), Vector( 32, -8 ) },
            { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( -32, 8 ) },
            { Vector( -32, 8 ), Vector( -32, 8 ) }
        },
        LRD = {
            { Vector( -32, -8 ), Vector( 32, -8 ) },
            { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( 8, 8 ) },
            { Vector( 8, 8 ), Vector( 8, 32 ) },
            { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, 8 ) },
            { Vector( -8, 8 ), Vector( -32, 8 ) },
            { Vector( -32, 8 ), Vector( -32, -8 ) }
        },
        LRU = {
            { Vector( -32, -8 ), Vector( -8, -8 ) },
            { Vector( -8, -8 ), Vector( -8, -32 ) },
            { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, -8 ) },
            { Vector( 8, -8 ), Vector( 32, -8 ) },
            { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( -32, 8 ) },
            { Vector( -32, 8 ), Vector( -32, -8 ) }
        },
        LRUD = {
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
        LU = {
            { Vector( -32, -8 ), Vector( -8, -8 ) },
            { Vector( -8, -8 ), Vector( -8, -32 ) },
            { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, 8 ) },
            { Vector( 8, 8 ), Vector( -32, 8 ) },
            { Vector( -32, 8 ), Vector( -32, -8 ) }
        },
        LUD = {
            { Vector( -32, -8 ), Vector( -8, -8 ) },
            { Vector( -8, -8 ), Vector( -8, -32 ) },
            { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, 32 ) },
            { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, 8 ) },
            { Vector( -8, 8 ), Vector( -32, 8 ) },
            { Vector( -32, 8 ), Vector( -32, -8 ) }
        },
        R = {
            { Vector( -32, -8 ), Vector( 32, -8 ) },
            { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( -32, 8 ) },
            { Vector( -32, 8 ), Vector( -32, 8 ) }
        },
        RD = {
            { Vector( -8, -8 ), Vector( 32, -8 ) },
            { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( 8, 8 ) },
            { Vector( 8, 8 ), Vector( 8, 32 ) },
            { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, -8 ) }
        },
        RU = {
            { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, -8 ) },
            { Vector( 8, -8 ), Vector( 32, -8 ) },
            { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( -8, 8 ) },
            { Vector( -8, 8 ), Vector( -8, -32 ) }
        },
        RUD = {
            { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, -8 ) },
            { Vector( 8, -8 ), Vector( 32, -8 ) },
            { Vector( 32, -8 ), Vector( 32, 8 ) },
            { Vector( 32, 8 ), Vector( 8, 8 ) },
            { Vector( 8, 8 ), Vector( 8, 32 ) },
            { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, -32 ) }
        },
        U = {
            { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, 32 ) },
            { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, -32 ) }
        },
        D = {
            { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, 32 ) },
            { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, -32 ) }
        },
        UD = {
            { Vector( -8, -32 ), Vector( 8, -32 ) },
            { Vector( 8, -32 ), Vector( 8, 32 ) },
            { Vector( 8, 32 ), Vector( -8, 32 ) },
            { Vector( -8, 32 ), Vector( -8, -32 ) }
        }
    }
}

function Wall:updateWallConfig( safe )
    self.wallconfig = ""
    local pos = self:getPos()
    local ents = World:getEntitiesAtGrid( pos.x-64, pos.y )
    for i,v in pairs( ents ) do
        if v:hasComponent( Components.wall ) then
            if not safe then
                v:updateWallConfig( true )
            end
            self.wallconfig = self.wallconfig .. "L"
            break
        end
    end
    ents = World:getEntitiesAtGrid( pos.x+64, pos.y )
    for i,v in pairs( ents ) do
        if v:hasComponent( Components.wall ) then
            if not safe then
                v:updateWallConfig( true )
            end
            self.wallconfig = self.wallconfig .. "R"
            break
        end
    end
    ents = World:getEntitiesAtGrid( pos.x, pos.y-64 )
    for i,v in pairs( ents ) do
        if v:hasComponent( Components.wall ) then
            if not safe then
                v:updateWallConfig( true )
            end
            self.wallconfig = self.wallconfig .. "U"
            break
        end
    end
    ents = World:getEntitiesAtGrid( pos.x, pos.y+64 )
    for i,v in pairs( ents ) do
        if v:hasComponent( Components.wall ) then
            if not safe then
                v:updateWallConfig( true )
            end
            self.wallconfig = self.wallconfig .. "D"
            break
        end
    end
    if self.wallconfig == "" then
        self.wallconfig = "None"
    end
    self.drawable = self.drawablelookup[ self.wallconfig ]
    self.shadowmesh = self.shadowmeshlookup[ self.wallconfig ]
    if #self.shapelookup[ self.wallconfig ] <= 1 then
        self:setShape( self.shapelookup[ self.wallconfig ][1] )
    else
        self:setShape( self.shapelookup[ self.wallconfig ][1] )
        for i=2,#self.shapelookup[ self.wallconfig ] do
            self:addShape( self.shapelookup[ self.wallconfig ][i] )
        end
    end

end

function Wall:setWallConfig( conf )
    self.wallconfig = conf
    self.drawable = self.drawablelookup[ self.wallconfig ]
    self.shadowmesh = self.shadowmeshlookup[ self.wallconfig ]
    if #self.shapelookup[ self.wallconfig ] <= 1 then
        self:setShape( self.shapelookup[ self.wallconfig ][1] )
    else
        self:setShape( self.shapelookup[ self.wallconfig ][1] )
        for i=2,#self.shapelookup[ self.wallconfig ] do
            self:addShape( self.shapelookup[ self.wallconfig ][i] )
        end
    end
end

function Wall:init()
    if not self:hasComponent( Components.drawable ) or not self:hasComponent( Components.blockslight ) or not self:hasComponent( Components.ongrid ) then
        error( "An entity containing the wall component MUST contain the drawable, blockslight, and ongrid component as well!" )
    end
    for i,v in pairs( self.components ) do
        if v == Components.ongrid then
            break
        end
        if v == Components.wall then
            error( "The wall component must be included after the ongrid component! This is so that the wall can exist within the world before it updates other nearby walls." )
        end
    end
    if self.wallconfig == "" then
        self:updateWallConfig()
    end
end

return Wall
