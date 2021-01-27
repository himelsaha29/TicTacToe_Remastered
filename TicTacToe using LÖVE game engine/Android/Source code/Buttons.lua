--[[
  Author: HimelSaha

]]

Buttons = Class{}

function Buttons:init(x, y, r, g, b, w, h, fsize)
    self.x = x
    self.y = y
    self.r = r
    self.g = g
    self.b = b
    self.buttonWidth = w
    self.buttonHeight = h
    self.fontSize = fsize
end

-- this function prints the label on a button
function Buttons:buttonText()

    if self.fontSize == 40 then
        txt = "2 Players"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 30))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 4, self.x, 'center')

    elseif self.fontSize == 45 then
        txt = "2 Players"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 33))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 7, self.x, 'center')

    elseif self.fontSize == 7 then
        txt = "1 Player"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 30))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 5, self.x, 'center')

    elseif self.fontSize == 11 then
        txt = "1 Player"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 33))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 7, self.x, 'center')

    elseif self.fontSize == 14 then
        txt = "Restart"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 14))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 15, self.x, 'center')

    elseif self.fontSize == 15 then
        txt = "Restart"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 15))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 16, self.x, 'center')

    elseif self.fontSize == 50 then
        txt = "TicTacToe"
        love.graphics.setFont(love.graphics.newFont("fonts/AlloyInk.ttf", 64))
        love.graphics.setColor(0, 0, 205 / 255)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 215, self.x, 'center')

    elseif self.fontSize == 30 then
        txt = "Continue"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 14))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 16, self.x, 'center')

    elseif self.fontSize == 35 then
        txt = "Continue"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 15))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 17, self.x, 'center')

    elseif self.fontSize == 1 then
        txt = "Home"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 15))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 15, self.x, 'center')

    elseif self.fontSize == 2 then
        txt = "Home"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 16))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 16, self.x, 'center')

    elseif self.fontSize == 77 then
        txt = "Instructions"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 27))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 3, self.x, 'center')

    elseif self.fontSize == 78 then
        txt = "Instructions"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 24))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 1, self.x, 'center')

    elseif self.fontSize == 87 then
        txt = "Quit"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 33))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 6, self.x, 'center')

    elseif self.fontSize == 88 then
        txt = "Quit"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 30))
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 - 4, self.x, 'center')
    end
end

function Buttons:creator()
    txt = "Created by Himel"
        love.graphics.setFont(love.graphics.newFont("fonts/Maler.ttf", 15))
        love.graphics.setColor(0, 0, 205 / 255)
        love.graphics.printf(string.format("%s",txt), 0, self.y / 2 + 115, self.x, 'center')
end

-- this function draws the rectangle that resembles a button
function Buttons:render()
    love.graphics.setColor(self.r, self.g, self.b)
    love.graphics.rectangle('fill', self.x / 2 - (self.buttonWidth / 2), self.y / 2 - (self.buttonHeight / 2), self.buttonWidth, self.buttonHeight)
end
