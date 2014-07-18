local setFrictionCoefficient = function( e, f )
    --e.frictioncoefficient = f
end

local Floor = {
    __name = "Floor",
    -- Coefficient of metal
    frictioncoefficient = 20,
    setFrictionCoefficient = setFrictionCoefficient,
    networkinfo = {
        setFrictionCoefficient = "frictioncoefficient"
    }
}

return Floor
