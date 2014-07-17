local metalwall = {
    __name = "metalwall",
    components = {
        Components.drawable,
        Components.blockslight,
        Components.physical,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/metalwall.png",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/metalwall.png" ),
        layer=3
    }
}

return { metalwall }
