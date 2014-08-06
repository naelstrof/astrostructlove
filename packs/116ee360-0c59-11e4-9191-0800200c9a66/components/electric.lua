local Electric = {
    __name = "Electric",
    wattage = 0,
    input = 0,
    powered = 0
}

function Electric:update( dt )
  if input >= wattage then
    if not self.powered then
      self:poweredOn()
      self.powered = true
    end
  elseif input < wattage then
    if self.powered then
      self:poweredOff()
      self.powered = false
    end
  end
end

function Electric:poweredOn()
  return 1
end

function Electric:poweredOff()
  return 1
end

return Electric
