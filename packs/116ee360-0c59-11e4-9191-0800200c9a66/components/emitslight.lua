local EmitsLight = {
    __name = "EmitsLight",
    shadowmeshdraw = nil,
    shadowobjects = {},
    changed = true,
    lighttype = "point",
    lightradius = 256,
    lightgirth = 256,
    lightsize = 32,
    lightdrawable = love.graphics.newImage( PackLocation .. "textures/point.png" ),
    -- light rotations will be random unless otherwise specified
    lightrot = nil,
    -- The timing in the light flicker is random too, unless otherwise specified
    lighttime = nil,
    lightoriginoffset = nil,
    lightscale = Vector( 1, 1 ),
    -- I set the light intensity to overflow due to the flickermap
    -- nearly halving it in all parts of the flicker
    baselightintensity = 1.55,
    networkinfo = {
        setLightIntensity = "baselightintensity"
    },
    lightintensity = baselightintensity,
    -- Uses "Flicker B" by default.
    lightflickermap = "nmonqnmomnmomomno"
}

function EmitsLight:updateShadowVolumes()
    if not self.changed then
        return
    end
    self.shadowobjects = {}
    self.changed = false
    local allverticies = {}
    local ents = World:getNearby( self:getPos(), self.lightradius )
    for i,v in pairs( ents ) do
        if v:hasComponent( Components.blockslight ) then
            table.insert( self.shadowobjects, v )
            local verts = v:getShadowVolume( self:getPos(), self.lightradius )
            for j,w in pairs( verts ) do
                table.insert( allverticies, w )
            end
        end
    end
    if table.maxn( allverticies ) > 1 then
        self.shadowmeshdraw = love.graphics.newMesh( allverticies, nil, "triangles" )
    end
end

function EmitsLight:update( dt )
    self:updateShadowVolumes()
    if type( self.lightflickermap ) ~= "table" then
        error( "Please use setFlickerMap() to set flicker maps!" )
    end
    -- Goes at 10 values a second
    self.lighttime = self.lighttime + ( dt * 10 )
    local pos = math.floor( self.lighttime % #self.lightflickermap ) + 1
    local npos = pos + 1
    if npos > #self.lightflickermap then
        npos = 1
    end
    local flickera = self.lightflickermap[ pos ]
    local flickerb = self.lightflickermap[ npos ]
    -- Just uses a simple linear function to interpolate the flickermap values
    local func = self.lighttime - math.floor( self.lighttime )
    local flicker =  flickera * (1-func) + flickerb * func
    self.lightintensity = self.baselightintensity * flicker
    -- Clamp between 0 and 1
    self.lightintensity = math.clamp( self.lightintensity, 0, 1 )
end

function EmitsLight:init()
    self.lightintensity = self.baselightintensity
    if self.lighttype == "point" then
        self.lightrot = self.lightrot or love.math.random()*math.pi*2
        self.lightoriginoffset = self.lightoriginoffset or Vector( self.lightdrawable:getWidth() / 2, self.lightdrawable:getHeight() / 2 )
        self.lightscale = Vector( self.lightradius*2/self.lightdrawable:getWidth(), self.lightradius*2/self.lightdrawable:getHeight() )
    elseif self.lighttype == "ray" then
        self.lightrot = self.rot
        self.lightoriginoffset = Vector( 0, self.lightdrawable:getHeight() / 2 )
        -- We use lightgirth on rays for height calculations
        self.lightscale = Vector( self.lightradius/self.lightdrawable:getWidth(), self.lightgirth/self.lightdrawable:getHeight() )
    end

    -- Convert the lightflickermap to more efficient values
    self:setFlickerMap( self.lightflickermap )

    -- Set the flicker time to a random value, this way if we create
    -- a ton of lights at once they'll flicker at different times
    self.lighttime = self.lighttime or ( love.math.random() * table.getn( self.lightflickermap ) )
    Renderer:addLight( self )
end

-- Converts a valve-style flickermap into floats
-- See https://developer.valvesoftware.com/wiki/Light#Appearances
function EmitsLight:setFlickerMap( flickermapstring )
    -- If the flickermap was already converted to a table then just use it
    if type( flickermapstring ) == "table" then
        self.lightflickermap = flickermapstring
        return
    end
    -- Otherwise we need to convert the string into a table of numbers.
    local flickermap = {}
    -- For each character
    for char in string.gmatch( flickermapstring, "." ) do
        -- 0 = a, 1 = z, m = 0.48
        local val = ( string.byte( char ) - 97 ) / 25
        table.insert( flickermap, val )
    end
    self.lightflickermap = flickermap
end

function EmitsLight:setPos( t )
    self.changed = true
end

function EmitsLight:setRot( r )
    self.lightrot = r
end

function EmitsLight:setRadius( r )
    self.lightradius = r
    self.changed = true
end

function EmitsLight:setLightIntensity( lightintensity )
    self.lightintensity = lightintensity
    self.baselightintensity = lightintensity
end

function EmitsLight:getLightIntensity()
    return self.baselightintensity
end

function EmitsLight:deinit()
    Renderer:removeLight( self )
end

return EmitsLight
