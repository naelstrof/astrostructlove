local player = {
    __name = "player",
    components = {
        Components.drawable,
        Components.camera,
        Components.hashands,
        Components.container,
        Components.physical,
        Components.controllable,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/human.png",
    attributes = {
        drawable=love.graphics.newImage( PackLocation .. "textures/human.png" ),
        physicstype="dynamic",
        shape=love.physics.newCircleShape( 10 ),
        smooth=true,
        mass=70,
        static=false
    }
}

return { player }
