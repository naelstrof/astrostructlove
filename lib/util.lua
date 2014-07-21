-- Clamps a number to within a certain range
function math.clamp( n, low, high )
    return math.min( math.max( n, low ), high )
end

-- Does a simple shallow copy of a table
function table.copy( t )
    local copy = {}
    for i,v in pairs( t ) do
        if type( v ) == "table" then
            copy[i] = table.copy( v )
        else
            copy[i] = v
        end
    end
    return copy
end

-- Checks equality between two tables
function table.equals( t1, t2 )
    if #t1 ~= #t2 then return false end
    for i,v in pairs( t1 ) do
        if v ~= t2[i] then return false end
    end
    return true
end

-- Merges table b into table a
function table.merge( a, b )
    if not a and b then
        return b
    end
    if a and not b then
        return a
    end
    if not a and not b then
        return nil
    end
    for i,v in pairs( b ) do
        if type( a[ i ] ) == "table" and type( v ) == "table" then
            table.merge( a[ i ], v )
        else
            a[ i ] = v
        end
    end
    return a
end
