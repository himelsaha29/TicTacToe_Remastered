--[[
  Author: HimelSaha

]]


Cross = Class{}

function Cross:init(x, y, size, r, g, b, a)
    self.r = r
    self.g = g
    self.b = b
    self.a = a
    self.x = x
    self.y = y
    self.size = size
end

-- this function draws a cross on the canvas
function Cross:render()
    love.graphics.setColor(self.r, self.g, self.b, self.a)  -- red channel, blue channel, green channel, alpha channel(transparency)
    love.graphics.setLineWidth(10)
    love.graphics.line(self.x, self.y, self.x + self.size, self.y + self.size)
    love.graphics.line(self.x, self.y + self.size, self.x + self.size, self.y)
end