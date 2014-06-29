--[[            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE*
                         Version 2, December 2004

        TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION:

        0. You just DO WHAT THE FUCK YOU WANT TO.

    ========================================================================    
      *look up the full license text by yourself, it only takes 10 seconds
    ========================================================================
	
    Common Organization of Controls Kit, version 1.3
    Copyright © 2013 Raidho36, the Pink Square Huge Jerk
	
	wiki page: http://www.love2d.org/wiki/Common_Organization_of_Controls_Kit
	project page: http://raidho36.net/stuff/cock
	
	REMARKS:
		* this library assumes you provide valid data, it won't handle programmers' errors, and foul code will most likely bluescreen with random error message
		* this code only nil-ing values to actually delete them, to unset them, it uses zeroes or falses
		* as of 0.8.0 which uses SDL1.2, under Windows XBox360 controller is not fully functional: both triggers are mapped to the same axis
		* delta modes yield delta value instead of absolute value; cutoff mode cuts off negative values
		* whole axis mode converts whole axis range -1..1 to 0..1, only works with joystick axis for obvious reasons; whole axis mode and deadzones ain't good friends
		* this library uses lookup table to resolve remapped/remodded joystick hats, I think it's way more effecient that way
		* text generating functions are kinda expensive and produce garbage, so lookup tables go out of bounds by having some of the computed values hard-coded in
		* callbacks are causing events flood pretty bad, so they're all disabled by default
		* some functions don't support colon notation, or have different sets of arguments, see the comments
		* many functions have down the letter identical snippets, these aren't chinese-style copypasted code, these are inlined functions (small functions needs to be inlined due to call overhead and Lua can't do it on it's own)
		* dummy joysticks only serve to be a placeholder to avoid functionality break on minor failures, but aren't actually handled
		
	TODO (sorted by priority):
		* make demos
		* proper XBox360 controller support (somewhat works for windows, doesn't work for other OSes)
		* love callback-based partial update (since 0.9.0)
		* add :load :save
		* detach joysticks from control objects
		* create a "verbose" version
		* add cropUnusedJoysticks 
		* add broad feature axis amplifiers
		
	CHANGELOG:
		1.3:
			fixed:
			* code refactoring; improved consistency
			* fixed broken event handler locks
			* generating random IDs now work properly
			* fixed issue with spacebar key and :explodeCapturedData/:bind ( unexplodedData ) functions
			* fixed all :*Joystick* functions.
			* :addJoystick will now create a dummy joystick if it's impossible to actually create the joystick
			added:
			* .defaultOption and defaultConfig fields
			* :convertJoystickHat, :convertJoystickHatMode, :convertKey
			* :find returns control object with given ID
			* :updateAll updates all registered objects
			* :addJoystick and :removeJoystick (handled automatically)
			* .controlcaptured, .controlpeaked, .controlzeroed, .controlpressed, .controlreleased, .controlchanged callbacks
			* :setCallbacks for enabling/disabling above callbacks
			* :getCapture function
			* addded 4-way diagonal hat mode (4-way input, diagonal input generates both conjuncted directions input)
			chagned:
			* control objects now have unique identifiers
			* control binds data will no longer accept one-default arranged data
			* event callbacks are now supplied with ID of the sender object
			* all joystick-related functions now have "device id" field which specifies the joystick used in terms of control object
			* :setDefaultXBox360 now accepts device ID to use
			* :capturedDataExplode renamed to :explodeCapturedData (lol)
			* :getConverted* renamed to :convert*
			* conversion functions now have argument "literal" to force either literal or numerical output
			* :getBinded and pals are now return raw unconverted data
			* :setCapture function will now by default invoke the callback
			* renamed joystick hat modes
			* lookup tables will now grow further to avoid extra garbage/increase function performance
			* :setDefaultXBox360 now returns joystick ID (could change)
			removed:
			* :setControlMode and pals
			* :setDefaultXBox360 for Linux and OS X
			
		1.2:
			fixed:
			* a bunch of potential pitfalls
			* joystick axes and hats are now correctly captured
			added:
			* multiple binds per action via "options" tables
			* :setJoystickDeadzone and getJoystickDeadzone gets and sets joystick deadzone per axis
			* :getJoysticksList returns list of all found joysticks names and numbers
			* :remapJoystickHat maps four joystick buttons to act like joystick hat
			* :bind directly binds mappings
			* :getBinded returns list of binds for map
			* :getEmptyOption returns next (in arbitrary order) unused option for map
			* :getControlModesList returns list of all control modess
			* :getConvertedDevice, :getConvertedAxis, :getConvertedInverse, :getConvertedDelta
			* cutoff delta modes and inversion modes (only pass positive/negative part)
			* :setDefaultXBox360 function (currently used XBox360 controller API in Windows version sucks pretty hard)
			* :capturedDataExplode helper function (can't pass table to LÖVE's events)
			changed:
			* :setCapture now accepts "callback" argument to be used instead of instant automatical binding
			* :grab now would either call callback function or instantly bind captured input
			* :unset renamed to :unbind
			* controls data table for assignment now have different format
			* :getJoystickHatMode and :getControlMode now only return literal value
			* joystick axis delta mode no longer requires stick to be on the corresponding side either (that was silly, too)
			* added two-way delta modes
			* added no-cutoff for negative values for inversion
			removed:
			* :getDeviceName (replaced with :getBinded)

		1.1: 
			fixed:
			* capturing an input now sets both .previous and .current tables to captured input value
			* mouse axis delta mode no longer requires mouse pointer to be on the corresponding side of the offset (that was silly)
			added:
			* :getDeviceName function returns literal name of a device assiged to specified map
			changed:
			* :reloadJoystick now returns true on success
		
		1.0: 
			* first release version
--]]

--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--
--==                               SYSTEM                                  ==--
--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--
local cock = { ["_capture"] = { ["object"] = false, ["map"] = false, ["option"] = false, ["mouse"] = false, ["eventlock"] = false, ["updatelock"] = false, ["callback"] = false }, ["_objects"] = { }, ["joysticks"] = { } }

love.handlers.controlcaptured = function ( id, longarg ) if cock.controlcaptured then return cock.controlcaptured ( id, longarg ) else return cock.bind ( cock.find ( id ), longarg ) end end 
love.handlers.controlpressed = function ( id, k, v ) if cock.controlpressed then return cock.controlpressed ( id, k, v ) end end
love.handlers.controlreleased = function ( id, k, v ) if cock.controlreleased then return cock.controlreleased ( id, k, v ) end end
love.handlers.controlpeaked = function ( id, k, v ) if cock.controlpeaked then return cock.controlpeaked ( id, k, v ) end end
love.handlers.controlzeroed = function ( id, k, v ) if cock.controlzeroed then return cock.controlzeroed ( id, k, v ) end end
love.handlers.controlchanged = function ( id, k, v ) if cock.controlchanged then return cock.controlchanged ( id, k, v ) end end

local lk_isDown = love.keyboard.isDown
local lm_getX = love.mouse.getX
local lm_getY = love.mouse.getY
local lm_isDown = love.mouse.isDown
local lm_setPosition = love.mouse.setPosition
local lj_isDown = love.joystick.isDown
local lj_getAxis = love.joystick.getAxis
local lj_getHat = love.joystick.getHat
local lj_getNumJoysticks = love.joystick.getNumJoysticks
local lj_getNumAxes = love.joystick.getNumAxes
local lj_getNumHats = love.joystick.getNumHats
local lj_isOpen = love.joystick.isOpen
local lj_open = love.joystick.open
local lj_getName = love.joystick.getName
local le_push = love.event.push
local le_pump = love.event.pump
local lg_getWidth = love.graphics.getWidth
local lg_getHeight = love.graphics.getHeight
local table_insert = table.insert
local table_remove = table.remove
local mabs, mmin, mmax, mrand = math.abs, math.min, math.max, math.random

local l_keypressed, l_keyreleased = 0, 0
local l_mousepressed, l_mousereleased = 0, 0
local l_joystickpressed, l_joystickreleased = 0, 0
local l_controlpressed, l_controlreleased = 0, 0
local l_controlpeaked, l_controlzeroed = 0, 0
local l_controlchanged, l_update = 0, 0

local _hataliases = { [1] = { ["c"] = { }, ["u"] = { "u", ["u"] = true }, ["d"] = { "d", ["d"] = true }, ["l"] = { "l", ["l"] = true }, ["r"] = { "r", ["r"] = true }, ["lu"] = { "lu", ["lu"] = true }, ["ld"] = { "ld", ["ld"] = true }, ["ru"] = { "ru", ["ru"] = true }, ["rd"] = { "rd", ["rd"] = true } },
	[2] = { ["c"] = { }, ["u"] = { "u", ["u"] = true }, ["d"] = { "d", ["d"] = true }, ["l"] = { "l", ["l"] = true }, ["r"] = { "r", ["r"] = true }, ["lu"] = { "l", ["l"] = true }, ["ld"] = { "l", ["l"] = true }, ["ru"] = { "r", ["r"] = true }, ["rd"] = { "r", ["r"] = true } },
	[3] = { ["c"] = { }, ["u"] = { "u", ["u"] = true }, ["d"] = { "d", ["d"] = true }, ["l"] = { "l", ["l"] = true }, ["r"] = { "r", ["r"] = true }, ["lu"] = { "u", ["u"] = true }, ["ld"] = { "d", ["d"] = true }, ["ru"] = { "u", ["u"] = true }, ["rd"] = { "d", ["d"] = true } },
	[4] = { ["c"] = { }, ["u"] = { "u", ["u"] = true }, ["d"] = { "d", ["d"] = true }, ["l"] = { "l", ["l"] = true }, ["r"] = { "r", ["r"] = true }, ["lu"] = { "u", ["u"] = true }, ["ld"] = { "l", ["l"] = true }, ["ru"] = { "r", ["r"] = true }, ["rd"] = { "d", ["d"] = true } },
	[5] = { ["c"] = { }, ["u"] = { "u", ["u"] = true }, ["d"] = { "d", ["d"] = true }, ["l"] = { "l", ["l"] = true }, ["r"] = { "r", ["r"] = true }, ["lu"] = { "l", ["l"] = true }, ["ld"] = { "d", ["d"] = true }, ["ru"] = { "u", ["u"] = true }, ["rd"] = { "r", ["r"] = true } },
	[6] = { ["c"] = { }, ["u"] = { "u", ["u"] = true }, ["d"] = { "d", ["d"] = true }, ["l"] = { "l", ["l"] = true }, ["r"] = { "r", ["r"] = true }, ["lu"] = { "l", ["l"] = true, ["u"] = true }, ["ld"] = { "l", ["l"] = true, ["d"] = true }, ["ru"] = { "r", ["r"] = true, ["u"] = true }, ["rd"] = { "r", ["r"] = true, ["d"] = true } } }
local _hatbitfield = { "c", "u", "d", "c", "l", "lu", "ld", "l", "r", "ru", "rd", "r", "c", "u", "d", "c" }

local _lookup_hatmodes = { "8-way", "4-way vertical", "4-way horizontal", "4-way clockwise", "4-way counter-clockwise", "4-way diagonal"; ["8-way"] = 1, ["4-way vertical"] = 2, ["4-way horizontal"] = 3, ["4-way clockwise"] = 4, ["4-way counter-clockwise"] = 5, ["4-way diagonal"] = 6 }
local _lookup_devices = { "keyboard", "mouse button", "mouse axis", "joystick button", "joystick axis", "joystick hat"; ["keyboard"] = 1, ["mouse button"] = 2, ["mouse axis"] = 3, ["joystick button"] = 4, ["joystick axis"] = 5, ["joystick hat"] = 6, ["joystick hat 1"] = 6 }
local _lookup_axis = { "x", "y", "z", "r", "u", "v"; ["x"] = 1, ["y"] = 2, ["z"] = 3, ["r"] = 4, ["u"] = 5, ["v"] = 6 }  
local _lookup_modes = { [-3] = "-=", [-2] = "--", [-1] = "-", [0] = "=", [1] = "+", [2] = "++", [3] = "+="; ["-="] = -3, ["--"] = -2, ["-"] = -1, ["="] = 0, ["+"] = 1, ["++"] = 2, ["+="] = 3; ["negative whole"] = -3, ["negative cutoff"] = -2, ["negative"] = 1, ["bypass"] = 0, ["positive"] = 1, ["positive cutoff"] = 2, ["positive whole"] = 3 }

-- controls capture wrappers
local function wrapper_update ( dt )
	if not cock._capture.updatelock and l_update then l_update ( dt ) end
	cock._capture.object:grab ( )
end

local function wrapper_keypressed ( key, uni )
	if not cock._capture.eventlock and l_keypressed then l_keypressed ( key, uni ) end
	cock._capture.object:grab ( nil, nil, 1, key )
end

local function wrapper_mousepressed ( x, y, key )
	if not cock._capture.eventlock and l_mousepressed then l_mousepressed ( x, y, key ) end
	cock._capture.object:grab ( nil, nil, 2, key )
end

local function wrapper_joystickpressed ( joy, key )
	if not cock._capture.eventlock and l_joystickpressed then l_joystickpressed ( joy, key ) end
	cock._capture.object:grab ( nil, nil, 4, key, nil, nil, joy )
end

local function wrapper_keyreleased ( key, uni )
	if not cock._capture.eventlock and l_keyreleased then l_keyreleased ( key, uni ) end
end

local function wrapper_mousereleased ( x, y, key )
	if not cock._capture.eventlock and l_mousereleased then l_mousereleased ( x, y, key ) end
end

local function wrapper_joystickreleased ( joy, key )
	if not cock._capture.eventlock and l_joystickreleased then l_joystickreleased ( joy, key ) end
end

local function wrapper_controlpressed ( id, k, v )
	if not cock._capture.eventlock and l_controlpressed then l_controlpressed ( id, k, v ) end
end

local function wrapper_controlreleased ( id, k, v )
	if not cock._capture.eventlock and l_controlreleased then l_controlreleased ( id, k, v ) end
end

local function wrapper_controlpeaked ( id, k, v )
	if not cock._capture.eventlock and l_controlpeaked then l_controlpeaked ( id, k, v ) end
end

local function wrapper_controlzeroed ( id, k, v )
	if not cock._capture.eventlock and l_controlzeroed then l_controlzeroed ( id, k, v ) end
end

local function wrapper_controlchanged ( id, k, v )
	if not cock._capture.eventlock and l_controlchanged then l_controlchanged ( id, k, v ) end
end

-- I could've fit that into a loop so it would look prettier, but who gives a shit about code prettines? KISS & DFWNB
local function wrapperRestore ( )
	love.update = l_update
	love.keypressed = l_keypressed
	love.keyreleased = l_keyreleased
	love.mousepressed = l_mousepressed
	love.mousereleased = l_mousereleased
	love.joystickpressed = l_joystickpressed
	love.joystickreleased = l_joystickreleased
	cock.controlpressed = l_controlpressed
	cock.controlreleased = l_controlreleased
	cock.controlpeaked = l_controlpeaked
	cock.controlzeroed = l_controlzeroed
	cock.controlchanged = l_controlchanged
end

local function wrapperSetup ( )
	l_update = love.update
	l_keypressed = love.keypressed
	l_keyreleased = love.keyreleased
	l_mousepressed = love.mousepressed
	l_mousereleased = love.mousereleased
	l_joystickpressed = love.joystickpressed
	l_joystickreleased = love.joystickreleased
	l_controlpressed = cock.controlpressed
	l_controlreleased = cock.controlreleased
	l_controlpeaked = cock.controlpeaked
	l_controlzeroed = cock.controlzeroed
	l_controlchanged = cock.controlchanged
	
	love.update = wrapper_update
	love.keypressed = wrapper_keypressed
	love.keyreleased = wrapper_keyreleased
	love.mousepressed = wrapper_mousepressed
	love.mousereleased = wrapper_mousereleased
	love.joystickpressed = wrapper_joystickpressed
	love.joystickreleased = wrapper_joystickreleased
	cock.controlpressed = wrapper_controlpressed
	cock.controlreleased = wrapper_controlreleased
	cock.controlpeaked = wrapper_controlpeaked
	cock.controlzeroed = wrapper_controlzeroed
	cock.controlchanged = wrapper_controlchanged
end

--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--
--==                               BASICS                                  ==--
--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--

-- Create new controls table and optionally fill it with defined control map.
-- NO COLON NOTATION
function cock.new ( id, data )
	if not id or cock._objects[ id ] then repeat id = tostring ( mrand ( 100000 ) ) until not cock._objects[ id ] end -- pick new unique ID
	local new = {
		["current"] = { }, ["previous"] = { }, ["layout"] = { }, ["defaults"] = { }, ["joysticks"] = { }, ["defaultOption"] = "default", ["defaultLayout"] = "default", 
		["etc"] = { ["id"] = id, ["mouse"] = { ["x"] = 0, ["y"] = 0, ["fx"] = 1, ["fy"] = 1, ["_x"] = 0, ["_y"] = 0 }, ["_callbacks"] = { ["any"] = false, ["controlpressed"] = false, ["controlreleased"] = false, ["controlpeaked"] = false, ["controlzeroed"] = false, ["controlchanged"] = false } }
	}
	setmetatable ( new, { ["__index"] = cock } )
	if data then new:setControls ( data ) end
	cock._objects[ id ] = new
	return new
end

-- Return object with given ID.
-- NO COLON NOTATION
function cock.find ( target )
	return cock._objects[ target ]
end

-- Delete (un-track) controls table.
function cock.delete ( self )
	if type ( self ) == "table" then self = self.etc.id end
	cock._objects[ self ] = nil
end

-- Fill the controls table with control map; will overwrite currently defined map, but will not erase what's not overlapped.
-- { default1 = { forward = { option1 = { dev, key, inv, dlt }, option2 = { }, etc. }, backwards = { }, etc. }, default2 = { }, etc. }
function cock.setControls ( self, data )
	for defKey, defVal in pairs ( data ) do
		if not self.defaults[ defKey ] then self.defaults[ defKey ] = { } end
		for mapKey, mapVal in pairs ( defVal ) do
			if not self.current[ mapKey ] then
				self.current[ mapKey ] = 0.0
				self.previous[ mapKey ] = 0.0
			end
			for optKey, optVal in pairs ( mapVal ) do
				if not self.defaults[ defKey ][ optKey ] then self.defaults[ defKey ][ optKey ] = { map = { }, invmap = { }, dev = { }, key = { }, inv = { }, dlt = { }, _did = { }, _raw = { } } end
				local dev, key, inv, dlt = optVal[ 1 ], optVal[ 2 ], optVal[ 3 ] or 2, optVal[ 4 ] or 0
				
				-- convert literal names to digital names
				if type ( dev ) == "string" then local d = _lookup_devices[ dev ]; if not d then d = tonumber ( dev:sub ( 14 ) ) + 5; _lookup_devices[ dev ] = d; _lookup_devices[ d ] = dev end dev = d end
				if ( dev == 3 or dev == 5 ) and type ( key ) == "string" then local a = _lookup_axis [ key ]; if not a then a = tonumber ( key ); _lookup_axis[ key ] = a; _lookup_axis[ a ] = key end key = a end
				if type ( inv ) == "string" then inv = _lookup_modes[ inv ] end
				if type ( dlt ) == "string" then dlt = _lookup_modes[ dlt ] end
				
				table_insert ( self.defaults[ defKey ][ optKey ].dev, dev )
				table_insert ( self.defaults[ defKey ][ optKey ].key, key )
				table_insert ( self.defaults[ defKey ][ optKey ].inv, inv )
				table_insert ( self.defaults[ defKey ][ optKey ].dlt, dlt )
				table_insert ( self.defaults[ defKey ][ optKey ]._did, 1 )
				table_insert ( self.defaults[ defKey ][ optKey ]._raw, 0.0 )
				table_insert ( self.defaults[ defKey ][ optKey ].map, mapKey )
				self.defaults[ defKey ][ optKey ].invmap[ mapKey ] = #self.defaults[ defKey ][ optKey ].map
			end
		end
	end
end

-- Set controls layout to specified default layout.
function cock.setDefault ( self, default )
	if not default then default = self.defaultLayout end
	self.layout = self.defaults[ default ]
end

-- Set controls layout to XBox360 controller layout.
function cock.setDefaultXBox360 ( self, override, d )
	if love._os ~= "Windows" then return 0 end -- Sorry, no eeks-bawkz for Linux and Mac
	
	if not override then override = "XBox360" end
	if not self.layout[ override ] then self.layout[ override ] = { } end
	if not d then d = 1 end
	if not self.joysticks[ d ] then d = self:addJoystick ( 1 ) end
	
	self.current = { ["A"] = 0.0, ["B"] = 0.0, ["X"] = 0.0, ["Y"] = 0.0, ["LB"] = 0.0, ["RB"] = 0.0, ["back"] = 0.0, ["start"] = 0.0, ["xbox"] = 0.0, ["LS"] = 0.0, ["RS"] = 0.0, ["lx"] = 0.0, ["ly"] = 0.0, ["lt"] = 0.0, ["rt"] = 0.0, ["rx"] = 0.0, ["ry"] = 0.0, ["du"] = 0.0, ["dd"] = 0.0, ["dl"] = 0.0, ["dr"] = 0.0, ["dlu"] = 0.0, ["dru"] = 0.0, ["dld"] = 0.0, ["drd"] = 0.0 }
	self.previous ={ ["A"] = 0.0, ["B"] = 0.0, ["X"] = 0.0, ["Y"] = 0.0, ["LB"] = 0.0, ["RB"] = 0.0, ["back"] = 0.0, ["start"] = 0.0, ["xbox"] = 0.0, ["LS"] = 0.0, ["RS"] = 0.0, ["lx"] = 0.0, ["ly"] = 0.0, ["lt"] = 0.0, ["rt"] = 0.0, ["rx"] = 0.0, ["ry"] = 0.0, ["du"] = 0.0, ["dd"] = 0.0, ["dl"] = 0.0, ["dr"] = 0.0, ["dlu"] = 0.0, ["dru"] = 0.0, ["dld"] = 0.0, ["drd"] = 0.0 }
	
	self.layout[ override ].invmap = { ["A"] = 1, ["B"] = 2, ["X"] = 3, ["Y"] = 4, ["LB"] = 5, ["RB"] = 6, ["back"] = 7, ["start"] = 8, ["xbox"] = 9, ["LS"] = 10, ["RS"] = 11, ["lx"] = 12, ["ly"] = 13, ["lt"] = 14, ["rt"] = 15, ["rx"] = 16, ["ry"] = 17, ["du"] = 18, ["dd"] = 19, ["dl"] = 20, ["dr"] = 21, ["dlu"] = 22, ["dru"] = 23, ["dld"] = 24, ["drd"] = 25 }
	self.layout[ override ].map = { "A", "B", "X", "Y", "LB", "RB", "back", "start", "xbox", "LS", "RS", "lx", "ly", "lt", "rt", "rx", "ry", "du", "dd", "dl", "dr", "dlu", "dru", "dld", "drd" }
	self.layout[ override ].dev = { 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6 }
	self.layout[ override ].dlt = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	self.layout[ override ].inv = { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 3, 3, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2 }
	self.layout[ override ]._did = { d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d }
	self.layout[ override ]._raw = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }
	
	if love._os == "Windows" then
		self.layout[ override ].key = { 1, 2, 3, 4, 5, 6, 7, 8, 12, 9, 10, 1, 2, 3, 3, 5, 4, "u", "d", "l", "r", "lu", "ru", "ld", "rd" } -- works
		self.layout[ override ].inv[ 14 ] = 2
		self.layout[ override ].inv[ 15 ] = -2
	elseif love._os == "OS X" then
		self.layout[ override ].key = { 12, 13, 14, 15, 9, 10, 5, 6, 11, 7, 8, 1, 2, 5, 6, 3, 4, "u", "d", "l", "r", "lu", "ru", "ld", "rd" } -- ??
		self.joysticks[ d ]._hatremaps[ 1 ] = { "c", 1, 2, 3, 4; ["hatmode"] = 1 }
	else -- Linux and Unknown
		self.layout[ override ].key = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 1, 2, 6, 5, 3, 4, "u", "d", "l", "r", "lu", "ru", "ld", "rd" } -- ??
		self.joysticks[ d ]._hatremaps[ 1 ] = { "c", 14, 15, 12, 13; ["hatmode"] = 1 }
	end
	return d
end

-- Add controls option.
function cock.addOption ( self, option )
	if not option then repeat option = tostring ( mrand ( 100000 ) ) until not self.layout[ option ] end
	self.layout[ option ] = { map = { }, invmap = { }, dev = { }, key = { }, inv = { }, dlt = { }, _did = { }, _raw = { } }
	return option
end

-- Delete controls option (will erase all binds).
function cock.deleteOption ( self, option )
	self.layout[ option ] = nil
end

-- Find next non-occupied option for given map.
function cock.getEmptyOption ( self, map )
	for k, v in pairs ( self.layout ) do
		if not v.invmap[ map ] then return k end
	end
	return nil
end

-- Bind map.
-- func ( ... ) - bind specified data ( defaults: inv = 2, dlt = 0, val = 1, did = 1 )
-- func ( longarg ) - bind by data from longarg string
function cock.bind ( self, map, option, dev, key, inv, dlt, val, did )
	if not option then 
		local t1, t2, t3, t4, t5, t6, t7 = cock.explodeCapturedData ( map )
		if t7 then
			map = t1
			option = t2
			dev = t3
			key = t4
			inv = t5
			val = t6
			did = t7
		else
			option = self.defaultOption
		end
	end

	if type ( dev ) == "string" then local d = _lookup_devices[ dev ]; if not d then d = tonumber ( dev:sub ( 14 ) ) + 5; _lookup_devices[ dev ] = d; _lookup_devices[ d ] = dev end dev = d end
	if ( dev == 3 or dev == 5 ) and type ( key ) == "string" then local a = _lookup_axis [ key ]; if not a then a = tonumber ( key ); _lookup_axis[ key ] = a; _lookup_axis[ a ] = key end key = a end
	if type ( inv ) == "string" then inv = _lookup_modes[ inv ] end
	if type ( dlt ) == "string" then dlt = _lookup_modes[ dlt ] end
	if type ( did ) == "string" then did = self.joysticks[ did ] end
	
	if not val then val = 0.0 end
	
	self.current[ map ] = val
	self.previous[ map ] = val

	local slo = self.layout[ option ]
	if not slo.invmap[ map ] then
		table_insert ( slo.map, map )
		slo.invmap[ map ] = #slo.map
	end
	
	map = slo.invmap[ map ]
	slo.dev[ map ] = dev
	slo.key[ map ] = key 
	slo.inv[ map ] = inv or 2
	slo.dlt[ map ] = dlt or 0
	slo._did[ map ] = did or 1
	slo._raw[ map ] = val
end

-- Delete input key and device from layout for specified map.
function cock.unbind ( self, map, option )
	if not option then option = self.defaultOption end
	local slo = self.layout[ option ]
	local invmap = slo.invmap[ map ]
	self.current[ map ] = 0.0
	self.previous[ map ] = 0.0
	
	if not invmap then return end
	slo.invmap[ map ] = nil
	table_remove ( slo.map, invmap )
	table_remove ( slo.key, invmap )
	table_remove ( slo.dev, invmap )
	table_remove ( slo.inv, invmap )
	table_remove ( slo.dlt, invmap )
	table_remove ( slo._did, invmap )
	table_remove ( slo._raw, invmap )
	
	slo = slo.invmap
	for k, v in pairs ( slo ) do -- adjust invmap for shifted values
		if v > invmap then slo[ k ] = v - 1 end
	end
end

--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--
--==                                 MOUSE                                 ==--
--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--

-- Set mouse offset.
function cock.setMouseOffset ( self, x, y )
	self.etc.mouse.x = x or self.etc.mouse.x
	self.etc.mouse.y = y or self.etc.mouse.y
end

-- Get mouse offset.
function cock.getMouseOffset ( self )
	return self.etc.mouse.x, self.etc.mouse.y
end

-- Set mouse multiplication factor.
function cock.setMouseFactor ( self, x, y )
	self.etc.mouse.fx = x or self.etc.mouse.fx
	self.etc.mouse.fy = y or self.etc.mouse.fy 
end

-- Get mouse multiplication factor.
function cock.getMouseFactor ( self )
	return self.etc.mouse.fx, self.etc.mouse.fy
end

--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--
--==                               JOYSTICK                                ==--
--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--

function cock.addJoystick ( self, number )
	if not number then number = 1 end
	local isdummy = lj_getNumJoysticks ( ) < number and true or false
	local joyname = isdummy and "None" or ( lj_getName ( number ) .. " (" .. number .. ")" )
	local joynum = #self.joysticks + 1
	
	if isdummy then number = 0 end
	
	self.joysticks[ joyname ] = joynum
	self.joysticks[ joynum ] = { ["name"] = joyname, ["number"] = number, ["_deadzones"] = { ["thr"] = { }, ["amp"] = { } }, ["_hatremaps"] = { } }
	if not isdummy then -- dummy joysticks don't have hats
		local hatremaps = self.joysticks[ joynum ]._hatremaps
		for i = 1, lj_getNumHats ( number ) do
			hatremaps[ i ] = { "c", false, 0, 0, 0; ["hatmode"] = 1 } -- set up joystick hats
		end
	else
		self.joysticks[ joynum ].dummy = true 
	end
	
	return joynum
end

-- Delete joystick.
-- func ( self, number ) : delete by self's joystick number
-- func ( self, string ) : delete by name
function cock.deleteJoystick ( self, number )
	local name
	if type ( number ) == "string" then
		name = number
		number = self.joysticks[ number ] 
	else 
		name = self.joysticks[ number ].name 
	end
	
	table_remove ( self.joysticks, number )
	self.joysticks[ name ] = nil
end

-- Set joystick hat mode by either number or literal value.
function cock.setJoystickHatMode ( self, joystick, hat, hatmode )
	if not joystick then joystick = 1 elseif type ( joystick ) == "string" then joystick = self.joysticks[ joystick ] end
	if self.joysticks[ joystick ].dummy then return end -- do not service dummies
	if not hat then hat = 1 elseif type ( hat ) == "string" then local d = _lookup_devices[ hat ]; if not d then d = tonumber ( hat:sub ( 14 ) ); _lookup_devices[ d + 5 ] = hat; _lookup_devices[ hat ] = d + 5 end hat = d end
	if not hatmode then hatmode = 1 elseif type ( hatmode ) == "string" then hatmode = _lookup_hatmodes[ hatmode ] end

	self.joysticks[ joystick ]._hatremaps[ hat ].hatmode = hatmode
end

-- Get literal joystick hat mode.
function cock.getJoystickHatMode ( self, joystick, hat )
	if not joystick then joystick = 1 elseif type ( joystick ) == "string" then joystick = self.joysticks[ joystick ] end
	if self.joysticks[ joystick ].dummy then return 1 end -- do not service dummies
	if not hat then hat = 1 elseif type ( hat ) == "string" then local d = _lookup_devices[ hat ]; if not d then d = tonumber ( hat:sub ( 14 ) ); _lookup_devices[ d + 5 ] = hat; _lookup_devices[ hat ] = d + 5 end hat = d end
	
	return _lookup_hatmodes[ self.joysticks[ joystick ]._hatremaps[ hat ].hatmode ]
end

-- Set joystick deadzone.
-- func ( self, joy, true, thr ) : sets deadzone to all axis
function cock.setJoystickDeadzone ( self, joystick, axis, threshold )
	if not joystick then joystick = 1 elseif type ( joystick ) == "string" then joystick = self.joysticks[ joystick ] end
	if self.joysticks[ joystick ].dummy then return end -- do not service dummies
	
	if joystick and self.joysticks[ joystick ] then
		if axis == true then 
			axis = 1 / ( 1 - threshold ) -- just reused a variable, that ain't crime
			for i = 1, lj_getNumAxes ( joystick ) do --love.joystick.getAxisCount since 0.9.0
				self.joysticks[ joystick ]._deadzones.thr[ i ] = threshold
				self.joysticks[ joystick ]._deadzones.amp[ i ] = axis
			end
		else
			if type ( axis ) == "string" then local a = _lookup_axis[ axis ]; if not a then a = tonumber ( axis ); _lookup_axis[ axis ] = a; _lookup_axis[ a ] = axis end axis = a end
			self.joysticks[ joystick ]._deadzones.thr[ axis ] = threshold 
			self.joysticks[ joystick ]._deadzones.amp[ axis ] = 1 / ( 1 - threshold )
		end
	end
end

-- Get joystick deadzone.
function cock.getJoystickDeadzone ( self, joystick, axis )
	if not joystick then joystick = 1 elseif type ( joystick ) == "string" then joystick = self.joysticks[ joystick ] end
	if self.joysticks[ joystick ].dummy then return 0.0 end -- do not service dummies
	if not axis then axis = 1 elseif type ( axis ) == "string" then local a = _lookup_axis [ key ]; if not a then a = tonumber ( key ); _lookup_axis[ key ] = a; _lookup_axis[ a ] = key end key = a end
	
	return joystick and self.joysticks[ joystick ] and self.joysticks[ joystick ]._deadzones.thr[ axis ]
end

-- Map (exactly) 4 joystick buttons to act like joystick hat. 
function cock.remapJoystickHat ( self, joystick, hat, u, d, l, r )
	if not joystick then joystick = 1 elseif type ( joystick ) == "string" then joystick = self.joysticks[ joystick ] end
	if self.joysticks[ joystick ].dummy then return end -- do not service dummies
	if not hat then hat = 1 elseif type ( hat ) == "string" then local d = _lookup_devices[ hat ]; if not d then d = tonumber ( hat:sub ( 14 ) ); _lookup_devices[ d + 5 ] = hat; _lookup_devices[ hat ] = d + 5 end hat = d end
	
	if joystick and self.joysticks[ joystick ] then
		local remaps = self.joysticks[ joystick ]._hatremaps[ hat ]
		if not remaps then -- one may add virtual hat
			self.joysticks[ joystick ]._hatremaps[ hat ] = { "c", false, 0, 0, 0; ["hatmode"] = 1 } 
			remaps = self.joysticks[ joystick ]._hatremaps[ hat ]
		end
		if not u and not d and not l and not r then 
			remaps[ 2 ] = false
			remaps[ 3 ] = 0
			remaps[ 4 ] = 0
			remaps[ 5 ] = 0
			return
		end
		remaps[ 2 ] = u or remaps[ 2 ]
		remaps[ 3 ] = d or remaps[ 3 ]
		remaps[ 4 ] = l or remaps[ 4 ]
		remaps[ 5 ] = r or remaps[ 5 ] 
	end
end

-- Resolve joystick un- and re-plugging.
function cock.reloadJoysticks ( self ) 
	local taken = { }
	-- love.joystick.reload ( ) since 0.9.0
	for i = 1, #self.joysticks do
		local joy = self.joysticks[ i ]
		local name
		if joy.dummy then name = "" 
		elseif joy.fallback then name = joy.fallback.name else name = joy.name end -- use fallback name if any (try to find originally used joystick)
		name = name:gsub ( "%s%(%d+%)$", "" ) -- remove trailing joystick number from the name

		joy.number = 0
		for j = 1, lj_getNumJoysticks ( ) do  -- love.joystick.getJoystickCount since 0.9.0
			if not taken[ j ] then -- multiple same joysticks, like multiple XBox360 controllers - ignore what's taken
				if lj_getName ( j ) == name then
					if joy.fallback then -- restore backed up data
						self.joysticks[ i ] = joy.fallback 
						joy = self.joysticks[ i ] 
					end
					joy.number = j
					joy.name = name .. " (" .. j .. ")"
					taken[ j ] = true
					break 
				end
			end
		end
-- auto fallback only works if there was only one joystick, two or more will inevitably get fucked up; if it can't be done then just keep the unused joystick field
		if joy.number == 0 and #self.joysticks == 1 and lj_getNumJoysticks ( ) > 0 then 
			local fallback = joy.fallback or joy
			self:deleteJoystick ( 1 )
			joy = self.joysticks[ self:addJoystick ( 1 ) ]
			if not joy.dummy then joy.fallback = fallback end -- do not keep a record for dummy joysticks
		end
	end
end
--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--
--==                               HANDLING                                ==--
--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--

-- Set callbacks field.
function cock.setCallbacks ( self, pressed, released, peaked, zeroed, changed )
	self = self.etc._callbacks
	if type ( pressed ) == "string" and type ( released ) == "boolean" then
		self[ pressed ] = released
		self.any = true
		return
	end
	self.controlpressed = pressed or self.controlpressed
	self.controlreleased = released or self.controlreleased
	self.controlpeaked = peaked or self.controlpeaked
	self.controlzeroed = zeroed or self.controlzeroed
	self.controlchanged = changed or self.controlchanged
	
	self.any = ( self.controlpressed or self.controlreleased or self.controlpeaked or self.controlzeroed or self.controlchanged ) and true or false
end

-- Enable "input capture" mode.
function cock.setCapture ( self, map, option, eventlock, updatelock, nomouse, callback )
	wrapperSetup ( )
	if nomouse then
		cock._capture.mouse = false
	else
		cock._capture.mouse = true
		self.etc.mouse._x = lm_getX ( )
		self.etc.mouse._y = lm_getY ( )
		lm_setPosition ( lg_getWidth ( ) / 2, lg_getHeight ( ) / 2 ) 
		le_pump ( ) -- kludge for odd behavior with failed mouse repositioning 
	end
	cock._capture.object = self
	cock._capture.map = map
	cock._capture.option = option or self.defaultOption
	cock._capture.eventlock = eventlock and true or false
	cock._capture.updatelock = updatelock and true or false
	cock._capture.callback = ( callback == nil ) and true or callback
end

-- Return capture state.
-- No COLON NOTATION
function cock.getCapture ( )
	return cock._capture.object
end

-- Cancel the capture mode and restore all temporary values back.
-- NO COLON NOTATION
function cock.cancelCapture ( )
	wrapperRestore ( )
	if cock._capture.mouse then lm_setPosition ( cock._capture.object.etc.mouse._x, cock._capture.object.etc.mouse._y ) end
	cock._capture.object = false
end

-- Update all registered control objects.
-- NO COLON NOTATION
function cock.updateAll ( )
	for k, v in pairs ( cock._objects ) do
		v:update ( )
	end
end

-- Update all control states. 
function cock.update ( self )
	local curr, prev, etc, vcurr = self.current, self.previous, self.etc, 0
	
	for i = 1, #self.joysticks do -- update hats positions
		local jnum, jhrem = self.joysticks[ i ].number, self.joysticks[ i ]._hatremaps
		for j = 1, #jhrem do -- go through every hat
			local jh = jhrem[ j ]
			if jh[ 2 ] then -- remapped hat is computed via bitfield
				jh[ 1 ] = _hatbitfield[ ( lj_isDown ( jnum, jh[ 2 ] ) and 2 or 1 ) + ( lj_isDown ( jnum, jh[ 3 ] ) and 2 or 0 ) + ( lj_isDown ( jnum, jh[ 4 ] ) and 4 or 0 ) + ( lj_isDown ( jnum, jh[ 5 ] ) and 8 or 0 ) ]
			else
				jh[ 1 ] = lj_getHat ( jnum, j )
			end
		end
	end
	
	for k, v in pairs ( curr ) do 
		curr[ k ] = 0.0
	end
	
	for optKey, optVal in pairs ( self.layout ) do -- go through all options
		local map, dev, key, inv, dlt, _did, _raw = optVal.map, optVal.dev, optVal.key, optVal.inv, optVal.dlt, optVal._did, optVal._raw
		for i = 1, #map do -- go through every binded map
			local lm, ld, lk, li, la, _ld, _rc, _rp = map[ i ], dev[ i ], key[ i ], inv[ i ], dlt[ i ], _did[ i ], 0, _raw[ i ]
			
			if li < 0 then -- negative
				if ld == 1 then -- keyboard
					_rc = lk_isDown ( lk ) and 0.0 or 1.0
				elseif ld == 2 then -- mouse button
					_rc = lm_isDown ( lk ) and 0.0 or 1.0
				elseif ld == 3 then -- mouse axis
					if lk == 1 then
						_rc = ( etc.mouse.x - lm_getX ( ) ) * etc.mouse.fx
					elseif lk == 2 then
						_rc = ( etc.mouse.y - lm_getY ( ) ) * etc.mouse.fy
					end
				elseif ld > 3 then -- joystick
					local joy = self.joysticks[ _ld ]
					if joy and joy.number > 0 then
						if ld == 4 then -- joystick button
							_rc = lj_isDown ( joy.number, lk ) and 0.0 or 1.0
						elseif ld == 5 then -- joystick axis
							local axs = -lj_getAxis ( joy.number, lk )
							if li == -3 then axs = ( axs + 1.0 ) / 2 end -- whole axis mode
							if la == 0 and joy._deadzones.thr[ lk ] then
								if axs > 0 then axs = mmax ( 0.0, ( axs - joy._deadzones.thr[ lk ] ) * joy._deadzones.amp[ lk ] ) else axs = mmin ( 0.0, ( axs + joy._deadzones.thr[ lk ] ) * joy._deadzones.amp[ lk ] ) end
							end
							_rc = axs
						elseif ld > 5 then -- joystick POV hat
							ld = ld - 5
							_rc = _hataliases[ joy._hatremaps[ ld ].hatmode ][ joy._hatremaps[ ld ][ 1 ] ][ lk ] and 0.0 or 1.0 -- _hatmodes[ mode ][ what we got ][ what we need ]
						end
					end
				end
			else
				if ld == 1 then -- keyboard
					_rc = lk_isDown ( lk ) and 1.0 or 0.0
				elseif ld == 2 then -- mouse button
					_rc = lm_isDown ( lk ) and 1.0 or 0.0
				elseif ld == 3 then -- mouse axis
					if lk == 1 then
						_rc = ( lm_getX ( ) - etc.mouse.x ) * etc.mouse.fx
					elseif lk == 2 then
						_rc = ( lm_getY ( ) - etc.mouse.y ) * etc.mouse.fy
					end
				elseif ld > 3 then -- joystick
					local joy = self.joysticks[ _ld ]
					if joy and joy.number > 0 then
						if ld == 4 then -- joystick button
							_rc = lj_isDown ( joy.number, lk ) and 1.0 or 0.0
						elseif ld == 5 then -- joystick axis
							local axs = lj_getAxis ( joy.number, lk )
							if li == 3 then axs = ( axs + 1.0 ) / 2 end -- whole axis mode
							if la == 0 and joy._deadzones.thr[ lk ] then
								if axs > 0 then axs = mmax ( 0.0, ( axs - joy._deadzones.thr[ lk ] ) * joy._deadzones.amp[ lk ] ) else axs = mmin ( 0.0, ( axs + joy._deadzones.thr[ lk ] ) * joy._deadzones.amp[ lk ] ) end
							end
							_rc = axs
						elseif ld > 5 then -- joystick POV hat
							ld = ld - 5
							_rc = _hataliases[ joy._hatremaps[ ld ].hatmode ][ joy._hatremaps[ ld ][ 1 ] ][ lk ] and 1.0 or 0.0 -- _hatmodes[ mode ][ what we got ][ what we need ]
						end
					end
				end
			end
			
			if la == 0 then
				if li == 2 or li == -2 then vcurr = mmax ( _rc, 0.0 ) else vcurr = _rc end -- ( inverse cutoff )
			else
				if ( la == 1 ) or ( la == 2 and _rc > _rp ) then -- ( delta cutoff )
					vcurr = _rc - _rp
				elseif ( la == -1 ) or ( la == -2 and _rc < _rp ) then
					vcurr = _rp - _rc
				else
					vcurr = 0.0
				end	
				_raw[ i ] = _rc
			end
			if ( curr[ lm ] > 0 ) ~= ( vcurr > 0 ) then -- different signs, cancel each other out
				if vcurr > 0 then curr[ lm ] = curr[ lm ] + vcurr else curr[ lm ] = curr[ lm ] - vcurr end
			else -- select biggest value
				if vcurr > 0 then curr[ lm ] = mmax ( curr[ lm ], vcurr ) else curr[ lm ] = mmin ( curr[ lm ], vcurr ) end
			end
		end
	end
	
	vcurr = self.etc._callbacks
	if vcurr.any then
		for k, v in pairs ( curr ) do -- push events
			if vcurr.controlpressed and ( ( v > 0.5 and prev[ k ] <= 0.5 ) or ( v < -0.5 and prev[ k ] >= -0.5 ) ) then
				le_push ( "controlpressed", self.etc.id, k, v )
			elseif vcurr.controlreleased and ( ( v <= 0.5 and prev[ k ] > 0.5 ) or ( v > -0.5 and prev[ k ] <= -0.5 ) )  then
				le_push ( "controlreleased", self.etc.id, k, v )
			end
			if vcurr.controlpeaked and ( ( v >= 1.0 and v > prev[ k ] ) or ( v <= -1.0 and v < prev[ k ] ) ) then
				le_push ( "controlpeaked", self.etc.id, k, v )
			elseif vcurr.controlzeroed and v == 0.0 and v ~= prev[ k ] then
				le_push ( "controlzeroed", self.etc.id, k, v )
			end
			if vcurr.controlchanged and v ~= prev[ k ] then
				le_push ( "controlchanged", self.etc.id, k, v )
			end
			prev[ k ] = v
		end
	end
end

-- Grab the input device and key. Returns false if nothing was grabbed.
function cock.grab ( self, map, option, dev, key, inv, val, did )
	if not map then map = cock._capture.map end
	if not option then option = cock._capture.option end
	
	if type ( dev ) == "string" then local d = _lookup_devices[ dev ]; if not d then d = tonumber ( dev:sub ( 14 ) ) + 5; _lookup_devices[ dev ] = d; _lookup_devices[ d ] = dev else dev = d end end
	if ( dev == 3 or dev == 5 ) and type ( key ) == "string" then local a = _lookup_axis [ key ]; if not a then a = tonumber ( key ); _lookup_axis[ key ] = a; _lookup_axis[ a ] = key end end
	if type ( inv ) == "string" then inv = _lookup_modes[ inv ] end
	if type ( did ) == "string" then did = self.joysticks[ did ] end
	
	if dev == 4 and key and did then -- possibly remapped joystick hat
		local n = self.joysticks[ did ].number
		for i, v in pairs ( self.joysticks[ did ]._hatremaps ) do
			if v[ 2 ] == key or v[ 3 ] == key or v[ 4 ] == key or v[ 5 ] == key then
				local k = _hataliases[ v.hatmode ][ _hatbitfield[ ( lj_isDown ( n, v[ 2 ] ) and 2 or 1 ) + ( lj_isDown ( n, v[ 3 ] ) and 2 or 0 ) + ( lj_isDown ( n, v[ 4 ] ) and 4 or 0 ) + ( lj_isDown ( n, v[ 5 ] ) and 8 or 0 ) ] ][ 1 ]
				if k then -- just because related key is pressed does not guarantees that there's meaningful hat input
					key = k
					dev = i + 5
					break
				end
			end
		end
	end
	
	if not key then
		if cock._capture.mouse and ( not dev or dev == 3 ) then -- capture mouse
			local mdx, mdy = lm_getX ( ) - lg_getWidth ( ) / 2, lm_getY ( ) - lg_getHeight ( ) / 2
			if mabs ( mdx ) > 50 and mabs ( mdx ) > mabs ( mdy ) then
				if not dev then dev = 3 end
				key = 1
				val = mabs ( mdx )
				inv = mdx > 0 and 1 or -1
				dev = 3
			elseif mabs ( mdy ) > 50 and mabs ( mdy ) > mabs ( mdx ) then
				if not dev then dev = 3 end
				key = 2
				val = mabs ( mdy )
				inv = mdy > 0 and 1 or -1
				dev = 3
			end
		end
		if not dev or dev == 5 then -- capture joystick axis
			for i = 1, lj_getNumJoysticks ( ) do -- love.joystick.getJoystickCount ( i ) since 0.9.0
				for j = 1, lj_getNumAxes ( i ) do -- love.joystick.getAxisCount ( num ) since 0.9.0
					local a = lj_getAxis ( i, j )
					if mabs ( a ) > 0.5 then
						local k = 0
						key = j
						val = mabs ( a )
						inv = a > 0.0 and 1 or -1
						dev = 5
						
						for z = 1, #self.joysticks do
							if self.joysticks[ z ].number == i then did = i; break end
						end
						if not did then
							did = self:addJoystick ( i )
						end
						break
					end
				end
			end
		end
		if not dev or dev > 5 then -- capture joystick hat (tricky)
			if not dev then
				for i = 1, lj_getNumJoysticks ( ) do -- love.joystick.getJoystickCount ( ) since 0.9.0
					local dd = did
					if not dd then
						for z = 1, #self.joysticks do -- find joystick (if not specified)
							if self.joysticks[ z ].number == i then dd = i; break end
						end
					end
					
					if dd then -- joystick exists
						for k, v in pairs ( self.joysticks[ dd ]._hatremaps ) do
							if v[ 2 ] == false then -- ignore remapped hats, they're resolved elsewhere
								key = _hataliases[ v.hatmode ][ lj_getHat ( i, k ) ][ 1 ] -- this table conveniently contains "nil" value for "c" key
								if key then
									dev = k + 5
									did = dd
									break
								end
							end
						end
					else -- joystick does not exists
						for j = 1, lj_getNumHats ( i ) do -- love.joystick.getHatCount ( i ) since 0.9.0
							key = _hataliases[ 1 ][ lj_getHat ( i, j ) ][ 1 ] -- default to 8-way
							if key then 
								dev = j + 5
								did = self:addJoystick ( i ) -- automatically add unregistered joystick
								break
							end
						end
					end
					if key then break end
				end
			else -- device is specified
				dev = dev - 5
				if did then -- joystick is specified 
					local j = self.joysticks[ did ]
					if j._hatremaps[ dev ][ 2 ] == false then -- ignore remapped hats
						key = _hatremaps[ j._hatremaps[ dev ].hatmode ][ lj_getHat ( j.number, dev ) ][ 1 ]
					end
				else
					for i = 1, #self.joysticks do -- device but no joystick specified, perform traversal
						local v = self.joysticks[ i ]._hatremaps[ dev ]
						if v[ 2 ] == false then -- ignore remapped hats
							key = _hatremaps[ v.hatmode ][ lj_getHat ( self.joysticks[ i ].number, dev ) ][ 1 ]
							if key then 
								did = i 
								break 
							end
						end
					end
				end
				dev = dev + 5
			end	
		end
		if not key then return end
	end
	
	if not val then val = 1.0 end
	if not inv then inv = 2 end
	if not did then did = 1 end
	
	if dev > 3 and self.joysticks[ did ].fallback then -- this joystick had backup but now actually used - remove backup data
		self.joysticks[ did ].fallback = nil
	end
	
	self:cancelCapture ( )
	if cock._capture.callback then
		le_push ( "controlcaptured", self.etc.id, map .. " " .. option .. " " .. dev ..  " " .. ( key == " " and "space" or key ) .. " " .. inv .. " " .. val .. " " .. did )
	else
		self:bind ( map, option, dev, key, inv, nil, val )
	end
end

--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--
--==                               HELPERS                                 ==--
--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--

-- Get literal name of assigned device.
-- func ( self, map, true ) : return all bingings for map
function cock.getBinded ( self, map, option )
	if not option then option = self.defaultOption
	elseif option == true then
		local l = { option = { }, device = { }, key = { }, inverse = { }, delta = { }, joystick = { } }
		for k, v in pairs ( self.layout ) do
			local c = v.invmap[ map ]
			if c then
				table_insert ( l.option, k )
				table_insert ( l.device, v.dev[ c ] )
				table_insert ( l.key, v.key[ c ] )
				table_insert ( l.inverse, v.inv[ c ] )
				table_insert ( l.delta, v.dlt[ c ] )
				table_insert ( l.joystick, v._did[ c ] )
			end
		end
		return l
	end
	local v = self.layout[ option ]
	local c = v.invmap[ map ]
	if not c then return nil, nil, nil, nil, nil end
	return v.dev[ c ], v.key[ c ], v.inv[ c ], v.dlt[ c ], v._did[ c ]
end

-- Helper function for controlcaptured callback.
-- NO COLON NOTATION
function cock.explodeCapturedData ( data )
	local d = { }
	for w in string.gmatch ( data, "%S+" ) do table_insert ( d, w ) end
	return d[ 1 ], d[ 2 ], tonumber ( d[ 3 ] ), ( tonumber ( d[ 3 ] ) == 3 or tonumber ( d[ 3 ] ) > 5 ) and tonumber ( d[ 4 ] ) or ( d[ 4 ] == "space" and " " or d[ 4 ] ), tonumber ( d[ 5 ] ), tonumber ( d[ 6 ] ), tonumber ( d[ 7 ] )
end

-- Find all joysticks and returns list of their names under indices corresponding to joystick number.
-- NO COLON NOTATION
function cock.getJoysticksList ( )
	local list = { }
	-- love.joystick.getJoystickCount since 0.9.0
	for i = 1, lj_getNumJoysticks ( ) do
		if not lj_isOpen ( i ) then lj_open ( i ) end -- remove since 0.9.0
		list[ i ] = lj_getName ( i ) .. " (" .. i .. ")"
	end
	return list
end

-- Convert literal to digital value of a device.
-- NO COLON NOTATION
function cock.convertDevice ( device, literal )
	if literal == nil or ( ( literal == true ) ~= ( type ( device ) == "string" ) ) then
		local d = _lookup_devices[ device ]
		if not d then
			if type ( device ) == "string" then  d = tonumber ( device:sub ( 14 ) ) + 5 else d = "joystick hat " .. ( device - 5 ) end
			_lookup_devices[ device ] = d
			_lookup_devices[ d ] = device 
		end
		return d
	end
	return device
end

-- Convert literal to digital value of a key
-- NO COLON NOTATION
function cock.convertKey ( device, key, literal )
	if not device then device = 3 
	elseif type ( device ) == "string" then device = _lookup_devices[ device ] end	
	if ( device == 3 or device == 5 ) and ( literal == nil or ( ( literal == true ) ~= ( type ( key ) == "string" ) ) ) then
		local a = _lookup_axis[ key ]
		if not a then 
			if type ( key ) == "string" then a = tonumber ( key ) else a = tostring ( key ) end
			_lookup_axis[ key ] = a
			_lookup_axis[ a ] = key
		end
		return a
	end
	return key
end
	
-- Convert literal to digital value of an axis.
-- NO COLON NOTATION
function cock.convertdAxis ( axis, literal )
	if literal == nil or ( ( literal == true ) ~= ( type ( axis ) == "string" ) ) then
		local a = _lookup_axis[ axis ]
		if not a then 
			if type ( axis ) == "string" then a = tonumber ( axis ) else a = tostring ( axis ) end
			_lookup_axis[ axis ] = a
			_lookup_axis[ a ] = axis
		end
		return a
	end
	return axis
end

-- Convert literal to digital value of inverse.
-- NO COLON NOTATION
function cock.convertInverse ( inverse, literal )
	if literal == nil or ( ( literal == true ) ~= ( type ( inverse ) == "string" ) ) then
		return _lookup_modes[ inverse ]
	end
	return inverse
end

-- Convert literal to digital value of delta (exactly the same as previous, that's right). 
-- NO COLON NOTATION
function cock.convertDelta ( delta, literal )
	if literal == nil or ( ( literal == true ) ~= ( type ( delta ) == "string" ) ) then
		return _lookup_modes[ delta ]
	end
	return delta
end

-- Convert literal to digital value of joystick hat mode.
-- NO COLON NOTATION
function cock.convertJoystickHatMode ( hatmode, literal )
	if literal == nil or ( ( literal == true ) ~= ( type ( hatmode ) == "string" ) ) then
		return _lookup_hatmodes[ hatmode ]
	end
	return hatmode
end

-- Convert literal to digital value of joystick hat number.
-- NO COLON NOTATION
function cock.convertJoystickHat ( hat, literal )
	if literal == nil or ( ( literal == true ) ~= ( type ( hat ) == "string" ) ) then
		if type ( hat ) == "string" then
			local d = _lookup_devices[ hat ]
			if not d then 
				d = tonumber ( hat:sub ( 14 ) )
				_lookup_devices[ d + 5 ] = hat
				_lookup_devices[ hat ] = d + 5 
			end
			return d
		else
			local d = _lookup_devices[ hat + 5 ]
			if not d then 
				d = "joystick hat " .. ( hat )
				_lookup_devices[ hat + 5 ] = d
				_lookup_devices[ d ] = hat + 5 
			end
			return d
		end
	end
	return hat
end

-- Convert literal to digital value of joystick id.
-- func ( self, joystick, literal ) : convert self's joysticks
function cock.convertJoystick ( self, joystick, literal )
	if literal == nil or ( ( literal == true ) ~= ( type ( joystick ) == "string" ) ) then
		if type ( joystick ) == "string" then return self.joysticks[ joystick ].number else return self.joysticks[ joystick ] end
	end
	return joystick
end

-- And this is just to mock faggots who use getters and setters for every single little thing, especially if it's used often. It might get inlined in C and pals, but Lua will always introduce function call overhead. If you really that much of a faggot, delete fail line and uncomment the following one.
function cock.getCurrent ( self, map )
	error ( "use the 'yourcontroltable.current.yourkeyvalue' instead, you moron" )
	--return self.current[ map ]
	-- but seriously, use the "yourcontroltable.current.yourkeyvalue" instead
end

function cock.getPrevious ( self, map )
	error ( "use the 'yourcontroltable.previous.yourkeyvalue' instead, you moron" )
	--return self.previous[ map ]
	-- but seriously, use the "yourcontroltable.previous.yourkeyvalue" instead
end

return cock

--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--
--==                            END OF LIBRARY                             ==--
--== = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ==--

--[[ equality sheet (you can use either numerical value or literal value ): 
	hat modes:
		 1 = '8-way'
		 2 = '4-way vertical'
		 3 = '4-way horizontal'
		 4 = '4-way clockwise'
		 5 = '4-way counter-clockwise'
		 6 = '4-way diagonal'
	devices:
		 1 = 'keyboard'
		 2 = 'mouse button'
		 3 = 'mouse axis'
		 4 = 'joystick button'
		 5 = 'joystick axis'
		 6 = 'joystick hat' ('joystick hat 1')
		 7 = 'joystick hat 2'
		 8 = 'joystick hat 3', etc.
	axis:
		 1 = 'x'
		 2 = 'y'
		 3 = 'z'
		 4 = 'r'
		 5 = 'u'
		 6 = 'v'
		 7 = '7'
		 8 = '8' 
		 9 = '9', etc.
	inverse:
		 1 = '+'
		 2 = '++'
		 3 = '+='
		-1 = '-'
		-2 = '--'
		-3 = '-='
	delta:
		 0 = '='
		 1 = '+'
		 2 = '++'
		-1 = '-'
		-2 = '--'
		
hat:sub ( 1, 12 ) == "joystick hat"
--]]