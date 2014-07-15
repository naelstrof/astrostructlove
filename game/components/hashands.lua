
local processHand = function( e, hand, controls )
    if controls[ "hand"..hand ] ~= 1 then
        return
    end
    -- If nothing is in the hand
    -- we try to pick something up. (Even if we have modifiers pressed)
    if not e.handitems[ hand ] then
        -- Make sure we don't have any modifiers held
        if controls.throwmodifier ~= 1 and controls.dropmodifier ~= 1 then
            local ents = game.entities:getNearby( game.vector( controls.x, controls.y ), e.handsize )
            -- If we found something we put it in our hand
            for i,v in pairs( ents ) do
                -- We can only pick up items
                if v:hasComponent( compo.isitem ) then
                    e.handitems[ hand ] = v.demoIndex
                    break
                    -- We don't have to move the entity around since updateItems is called shortly after this
                end
            end
        end
    else
        -- If we have something in our hand, check for modifiers
        if controls.throwmodifier == 1 then
            -- throw
        elseif controls.dropmodifier == 1 then
            -- drop
            e.handitems[ hand ] = nil
        else
            -- use
            local ent = game.demosystem.entities[ e.handitems[ hand ] ]
            ent:use( e )
        end
    end
end

local update = function( e, dt, tick )
    -- Active runs is true when we're the active player being
    -- controlled by the client.
    -- tick is not nil when we're being ran in a simulation
    local controls = game.network:getControls( e.playerid, tick )
    if ( e.active and controls ~= nil ) or ( tick ~= nil and controls ~= nil ) then
        -- We go and see if any hand binds are pressed
        for i=1, 2 do
            if controls[ "hand"..i ] ~= e.handmemory[ "hand"..i ] then
                e:processHand( i, controls )
                e.handmemory[ "hand"..i ] = controls[ "hand"..i ]
            end
        end
    end
    e.updateItems( e, dt, tick )
end

local updateItems = function( e, dt, tick )
    local controls = game.network:getControls( e.playerid, tick )
    if controls then
        for i,v in pairs( e.handitems ) do
            local ent = game.demosystem.entities[ v ]
            ent:setPos( e:getPos() + e.handpositions[ i ]:rotated( e:getRot() ) )
            ent:setRot( ( e:getPos() + e.handpositions[ i ] ):angleTo( game.vector( controls.x, controls.y ) ) + math.pi )
        end
    end
end

local setHandItems = function( e, handitems )
    e.handitems = handitems
end

local init = function( e )
    -- Since complex types are lost when networked, we need to make sure
    -- handpositions contains actual vectors
    for i,v in pairs( e.handpositions ) do
        e.handpositions[ i ] = game.vector( v.x, v.y )
    end
end

local deinit = function( e )
end

local HasHands = {
    __name = "HasHands",
    handcount = 2,
    -- Used for lenient clicks
    handsize = 5,
    handpositions = {
        game.vector( -20, 5 ),
        game.vector( 20, 5 )
    },
    handitems = {},
    handmemory = {},
    update = update,
    setHandItems = setHandItems,
    networkedvars = { "handitems" },
    networkedfunctions = { "setHandItems" },
    updateItems = updateItems,
    processHand = processHand,
    init = init,
    deinit = deinit
}

return HasHands
