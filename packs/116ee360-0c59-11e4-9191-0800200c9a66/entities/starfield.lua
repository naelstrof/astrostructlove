local starfield = {
    __name = "starfield",
    components = {
        Components.starfield,
        Components.networked,
        Components.debugdrawable,
        Components.default
    },
    image = PackLocation .. "textures/logic.png",
    attributes = {}
}

return starfield
