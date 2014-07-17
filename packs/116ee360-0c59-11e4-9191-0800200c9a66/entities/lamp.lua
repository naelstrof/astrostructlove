local lamp = {
    __name = "lamp",
    components = {
        Components.drawable,
        Components.isitem,
        Components.emitslight,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/lamp.png",
    description = "A primitive oil lamp. Can be used to turn on/off.",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/lamp.png" ),
        lightdrawable = love.graphics.newImage( PackLocation .. "textures/lamp_point.png" ),
        lighttype = "point",
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

return { lamp }
