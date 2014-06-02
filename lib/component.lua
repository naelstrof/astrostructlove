-- Components describe entities by placing them in their specified
-- systems and assigning default values.

-- The default component does nothing, it's meant to be inherited.

local Component = love.class()

Component.__name = "Component"

function Component:init( e )
end

function Component:deinit( e )
end

return Component
