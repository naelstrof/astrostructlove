local use = function( e, player )
    -- Do nothing by default!
end

local IsItem = {
    __name = "IsItem",
    mass = 1,
    volume = 1,
    use = use
}

return IsItem
