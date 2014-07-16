local star= {
    __name = "star",
    components = {
        Components.drawable,
        Components.default
    },
    image = PackLocation .. "textures/star.png",
    attributes = {
        layer=1,
        drawable=love.graphics.newImage( PackLocation .. "textures/star.png" )
    }
}

return star
