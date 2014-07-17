local walltileLD = {
    __name = "walltileLD",
    components = {
        Components.drawable,
        Components.blockslight,
        Components.physical,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/walltileLD.png",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/walltileLD.png" ),
        layer=3
    }
}

local walltileLR = {
    __name = "walltileLR",
    components = {
        Components.drawable,
        Components.blockslight,
        Components.physical,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/walltileLR.png",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/walltileLR.png" ),
        layer=3
    }
}

local walltileLRD = {
    __name = "walltileLRD",
    components = {
        Components.drawable,
        Components.blockslight,
        Components.physical,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/walltileLRD.png",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/walltileLRD.png" ),
        layer=3
    }
}

local walltileLRU = {
    __name = "walltileLRU",
    components = {
        Components.drawable,
        Components.blockslight,
        Components.physical,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/walltileLRU.png",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/walltileLRU.png" ),
        layer=3
    }
}

local walltileLRUD = {
    __name = "walltileLRUD",
    components = {
        Components.drawable,
        Components.blockslight,
        Components.physical,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/walltileLRUD.png",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/walltileLRUD.png" ),
        layer=3
    }
}

local walltileLU = {
    __name = "walltileLU",
    components = {
        Components.drawable,
        Components.blockslight,
        Components.physical,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/walltileLU.png",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/walltileLU.png" ),
        layer=3
    }
}

local walltileLUD = {
    __name = "walltileLUD",
    components = {
        Components.drawable,
        Components.blockslight,
        Components.physical,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/walltileLUD.png",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/walltileLUD.png" ),
        layer=3
    }
}

local walltileRD = {
    __name = "walltileRD",
    components = {
        Components.drawable,
        Components.blockslight,
        Components.physical,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/walltileRD.png",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/walltileRD.png" ),
        layer=3
    }
}

local walltileRU = {
    __name = "walltileRU",
    components = {
        Components.drawable,
        Components.blockslight,
        Components.physical,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/walltileRU.png",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/walltileRU.png" ),
        layer=3
    }
}

local walltileRUD = {
    __name = "walltileRUD",
    components = {
        Components.drawable,
        Components.blockslight,
        Components.physical,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/walltileRUD.png",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/walltileRUD.png" ),
        layer=3
    }
}

local walltileUD = {
    __name = "walltileUD",
    components = {
        Components.drawable,
        Components.blockslight,
        Components.physical,
        Components.networked,
        Components.default
    },
    image = PackLocation .. "textures/walltileUD.png",
    attributes = {
        drawable = love.graphics.newImage( PackLocation .. "textures/walltileUD.png" ),
        layer=3
    }
}

return { walltileLD, walltileLR, walltileLRD, walltileLRU, walltileLRUD, walltileLU, walltileLUD, walltileRD, walltileRU, walltileRUD, walltileUD }
