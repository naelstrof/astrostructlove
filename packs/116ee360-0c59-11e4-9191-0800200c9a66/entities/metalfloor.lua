metalfloor = {
    __name = "metalfloor",
    components = {
        Components.drawable,
        Components.floor,
        Components.networked,
        Components.ongrid,
        Components.default
    },
    image = PackLocation .. "textures/metalfloor.png",
    attributes = {
        frictioncoefficient = 32,
        layer = "floor",
        drawable=love.graphics.newImage( PackLocation .. "textures/metalfloor.png" )
    }
}

return { metalfloor }
