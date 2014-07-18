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
        -- Setting the light type to ray automatically sets the
        -- origin to the left of the light image, and does
        -- size calculations a little differently.
        lighttype = "ray",
        -- Makes it so players carrying the flashlight can
        -- rotate it towards their mouse
        rotatecarry = true,
        lightradius = 712,
        -- Light girth is a special variable only used when
        -- lighttype is a ray, lets you specify how wide the
        -- light beam is.
        lightgirth = 412,
        -- We set up a function hook that lets players turn on and
        -- off the flashlight
        use = function( e, player )
            if e:getLightIntensity() == 1.55 then
                e:setLightIntensity( 0 )
            else
                e:setLightIntensity( 1.55 )
            end
        end,
        layer = 3
    }
}

return { flashlight }
