local ghost = {
    __name = "ghost",
    components = {
        Components.camera,
        Components.intangible,
        Components.controllable,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/logic.png",
    attributes = {}
}

return { ghost }
