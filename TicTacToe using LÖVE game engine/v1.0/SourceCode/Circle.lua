--[[
  Author: HimelSaha

]]

Circle = Class{}

function Circle:init(mode, x, y, radius, r, g, b, a)
    self.r = r
    self.g = g
    self.b = b
    self.a = a
    self.mode = mode
    self.x = x
    self.y = y
    self.radius = radius
end

-- this function draws a circle on the canvas
function Circle:render()
    love.graphics.setColor(self.r, self.g, self.b, self.a)  -- red channel, blue channel, green channel, alpha channel(transparency)
    love.graphics.setLineWidth(10)
    love.graphics.circle(self.mode, self.x, self.y, self.radius)
end