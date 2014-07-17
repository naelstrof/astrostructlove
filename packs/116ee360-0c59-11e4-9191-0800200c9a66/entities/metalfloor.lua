metalfloor = {
    __name = "metalfloor",
    components = {
        Components.drawable,
        Components.floor,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/metalfloor.png",
    attributes = {
        drawable=love.graphics.newImage( PackLocation .. "textures/metalfloor.png" )
    }
}

return { metalfloor }
