local controlpanel = {
    __name = "controlpanel",
    components = {
        Components.drawable,
        Components.glows,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/controlpanel.png",
    glowimage = PackLocation .. "textures/controlpanel_illumination.png",
    attributes = {
        drawable=love.graphics.newImage( PackLocation .. "textures/controlpanel.png" ),
        glowdrawable=love.graphics.newImage( PackLocation .. "textures/controlpanel_illumination.png" ),
        layer = 3
    }
}

return controlpanel
