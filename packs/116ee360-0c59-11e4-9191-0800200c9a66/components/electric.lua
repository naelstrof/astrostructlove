local Electric = {
    __name = "Electric",
    wattage = 0,
    input = 0,
    powered = 0
}

function Electric:update( dt )
	if input >= wattage then
		self:powered()
		self.powered = 1
	elseif input < wattage then
		self:unpowered()
		self.powered = 0
	end
end

function Electric:poweredOn()
	return 1
end

function Electric:poweredOff()
	return 1
end

return Electric