local wall = {
	__name = "wall",
	components = {
		Components.drawable,
		Components.blockslight,
		Components.physical,
		Components.networked,
		Components.default,
        -- wall HAS to come after default, since default spawns the wall
        -- into the world. Which lets nearby walls update their textures
        -- and shadowmeshs.
        Components.wall
	},
	image = PackLocation .. "textures/walltileLRUD.png",
	attributes = {
		drawable = love.graphics.newImage( PackLocation .. "textures/walltileLRUD.png" ),
        drawablelookup = {
            None = love.graphics.newImage( PackLocation .. "textures/walltileLRUD.png" ),
            L = love.graphics.newImage( PackLocation .. "textures/walltileLR.png" ),
            LD = love.graphics.newImage( PackLocation .. "textures/walltileLD.png" ),
            R = love.graphics.newImage( PackLocation .. "textures/walltileLR.png" ),
            LR = love.graphics.newImage( PackLocation .. "textures/walltileLR.png" ),
            LRD = love.graphics.newImage( PackLocation .. "textures/walltileLRD.png" ),
            LRU = love.graphics.newImage( PackLocation .. "textures/walltileLRU.png" ),
            LRUD = love.graphics.newImage( PackLocation .. "textures/walltileLRUD.png" ),
            LU = love.graphics.newImage( PackLocation .. "textures/walltileLU.png" ),
            LUD = love.graphics.newImage( PackLocation .. "textures/walltileLUD.png" ),
            RD = love.graphics.newImage( PackLocation .. "textures/walltileRD.png" ),
            RU = love.graphics.newImage( PackLocation .. "textures/walltileRU.png" ),
            RUD = love.graphics.newImage( PackLocation .. "textures/walltileRUD.png" ),
            U = love.graphics.newImage( PackLocation .. "textures/walltileUD.png" ),
            D = love.graphics.newImage( PackLocation .. "textures/walltileUD.png" ),
            UD = love.graphics.newImage( PackLocation .. "textures/walltileUD.png" )
        }
	}
}

return { wall }