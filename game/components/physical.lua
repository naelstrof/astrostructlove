local setPos = function( e, t, byme )
    -- We need to know if we called the set position
    -- Given that setPos is chained through all the other components
    -- Knowing if the user set the position will move the physical object
    -- Otherwise if we're calling it, we're just trying to move the
    -- entire entity instead
    if not byme then
        e.body:setPosition( t.x, t.y )
    end
end

local setRot = function( e, rot, byme )
    if not byme then
        e.body:setAngle( rot )
    end
end

local update = function( e, dt )
    local x, y = e.body:getPosition()
    e:setPos( { x=x, y=y }, true )
    e:setRot( e.body:getAngle(), true )
end

local init = function( e )
    if not e.body then
        if e.static then
            e.body = love.physics.newBody( game.physics.world, e.pos.x, e.pos.y )
        else
            e.body = love.physics.newBody( game.physics.world, e.pos.x, e.pos.y, "dynamic" )
        end
        e.body:setMass( e.mass )
    end
    if not e.shape and e:hasComponent( compo.drawable ) then
        e.shape = love.physics.newRectangleShape( e.drawable:getWidth(), e.drawable:getHeight() )
    elseif not e.shape then
        e.shape = love.physics.newRectangleShape( 64, 64 )
    end
    if not e.fixture then
        e.fixture = love.physics.newFixture( e.body, e.shape )
    end
    if e.friction then
        local t = love.physics.newFrictionJoint( game.physics.surface, e.body, e.pos.x, e.pos.y, false )
        t:setMaxForce( e.body:getMass() * e.maxforce )
        t:setMaxTorque( e.body:getInertia() * e.maxtorque )
    end
end

local deinit = function( e )
end

local Physical = {
    __name = "Physical",
    body = nil,
    maxforce = 256,
    maxtorque = 5,
    static = true,
    friction = true,
    shape = nil,
    fixture = nil,
    mass = 70,
    update = update,
    init = init,
    deinit = deinit,
    setPos = setPos,
    setRot = setRot,
}

return Physical
