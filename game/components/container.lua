local getItems = function( e )
    -- we return a copy so it can't be edited
    local copy = {}
    for i,v in pairs( e.items ) do
        copy[i] = game.demosystem.entities[ v ]
    end
    return copy
end

local canFit = function( e, ent )
    if e.volumecontained + v.volumecontained > e.volumecap or
       ( e.masscontained + v.masscontained ) * game.physics.gravity  > e.weightcap then
       return false
    end
    return true
end

local ejectItem = function( e, i )
    local item = game.demosystem.entities[ e.items[ i ] ]
    if not item then
        error( "Tried to eject nil item!" )
    end
    if item.volumecontained and item.masscontained then
        e.volumecontained = e.volumecontained - item.volumecontained
        e.masscontained = e.masscontained - item.masscontained
    end
    item.pos = e.pos
    -- Respawn the item
    item:init()
    -- Remove it from our list
    table.remove( e.items, i )
end

local storeItem = function( e, ent )
    -- Check that we can fit the item
    if not item.volumecontained or not item.masscontained then
        return
    end
    if not e:canFit( ent ) then
       return
    end
    -- Despawn the item
    ent:deinit()
    -- then put it in our list
    table.insert( e.items, ent.demoIndex )
    e.volumecontained = e.volumecontained + v.volume
    e.masscontained = e.masscontained + v.mass
    if e.containertype == "bag" then
        e.volume = e.basevolume + e.volumecontained
    end
    e.mass = e.basemass + e.mass
end

local setItems = function( e, items )
    e.items = items
end

local init = function( e )
    for i,v in pairs( e:getItems() ) do
        if v.volume and v.mass then
            if not e:canFit( v ) then
                e:ejectItem( i )
            else
                e.volumecontained = e.volumecontained + v.volume
                e.masscontained = e.masscontained + v.mass
            end
        end
    end
    if e.containertype == "bag" then
        e.volume = e.basevolume + e.volumecontained
    end
    e.mass = e.basemass + e.mass
end

local update = function( e, dt )
    -- Eject items that we can't hold!
    while e.mass * game.physics.gravity > e.maxweight and e.items[ 1 ] ~= nil do
        e:ejectItem( 1 )
    end
end

local Container = {
    items = {},
    -- Available types: bag, box
    -- Boxes volumes are static while bags expand with their inventory
    containertype = "bag",
    -- In liters
    volumecap = 5,
    basevolume = 0.1,
    volume = basevolume,
    basevolume = 0.1,
    volumecontained = 0,
    -- kilograms
    maxweight = 30,
    masscontained = 0,
    basemass = 0.1,
    mass = basemass,
    getItems = getItems,
    setItems = setItems,
    update = update,
    networkedvars = { "items" },
    networkedfunctions = { "setItems" },
    init = init
}

return Container
