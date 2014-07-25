floorlight = {
    __name = "floorlight",
    components = {
        Components.drawable,
        Components.floor,
        Components.emitslight,
        Components.networked,
        Components.ongrid,
        Components.default
    },
    image = PackLocation .. "textures/floorlight.png",
    attributes = {
        layer="floor",
        drawable = love.graphics.newImage( PackLocation .. "textures/floorlight.png" )
    }
}

return { floorlight }
