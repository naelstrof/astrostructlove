local flashlight = {
    __name = "flashlight",
    components = {
        Components.drawable,
        Components.isitem,
        Components.emitslight,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/flashlight.png",
    description = "A battery powered flashlight. Can be used to turn on/off.",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/flashlight.png" ),
        lightdrawable = love.graphics.newImage( PackLocation .. "textures/flashlight_beam.jpg" ),
        lighttype = "ray",
        rotatecarry = true,
        use = function( e, player )
            if e:getLightIntensity() == 1.35 then
                e:setLightIntensity( 0 )
            else
                e:setLightIntensity( 1.35 )
            end
        end,
        layer = 3
    }
}

return flashlight
