local Starfield = love.class( { starfields = {} } )

function Starfield:addStarfield( e )
    table.insert( self.starfields, e )
    e.starfieldsIndex = table.maxn( self.starfields )
    e:createStarfield()
end

function Starfield:removeStarfield( e )
    table.remove( self.starfields, e.starfieldsIndex )
    -- Have to update all the indicies of all the other starfields.
    for i=e.starfieldsIndex, table.maxn( self.starfields ), 1 do
        self.starfields[i].starfieldsIndex = self.starfields[i].starfieldsIndex - 1
    end
end

function Starfield:update( dt )
    for i,v in pairs( self.starfields ) do
        v:updateStarfield( dt )
    end
end

return Starfield
