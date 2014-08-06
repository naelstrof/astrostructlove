local Physics = {
    world = nil,
    raytraces={},
    drawing = false,
    null = nil
}

function Physics:update( dt )
    self.world:update( dt )
end

function Physics:load()
    love.physics.setMeter( 64 )
    self.world = love.physics.newWorld( 0, 0, true )
    self.null = love.physics.newBody( self.world, 0, 0, "static" )
end

function Physics:rayCast( x1, y1, x2, y2, callback )
    if self.drawing then
        temporarypoints = {}
        local actualcallback = function( fixture, x, y, xn, yn, fraction )
            table.insert( temporarypoints, { x, y } )
            return callback( fixture, x, y, xn, yn, fraction )
        end
        self.world:rayCast( x1, y1, x2, y2, actualcallback )
        table.insert( self.raytraces, { lines={ x1, y1, x2, y2 }, points=temporarypoints } )
        temporarypoints = nil
    else
        self.world:rayCast( x1, y1, x2, y2, callback )
    end
end

function Physics:draw()
    -- Got this from a public forum post here:
    -- http://love2d.org/forums/viewtopic.php?f=5&t=77140#p161889 by
    -- username "Azhukar". He left no contact information.
    -- I assumed it was public use, but I haven't asked for permission yet
    -- TODO: ask for permission
    self.drawing = true
    local bodies = self.world:getBodyList()

    for b=#bodies,1,-1 do
        local body = bodies[b]
        local bx,by = body:getPosition()
        local bodyAngle = body:getAngle()
        love.graphics.push()
        love.graphics.translate(bx,by)
        love.graphics.rotate(bodyAngle)

        math.randomseed(1) --for color generation

        local fixtures = body:getFixtureList()
        for i=1,#fixtures do
            local fixture = fixtures[i]
            local shape = fixture:getShape()
            local shapeType = shape:getType()
            local isSensor = fixture:isSensor()

            if (isSensor) then
                love.graphics.setColor(0,0,255,96)
            else
                love.graphics.setColor(math.random(32,200),math.random(32,200),math.random(32,200),96)
            end

            love.graphics.setLineWidth(1)
            if (shapeType == "circle") then
                local x,y = fixture:getMassData() --0.9.0 missing circleshape:getPoint()
                --local x,y = shape:getPoint() --0.9.1
                local radius = shape:getRadius()
                love.graphics.circle("fill",x,y,radius,15)
                love.graphics.setColor(0,0,0,255)
                love.graphics.circle("line",x,y,radius,15)
                local eyeRadius = radius/4
                love.graphics.setColor(0,0,0,255)
                love.graphics.circle("fill",x+radius-eyeRadius,y,eyeRadius,10)
            elseif (shapeType == "polygon") then
                local points = {shape:getPoints()}
                love.graphics.polygon("fill",points)
                love.graphics.setColor(0,0,0,255)
                love.graphics.polygon("line",points)
            elseif (shapeType == "edge") then
                love.graphics.setColor(0,0,0,255)
                love.graphics.line(shape:getPoints())
            elseif (shapeType == "chain") then
                love.graphics.setColor(0,0,0,255)
                love.graphics.line(shape:getPoints())
            end
        end
        love.graphics.pop()
    end

    local joints = self.world:getJointList()
    for index,joint in pairs(joints) do
        love.graphics.setColor(0,255,0,255)
        local x1,y1,x2,y2 = joint:getAnchors()
        if (x1 and x2) then
            love.graphics.setLineWidth(3)
            love.graphics.line(x1,y1,x2,y2)
        else
            love.graphics.setPointSize(3)
            if (x1) then
                love.graphics.point(x1,y1)
            end
            if (x2) then
                love.graphics.point(x2,y2)
            end
        end
    end

    local contacts = self.world:getContactList()
    for i=1,#contacts do
        love.graphics.setColor(255,0,0,255)
        love.graphics.setPointSize(3)
        local x1,y1,x2,y2 = contacts[i]:getPositions()
        if (x1) then
            love.graphics.point(x1,y1)
        end
        if (x2) then
            love.graphics.point(x2,y2)
        end
    end

    for i,v in pairs( self.raytraces ) do
        love.graphics.setColor(255,255,0,96)
        love.graphics.setLineWidth(1)
        love.graphics.line( unpack( v.lines ) )
        for o,w in pairs( v.points ) do
            love.graphics.setColor(255,0,0,255)
            love.graphics.setPointSize(3)
            love.graphics.point( unpack( w ) )
        end
    end
    self.raytraces = {}
end

return Physics
