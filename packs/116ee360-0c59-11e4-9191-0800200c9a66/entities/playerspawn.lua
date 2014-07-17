local playerspawn = {
    __name = "playerspawn",
    components = {
        Components.debugdrawable,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/logic.png",
    attributes = { }
}

return { playerspawn }
