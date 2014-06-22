local Default = {}

Default.____name = "Default"

Default.entities = {
    metalfloor = {
        __name="metalfloor",
        components={ compo.drawable, compo.networked },
        image="data/textures/metalfloor.png",
        attributes={ drawable=love.graphics.newImage( "data/textures/metalfloor.png" ) }
    },
    metalwall = {
        __name="metalwall",
        components={ compo.drawable, compo.blockslight, compo.networked },
        image="data/textures/metalwall.png",
        attributes={ drawable=love.graphics.newImage( "data/textures/metalwall.png" ), layer=3 }
    },
    lamp = {
        __name="lamp",
        components={ compo.drawable, compo.emitslight, compo.controllable, compo.networked },
        image="data/textures/lamp.png",
        attributes={ drawable=love.graphics.newImage( "data/textures/lamp.png" ), layer=3 }
    },
    controlpanel = {
        __name="controlpanel",
        components={ compo.drawable, compo.glows, compo.networked },
        image="data/textures/controlpanel.png",
        glowimage="data/textures/controlpanel_illumination.png",
        attributes={
                        drawable=love.graphics.newImage( "data/textures/controlpanel.png" ),
                        glowdrawable=love.graphics.newImage( "data/textures/controlpanel_illumination.png" ),
                        layer = 3
                   }
    },
    starfield = {
        __name="starfield",
        components={ compo.starfield, compo.networked },
        image="data/textures/logic.png",
        attributes={}
    },
    star= {
        __name="star",
        components={ compo.drawable },
        image="data/textures/star.png",
        attributes={ layer=1, drawable=love.graphics.newImage( "data/textures/star.png" ) }
    },
    ghost = {
        __name="ghost",
        components={ compo.camera, compo.controllable, compo.networked },
        image="data/textures/logic.png",
        attributes={}
    }
}

return Default
