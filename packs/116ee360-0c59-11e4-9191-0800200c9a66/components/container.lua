local Container = {
    __name = "Container",
    items = {},
    -- Available types: bag, box
    -- Boxes volumes are static while bags expand with their inventory
    containertype = "bag",
    -- In liters
    volumecap = 5,
    basevolume = 0.1,
    volume = basevolume,
    volumecontained = 0,
    -- kilograms
    maxweight = 30,
    masscontained = 0,
    basemass = 0.1,
    gravity = 9.81,
    mass = basemass,
    networkinfo = {
        setItems = "items"
    }
}

function Container:getItems()
    -- we return a copy so it can't be edited
    local copy = {}
    for i,v in pairs( self.items ) do
        copy[i] = DemoSystem.entities[ v ]
    end
    return copy
end

function Container:canFit( ent )
    if self.volumecontained + v.volumecontained > self.volumecap or
       ( self.masscontained + v.masscontained ) * Physics.gravity  > self.weightcap then
       return false
    end
    return true
end

function Container:ejectItem( i )
    local item = DemoSystem.entities[ self.items[ i ] ]
    if not item then
        error( "Tried to eject nil item!" )
    end
    if item.volumecontained and item.masscontained then
        self.volumecontained = self.volumecontained - item.volumecontained
        self.masscontained = self.masscontained - item.masscontained
    end
    item.pos = self.pos
    -- Respawn the item
    item:init()
    -- Remove it from our list
    table.remove( self.items, i )
end

function Container:storeItem( ent )
    -- Check that we can fit the item
    if not item.volumecontained or not item.masscontained then
        return
    end
    if not self:canFit( ent ) then
       return
    end
    -- Despawn the item
    ent:deinit()
    -- then put it in our list
    table.insert( self.items, ent.demoIndex )
    self.volumecontained = self.volumecontained + v.volume
    self.masscontained = self.masscontained + v.mass
    if self.containertype == "bag" then
        self.volume = self.basevolume + self.volumecontained
    end
    self.mass = self.basemass + self.mass
end

function Container:setItems( items )
    self.items = items
end

function Container:init()
    for i,v in pairs( self:getItems() ) do
        if v.volume and v.mass then
            if not self:canFit( v ) then
                self:ejectItem( i )
            else
                self.volumecontained = self.volumecontained + v.volume
                self.masscontained = self.masscontained + v.mass
            end
        end
    end
    if self.containertype == "bag" then
        self.volume = self.basevolume + self.volumecontained
    end
    self.mass = self.basemass + self.mass
end

function Container:update( dt )
    -- Eject items that we can't hold!
    while self.mass * self.gravity > self.maxweight and self.items[ 1 ] ~= nil do
        self:ejectItem( 1 )
    end
end

return Container
