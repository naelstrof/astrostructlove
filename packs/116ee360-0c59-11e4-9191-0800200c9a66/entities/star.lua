local star= {
    __name = "star",
    components = {
        Components.drawable,
        Components.default
    },
    image = PackLocation .. "textures/star.png",
    attributes = {
        layer = "space",
        drawable=love.graphics.newImage( PackLocation .. "textures/star.png" )
    }
}

return { star }
