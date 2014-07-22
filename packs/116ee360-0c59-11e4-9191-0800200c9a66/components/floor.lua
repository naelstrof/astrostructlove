local Floor = {
    __name = "Floor",
    -- Coefficient of metal
    frictioncoefficient = 20,
    networkinfo = {
        setFrictionCoefficient = "frictioncoefficient"
    }
}

function Floor:setFrictionCoefficient( f )
    --self.frictioncoefficient = f
end

return Floor
