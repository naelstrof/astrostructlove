local wallnames = {"LD", "LR", "LRD", "LRU", "LRUD", "LU", "LUD", "RD", "RU", "RUD", "UD"}
local walls = {}
for k,v in pairs( wallnames ) do
	table.insert(walls, {
	__name = "walltile" .. v,
	components = {
		Components.drawable,
		Components.blockslight,
		Components.physical,
		Components.networked,
		Components.default
	},
	image = PackLocation .. "textures/walltile" .. v .. ".png",
	attributes = {
		drawable = love.graphics.newImage( PackLocation .. "textures/walltile" .. v .. ".png" ),
		layer=3
	}
})
end

return walls
