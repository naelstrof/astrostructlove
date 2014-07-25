local metalwall = {
    __name = "metalwall",
    components = {
        Components.drawable,
        Components.blockslight,
        Components.physical,
        Components.ongrid,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/metalwall.png",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/metalwall.png" )
    }
}

return { metalwall }
