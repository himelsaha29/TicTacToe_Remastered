--[[
  Author: HimelSaha

]]

-- associating other required classes

-- push is a library that will allow to draw the game at a virtual
-- resolution, instead of however large the window is.
-- https://github.com/Ulydev/push
push = require 'push'
tick = require 'tick'

-- the "Class" library facilitates representation of anything in
-- the game as code, rather than keeping track of many disparate variables and
-- methods
Class = require 'class'

require 'Layout'        -- draws the grid on gameplay screen
require 'Circle'        -- draws circle on canvas
require 'Cross'         -- draws cross on canvas
require 'Buttons'       -- draws buttons on canvas

WINDOW_WIDTH = 960
WINDOW_HEIGHT = 540

VIRTUAL_WIDTH = 960
VIRTUAL_HEIGHT = 540

layout_column_width = 5
layout_column_height = 382

layout_gap = 70

layout_row_width = 406
layout_row_height = 6

column_y = 80
row_x = 279

title = "Tic\nTac\nToe"
title2 = "R   E   M   A   S   T   E   R   E   D"
titleInside = "REMASTERED"
text = ""
player1Score = 0
player2Score = 0
waitingForInput = false
continuation = ""
continueShown = false
home = true     -- user starts with home screen
player1Selected = false
player2Selected = false
inst = false
serve = ""
randomStart = 0
instruction1 = "Get 3 crosses(X) or noughts(O) in a row to win a game"
instruction2 = "Crosses(X) or noughts(O) need to align horizontally/vertically/diagonally"
instruction3 = "Get to 5 points first to be elected as the\nwinner of the round"


-- mouse position table for start screen
cursorPointsSS = {
            0, 0
}

-- mouse position table for gameplay screen
cursorPointsGS = {
            0, 0
}





function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    tick.framerate = 20

    --[[game = {}
	game.screen_width = VIRTUAL_WIDTH
    game.screen_height = VIRTUAL_HEIGHT
    love.window.setMode(game.screen_width, game.screen_width, {resizable=true}, {vsync=true})]]

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, VIRTUAL_WIDTH, VIRTUAL_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- fonts table
fonts = {
    ['titleFont'] = love.graphics.newFont("fonts/AlloyInk.ttf", 44),
    ['winnerFont'] = love.graphics.newFont("fonts/Maler.ttf", 32),
    ['instFont'] = love.graphics.newFont("fonts/Maler.ttf", 23),
    ['scoreBoardFont'] = love.graphics.newFont("fonts/Maler.ttf", 16),
    ['scoreBoardFontSmall'] = love.graphics.newFont("fonts/Maler.ttf", 12),
    ['enterFont'] = love.graphics.newFont("fonts/Maler.ttf", 18)
}


-- sounds table
sounds = {
    ['background'] = love.audio.newSource('sounds/background.mp3', 'static'),
    ['winner']  = love.audio.newSource('sounds/winner.mp3', 'static'),
    ['hover']  = love.audio.newSource('sounds/hover.mp3', 'static'),
    ['click']  = love.audio.newSource('sounds/click.mp3', 'static'),
    ['gameWon'] = love.audio.newSource('sounds/gameWon.mp3', 'static')
}

    -- set the title of the application window
    love.window.setTitle('TicTacToe')
    home = true
    moveCounter = 0
    inputFailed = false
    randomStart = 0
    timePassed = 0
    timeToPass = 2.2
    

    gameTitle = Buttons(VIRTUAL_WIDTH, VIRTUAL_HEIGHT + 50, 20 / 255, 175 / 255, 20 / 255, 150, 50, 50)
    buttonLayer1 = Buttons(VIRTUAL_WIDTH + 150, VIRTUAL_HEIGHT - 50, 0.3, 0.6, 0.5, 150, 50, 40)
    buttonLayer2 = Buttons(VIRTUAL_WIDTH + 150, VIRTUAL_HEIGHT + 50, 0.4, 0.7, 0.5, 150, 50, 50)

    button2Layer1 = Buttons(VIRTUAL_WIDTH + 150, VIRTUAL_HEIGHT - 50, 0.3, 0.6, 0.5, 150, 50, 40)
    button2Layer2 = Buttons(VIRTUAL_WIDTH + 150, VIRTUAL_HEIGHT + 50, 0.4, 0.7, 0.5, 150, 50, 50)

    inst1 = Buttons(VIRTUAL_WIDTH - 250, VIRTUAL_HEIGHT + 130, 0 / 255, 225 / 255, 97 / 255, 200, 30, 78)
    inst2 = Buttons(VIRTUAL_WIDTH - 250, VIRTUAL_HEIGHT + 190, 50 / 255, 175 / 255, 20 / 255, 200, 30, 100)

    quit1 = Buttons(VIRTUAL_WIDTH + 250, VIRTUAL_HEIGHT + 130, 0 / 255, 225 / 255, 97 / 255, 200, 30, 88)
    quit2 = Buttons(VIRTUAL_WIDTH + 250, VIRTUAL_HEIGHT + 190, 50 / 255, 175 / 255, 20 / 255, 200, 30, 100)

    buttonInside1 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT / 4 - 15, 0.3, 0.6, 0.5, 80, 18, 40)
    buttonInside2 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT / 4 + 7, 0.7, 0.6, 0.5, 80, 12, 20)

    continue1 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT + 214, 0 / 255, 255 / 255, 97 / 255, 90, 18, 40)
    continue2 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT + 242, 20 / 255, 175 / 255, 20 / 255, 90, 13, 30)

    home1 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 255 / 255, 127 / 255, 80, 18, 15)
    home2 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 + 7, 0 / 255, 255 / 255, 127 / 255, 80, 18, 15)

    animation = newAnimation(love.graphics.newImage("sprite/loading.png"), 500, 500, 1)

    bg_image = love.graphics.newImage("img/background.png")

    initializeGame()
end

function love.update(dt)
    if home then                         -- while on start screen
        love.audio.stop()
        temp = 0
        local x = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())
        local y = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())

        -- when left clicked on the button, proceed to gameplay
        if love.mouse.isDown('1') then
            a = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())
            b = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())

            -- if mouse coordinates are within the button vertices (2 players option)
            if a >= ((VIRTUAL_WIDTH + 250) / 2 - 100) and a <= ((VIRTUAL_WIDTH + 250) / 2 + 100)
                    and b >= ((VIRTUAL_HEIGHT - 30) / 2 - 15) and b <= ((VIRTUAL_HEIGHT + 30) / 2 + 15) then
                home = false
                player2Selected = true
                player1Selected = false
                inst = false
                temp = 1
                sounds['click']:play()

            elseif a >= ((VIRTUAL_WIDTH - 250) / 2 - 100) and a <= ((VIRTUAL_WIDTH - 250) / 2 + 100)
                    and b >= ((VIRTUAL_HEIGHT - 30) / 2 - 15) and b <= ((VIRTUAL_HEIGHT + 30) / 2 + 15) then
                home = false
                player2Selected = false
                player1Selected = true
                inst = false
                temp = 1
                sounds['click']:play()

            elseif a >= ((VIRTUAL_WIDTH - 250) / 2 - 100) and a <= ((VIRTUAL_WIDTH - 250) / 2 + 100)
                    and b >= ((VIRTUAL_HEIGHT + 130) / 2 - 15) and b <= ((VIRTUAL_HEIGHT + 190) / 2 + 15) then
                home = false
                player2Selected = false
                player1Selected = false
                inst = true
                temp = 1
                sounds['click']:play()

            elseif a >= ((VIRTUAL_WIDTH + 250) / 2 - 100) and a <= ((VIRTUAL_WIDTH + 250) / 2 + 100)
                    and b >= ((VIRTUAL_HEIGHT + 130) / 2 - 15) and b <= ((VIRTUAL_HEIGHT + 190) / 2 + 15) then
                love.event.quit()
            end
        end

        local soundSX = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())
        local soundSY = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())

        -- 2 player button
        -- show mouse cursor hovering effect and play corresponding sound effect
        if x >= ((VIRTUAL_WIDTH + 250) / 2 - 100) and x <= ((VIRTUAL_WIDTH + 250) / 2 + 100)
                and y >= ((VIRTUAL_HEIGHT - 30) / 2 - 15) and y <= ((VIRTUAL_HEIGHT + 30) / 2 + 15) then
            buttonLayer1 = Buttons(VIRTUAL_WIDTH + 250, VIRTUAL_HEIGHT - 30, 0 / 255, 255 / 255, 127 / 255, 200, 30, 45)
            buttonLayer2 = Buttons(VIRTUAL_WIDTH + 250, VIRTUAL_HEIGHT + 30, 50 / 255, 205 / 255, 50 / 255, 200, 30, 51)
            gameTitle = Buttons(VIRTUAL_WIDTH, VIRTUAL_HEIGHT + 50, 20 / 255, 175 / 255, 20 / 255, 150, 50, 50)

            -- avoid repeating sound
            if not (cursorPointsSS[1] >= ((VIRTUAL_WIDTH + 250) / 2 - 100) and cursorPointsSS[1] <= ((VIRTUAL_WIDTH + 250) / 2 + 100)
                and cursorPointsSS[2] >= ((VIRTUAL_HEIGHT - 30) / 2 - 15) and cursorPointsSS[2] <= ((VIRTUAL_HEIGHT + 30) / 2 + 15)) then
                sounds['hover']:play()
            end
        else

            buttonLayer1 = Buttons(VIRTUAL_WIDTH + 250, VIRTUAL_HEIGHT - 30, 0 / 255, 225 / 255, 97 / 255, 200, 30, 40)
            buttonLayer2 = Buttons(VIRTUAL_WIDTH + 250, VIRTUAL_HEIGHT + 30, 20 / 255, 175 / 255, 20 / 255, 200, 30, 51)
            gameTitle = Buttons(VIRTUAL_WIDTH, VIRTUAL_HEIGHT + 50, 20 / 255, 175 / 255, 20 / 255, 150, 50, 50)

        end

        -- 1 player button
        if x >= ((VIRTUAL_WIDTH - 250) / 2 - 100) and x <= ((VIRTUAL_WIDTH - 250) / 2 + 100)
                and y >= ((VIRTUAL_HEIGHT - 30) / 2 - 15) and y <= ((VIRTUAL_HEIGHT + 30) / 2 + 15) then
            button2Layer1 = Buttons(VIRTUAL_WIDTH - 250, VIRTUAL_HEIGHT - 30, 0 / 255, 255 / 255, 127 / 255, 200, 30, 11)
            button2Layer2 = Buttons(VIRTUAL_WIDTH - 250, VIRTUAL_HEIGHT + 30, 50 / 255, 205 / 255, 50 / 255, 200, 30, 100)

            -- avoid repeating sound
            if not (cursorPointsSS[1] >= ((VIRTUAL_WIDTH - 250) / 2 - 100) and cursorPointsSS[1] <= ((VIRTUAL_WIDTH - 250) / 2 + 100)
                and cursorPointsSS[2] >= ((VIRTUAL_HEIGHT - 30) / 2 - 15) and cursorPointsSS[2] <= ((VIRTUAL_HEIGHT + 30) / 2 + 15)) then
                sounds['hover']:play()
            end
        else    
            button2Layer1 = Buttons(VIRTUAL_WIDTH - 250, VIRTUAL_HEIGHT - 30, 0 / 255, 225 / 255, 97 / 255, 200, 30, 7)
            button2Layer2 = Buttons(VIRTUAL_WIDTH - 250, VIRTUAL_HEIGHT + 30, 20 / 255, 175 / 255, 20 / 255, 200, 30, 100)
        end


        -- instruction
        if x >= ((VIRTUAL_WIDTH - 250) / 2 - 100) and x <= ((VIRTUAL_WIDTH - 250) / 2 + 100)
                and y >= ((VIRTUAL_HEIGHT + 130) / 2 - 15) and y <= ((VIRTUAL_HEIGHT + 190) / 2 + 15) then
            inst1 = Buttons(VIRTUAL_WIDTH - 250, VIRTUAL_HEIGHT + 130, 0 / 255, 255 / 255, 127 / 255, 200, 30, 77)
            inst2 = Buttons(VIRTUAL_WIDTH - 250, VIRTUAL_HEIGHT + 190, 50 / 255, 205 / 255, 50 / 255, 200, 30, 100)

            -- avoid repeating sound
            if not (cursorPointsSS[1] >= ((VIRTUAL_WIDTH - 250) / 2 - 100) and cursorPointsSS[1] <= ((VIRTUAL_WIDTH - 250) / 2 + 100)
                and cursorPointsSS[2] >= ((VIRTUAL_HEIGHT + 130) / 2 - 15) and cursorPointsSS[2] <= ((VIRTUAL_HEIGHT + 190) / 2 + 15)) then
                sounds['hover']:play()
            end
        else    
            inst1 = Buttons(VIRTUAL_WIDTH - 250, VIRTUAL_HEIGHT + 130, 0 / 255, 225 / 255, 97 / 255, 200, 30, 78)
            inst2 = Buttons(VIRTUAL_WIDTH - 250, VIRTUAL_HEIGHT + 190, 50 / 255, 175 / 255, 20 / 255, 200, 30, 100)
        end


        -- quit
        if x >= ((VIRTUAL_WIDTH + 250) / 2 - 100) and x <= ((VIRTUAL_WIDTH + 250) / 2 + 100)
                and y >= ((VIRTUAL_HEIGHT + 130) / 2 - 15) and y <= ((VIRTUAL_HEIGHT + 190) / 2 + 15) then
            quit1 = Buttons(VIRTUAL_WIDTH + 250, VIRTUAL_HEIGHT + 130, 0 / 255, 255 / 255, 127 / 255, 200, 30, 87)
            quit2 = Buttons(VIRTUAL_WIDTH + 250, VIRTUAL_HEIGHT + 190, 50 / 255, 205 / 255, 50 / 255, 200, 30, 100)

            -- avoid repeating sound
            if not (cursorPointsSS[1] >= ((VIRTUAL_WIDTH + 250) / 2 - 100) and cursorPointsSS[1] <= ((VIRTUAL_WIDTH + 250) / 2 + 100)
                and cursorPointsSS[2] >= ((VIRTUAL_HEIGHT + 130) / 2 - 15) and cursorPointsSS[2] <= ((VIRTUAL_HEIGHT + 190) / 2 + 15)) then
                sounds['hover']:play()
            end
        else    
            quit1 = Buttons(VIRTUAL_WIDTH + 250, VIRTUAL_HEIGHT + 130, 0 / 255, 225 / 255, 97 / 255, 200, 30, 88)
            quit2 = Buttons(VIRTUAL_WIDTH + 250, VIRTUAL_HEIGHT + 190, 50 / 255, 175 / 255, 20 / 255, 200, 30, 100)
        end


        --[[ adding last mouse position to table. This prevents hover sound effect from playing everytime
             the update function is called. Instead the hover sound plays only if the current mouse x-y coordinates
             are inside the button vertices and are not the same as the last x-y coordinates saved in the table.
             i.e. the last x-y coordinates stored in the table has to be outside the button ]]

        cursorPointsSS = {
            soundSX, soundSY
        }


    elseif inst then
        --love.audio.stop()
        temp = 0
        instruction1 = "Get 3 crosses(X) or noughts(O) in a row to win a game"
        instruction2 = "Crosses(X) or noughts(O) need to align horizontally/vertically/diagonally"
        instruction3 = "Get to 5 points first to be elected as the\nwinner of the round"

        local bX = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())
        local bY = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())
        local soundGX = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())
        local soundGY = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())

        if love.mouse.isDown('1') then
            local a = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())
            local b = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())

            if a >= ((2 * VIRTUAL_WIDTH - 242) / 2 - 40) and a <= ((2 * VIRTUAL_WIDTH - 242) / 2 + 40) and
                    b >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and b <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17) then
                sounds['click']:play()
                home = true
                player2Selected = false
                player1Selected = false
                inst = false
                temp = 1
                reset()
            end        

        end    

        -- home button aesthetics
        -- if mouse coordinates are within the button vertices
        if bX >= ((2 * VIRTUAL_WIDTH - 242) / 2 - 40) and bX <= ((2 * VIRTUAL_WIDTH - 242) / 2 + 40) and
                bY >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17) then
            home1 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 255 / 255, 127 / 255, 80, 18, 15)
            home2 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 + 7, 50 / 255, 205 / 255, 50 / 255, 80, 12, 2)

            -- avoid restart button repeating sound when hovered over
            if not (cursorPointsGS[1] >= ((2 * VIRTUAL_WIDTH - 242) / 2 - 40) and cursorPointsGS[1] <= ((2 * VIRTUAL_WIDTH - 242) / 2 + 40) and
                cursorPointsGS[2] >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and cursorPointsGS[2] <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17)) then
                sounds['hover']:play()
            end
        else
            home1 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 225 / 255, 97 / 255, 80, 18, 14)
            home2 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 + 7, 20 / 255, 175 / 255, 20 / 255, 80, 12, 1)
        end

        cursorPointsGS = {
            soundGX, soundGY
        }

    elseif player2Selected then -----------------------------------------------------------------------
        sounds['background']:play()


        -- prints which player serves
        if (val0 == 0 and val1 == 0 and val2 == 0) and (val3 == 0 and val4 == 0 and val5 == 0) and
                    (val6 == 0 and val7 == 0 and val8 == 0) then
            if player1 then
                serve = "Player 1 serves"
            elseif player2 then
                serve = "Player 2 serves"
            end
        end

        -- restart button function, scaled to fit phone display dimensions
        local bX = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())
        
        local bY = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())
        local soundGX = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())
        local soundGY = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())

        -- restart button aesthetics
        -- if mouse coordinates are within the button vertices
        if bX >= ((VIRTUAL_WIDTH / 4 - 5) / 2 - 40) and bX <= ((VIRTUAL_WIDTH / 4 - 5) / 2 + 40) and
                bY >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17) then
            buttonInside1 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 255 / 255, 127 / 255, 80, 18, 15)
            buttonInside2 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT / 4 + 7, 50 / 255, 205 / 255, 50 / 255, 80, 12, 15)

            -- avoid restart button repeating sound when hovered over
            if not (cursorPointsGS[1] >= ((VIRTUAL_WIDTH / 4 - 5) / 2 - 40) and cursorPointsGS[1] <= ((VIRTUAL_WIDTH / 4 - 5) / 2 + 40) and
                cursorPointsGS[2] >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and cursorPointsGS[2] <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17)) then
                sounds['hover']:play()
            end
        else
            buttonInside1 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 225 / 255, 97 / 255, 80, 18, 14)
            buttonInside2 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT / 4 + 7, 20 / 255, 175 / 255, 20 / 255, 80, 12, 14)
        end


        -- continue button aesthetics
        if bX >= ((VIRTUAL_WIDTH / 4 - 5) / 2 - 45) and bX <= ((VIRTUAL_WIDTH / 4 - 5) / 2 + 45) and 
                bY >= ((VIRTUAL_HEIGHT + 214) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT + 242) / 2 + 6.5) and continueShown then
            continue1 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT + 214, 0 / 255, 255 / 255, 127 / 255, 90, 18, 40)
            continue2 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT + 242, 50 / 255, 205 / 255, 50 / 255, 90, 13, 35)

            -- avoid restart button repeating sound when hovered over
            if not (cursorPointsGS[1] >= ((VIRTUAL_WIDTH / 4 - 5) / 2 - 45) and cursorPointsGS[1] <= ((VIRTUAL_WIDTH / 4 - 5) / 2 + 45) and
                cursorPointsGS[2] >= ((VIRTUAL_HEIGHT + 214) / 2 - 9) and cursorPointsGS[2] <= ((VIRTUAL_HEIGHT + 242) / 2 + 6.5)) then
                sounds['hover']:play()
            end

        elseif continueShown then
            continue1 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT + 214, 0 / 255, 225 / 255, 97 / 255, 90, 18, 40)
            continue2 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT + 242, 20 / 255, 175 / 255, 20 / 255, 90, 13, 30)
        end   
        
        
        -- home button aesthetics
        -- if mouse coordinates are within the button vertices
        if bX >= ((2 * VIRTUAL_WIDTH - 242) / 2 - 40) and bX <= ((2 * VIRTUAL_WIDTH - 242) / 2 + 40) and
                bY >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17) then
            home1 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 255 / 255, 127 / 255, 80, 18, 15)
            home2 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 + 7, 50 / 255, 205 / 255, 50 / 255, 80, 12, 2)

            -- avoid restart button repeating sound when hovered over
            if not (cursorPointsGS[1] >= ((2 * VIRTUAL_WIDTH - 242) / 2 - 40) and cursorPointsGS[1] <= ((2 * VIRTUAL_WIDTH - 242) / 2 + 40) and
                cursorPointsGS[2] >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and cursorPointsGS[2] <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17)) then
                sounds['hover']:play()
            end
        else
            home1 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 225 / 255, 97 / 255, 80, 18, 14)
            home2 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 + 7, 20 / 255, 175 / 255, 20 / 255, 80, 12, 1)
        end

        --[[ adding last mouse position to table. This prevents hover sound effect from playing everytime
             the update function is called. Instead the hover sound plays only if the current mouse x-y coordinates
             are inside the button vertices and are not the same as the last x-y coordinates saved in the table.
             i.e. the last x-y coordinates stored in the table has to be outside the button ]]

        cursorPointsGS = {
            soundGX, soundGY
        }

        -- buffer to avoid multiple mouse click registration
        if temp <= 5 then
            if love.mouse.isDown('1') then
                bufferX = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())
                bufferY = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())
            end
            temp = temp + 1
        else

            if love.mouse.isDown('1') then
                xPos = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())  -- scaling to fit phone display dimensions
                yPos = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())
                love.audio.setVolume(1)
                sounds['click']:play()
                serve = ""

                -- restart button function
                if bX >= ((VIRTUAL_WIDTH / 4 - 5) / 2 - 40) and bX <= ((VIRTUAL_WIDTH / 4 - 5) / 2 + 40) and
                    bY >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17) then
                    randomStart = 0
                    initializeGame()
                    player2Score = 0
                    player1Score = 0
                    waitingForInput = false
                    continuation = ""
                end

                -- continue button function
                if bX >= ((VIRTUAL_WIDTH / 4 - 5) / 2 - 45) and bX <= ((VIRTUAL_WIDTH / 4 - 35) / 2 + 45) and 
                    bY >= ((VIRTUAL_HEIGHT + 214) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT + 242) / 2 + 6.5) and continueShown then
                        waitingForInput = false
                        continuation = ""
                        serve = ""
                        initializeGame()            -- resetting the game
                        continueShown = false

                end    

                -- home button function
                if bX >= ((2 * VIRTUAL_WIDTH - 242) / 2 - 40) and bX <= ((2 * VIRTUAL_WIDTH - 242) / 2 + 40) and
                    bY >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17) then
                        player1Selected = false
                        player2Selected = false
                        home = true
                        reset()
                end        

                -- for each cell, if mouse is clicked, print x or o depending on the player
                if (xPos >= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2) + layout_column_width) and
                    (xPos <= VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2)) and
                    (yPos >= (VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2)) - 60 + layout_row_height) and
                    (yPos <= VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2) - 60)) and cell4 then

                    if player1 then
                        cross4 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 90, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val4 = 1
                    elseif player2 then
                        circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val4 = 2
                    end

                    cell4 = false           -- setting boolean value to false so that cell does not accept anymore input

                end

                if (xPos >= (VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2) + layout_column_width) and
                    (xPos <= (row_x + layout_row_width)) and
                    (yPos >= (VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2)) - 60 + layout_row_height) and
                    (yPos <= VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2) - 60)) and cell5 then

                    if player1 then
                        cross5 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 90, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val5 = 1
                    elseif player2 then
                        circle5 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val5 = 2
                    end

                    cell5 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

                if (xPos >= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2) + layout_column_width) and
                        (xPos <= VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2)) and
                        (yPos >= (VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2)) - 60 + layout_row_height)  and
                        (yPos <= column_y - 60 + layout_column_height)) and cell7 then

                    if player1 then
                        cross7 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 + 46, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val7 = 1
                    elseif player2 then
                        circle7 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 + 76, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val7 = 2
                    end

                    cell7 = false           -- setting boolean value to false so that cell does not accept anymore input

                end

                if (xPos >= (VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2) + layout_column_width) and
                    (xPos <= (row_x + layout_row_width)) and
                    (yPos >= (VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2)) - 60 + layout_row_height) and
                    (yPos <= column_y - 60 + layout_column_height)) and cell8 then

                    if player1 then
                        cross8 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 + 46, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val8 = 1
                    elseif player2 then
                        circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 80, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val8 = 2
                    end

                    cell8 = false           -- setting boolean value to false so that cell does not accept anymore input
                end


                if (xPos >= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2) + layout_column_width) and
                    xPos <= (VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2)) and
                    (yPos >= column_y - 60) and
                    (yPos <= VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2) - 60)) and cell1 then

                    if player2 then
                        circle1 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 195, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val1 = 2
                    elseif player1 then
                        cross1 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 230, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val1 = 1
                    end

                    cell1 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

                if (xPos >= (VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2) + layout_column_width) and
                    xPos <= (row_x + layout_row_width)) and
                    (yPos >= column_y - 60) and (yPos <= VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2) - 60) 
                    and cell2 then
                    if player1 then
                        cross2 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 225, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val2 = 1
                    elseif player2 then
                        circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val2 = 2
                    end

                    cell2 = false           -- setting boolean value to false so that cell does not accept anymore input
                end


                if (xPos <= VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2) and
                        (xPos >= row_x) and (yPos >= ((VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2)) - 60 + layout_row_height)) and
                        (yPos <= VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2) - 60)) and cell3 then
                    if player1 then
                        cross3 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 90, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val3 = 1
                    elseif player2 then
                        circle3 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val3 = 2
                    end
                    cell3 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

                if (xPos >= row_x and xPos <= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2)) and
                        (yPos >= column_y - 60) and
                        (yPos <= VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2) - 60)) and cell0 then

                    if player1 then
                        cross0 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 225, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val0 = 1
                    elseif player2 then
                        circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val0 = 2
                    end

                    cell0 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

                if (xPos >= row_x and xPos <= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2)) and
                        (yPos >= (VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2)) - 60 + layout_row_height) and
                        (yPos <= column_y - 60 + layout_column_height)) and cell6 then

                    if player1 then
                        cross6 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 + 46, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val6 = 1
                    elseif player2 then
                        circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 81, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val6 = 2
                    end

                    cell6 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

            end

            if (val0 == 1 and val1 == 1 and val2 == 1) or (val0 == 2 and val1 == 2 and val2 == 2) or
                (val3 == 1 and val4 == 1 and val5 == 1) or (val3 == 2 and val4 == 2 and val5 == 2) or
                (val6 == 1 and val7 == 1 and val8 == 1) or (val6 == 2 and val7 == 2 and val8 == 2) or
                (val0 == 1 and val3 == 1 and val6 == 1) or (val0 == 2 and val3 == 2 and val6 == 2) or
                (val1 == 1 and val4 == 1 and val7 == 1) or (val1 == 2 and val4 == 2 and val7 == 2) or
                (val2 == 1 and val5 == 1 and val8 == 1) or (val2 == 2 and val5 == 2 and val8 == 2) or
                (val2 == 1 and val4 == 1 and val6 == 1) or (val2 == 2 and val4 == 2 and val6 == 2) or
                (val0 == 1 and val4 == 1 and val8 == 1) or (val0 == 2 and val4 == 2 and val8 == 2) and player1Score ~= 5
                and player2Score ~= 5 then

                -- if a player has 3 straight Xs or Os, the board does not accept further inputs
                cell0 = false
                cell1 = false
                cell2 = false
                cell3 = false
                cell4 = false
                cell5 = false
                cell6 = false
                cell7 = false
                cell8 = false

                if player1 and not waitingForInput then
                    player2Score = player2Score + 1        -- player score updated depending on which player made the last move
                elseif player2 and not waitingForInput then
                    player1Score = player1Score + 1        -- player score updated depending on which player made the last move
                end
                waitingForInput = true
                continuation = "Touch to continue"
                showPath()

            -- tie function
            elseif (val0 ~= 0 and val1 ~= 0 and val2 ~= 0) and (val3 ~= 0 and val4 ~= 0 and val5 ~= 0) and
                    (val6 ~= 0 and val7 ~= 0 and val8 ~= 0) then
                waitingForInput = true
                continuation = "TIE"
            end


            -- if a player has 5 points, the game is over and winner is declared
            if player1Score == 5 or player2Score == 5 then
                if player1Score == 5 then
                    if winnerSound == 0 then
                        sounds['winner']:play()
                        winnerSound = winnerSound + 1
                    end
                    continuation = "Player 1 won"
                    waitingForInput = true
                else
                    if winnerSound == 0 then
                        sounds['winner']:play()
                        winnerSound = winnerSound + 1
                    end
                    continuation = "Player 2 won"
                    waitingForInput = true
                end
            end
        end


    elseif player1Selected then -----------------------------------------------------------------------
        animation.currentTime = animation.currentTime + dt
        if animation.currentTime >= animation.duration then
            animation.currentTime = animation.currentTime - animation.duration
        end

        sounds['background']:play()

        -- prints which player serves
        if (val0 == 0 and val1 == 0 and val2 == 0) and (val3 == 0 and val4 == 0 and val5 == 0) and
                    (val6 == 0 and val7 == 0 and val8 == 0) then
            if player1 then
                serve = "You serve"
            elseif player2 then
                serve = "Computer serves"
            end
        end

        -- restart button function, scaled to fit phone display dimensions
        local bX = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())
        
        local bY = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())
        local soundGX = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())
        local soundGY = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())

        -- restart button aesthetics
        -- if mouse coordinates are within the button vertices
        if bX >= ((VIRTUAL_WIDTH / 4 - 5) / 2 - 40) and bX <= ((VIRTUAL_WIDTH / 4 - 5) / 2 + 40) and
                bY >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17) then
            buttonInside1 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 255 / 255, 127 / 255, 80, 18, 15)
            buttonInside2 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT / 4 + 7, 50 / 255, 205 / 255, 50 / 255, 80, 12, 15)

            -- avoid restart button repeating sound when hovered over
            if not (cursorPointsGS[1] >= ((VIRTUAL_WIDTH / 4 - 5) / 2 - 40) and cursorPointsGS[1] <= ((VIRTUAL_WIDTH / 4 - 5) / 2 + 40) and
                cursorPointsGS[2] >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and cursorPointsGS[2] <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17)) then
                sounds['hover']:play()
            end
        else
            buttonInside1 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 225 / 255, 97 / 255, 80, 18, 14)
            buttonInside2 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT / 4 + 7, 20 / 255, 175 / 255, 20 / 255, 80, 12, 14)
        end


        -- continue button aesthetics
        if bX >= ((VIRTUAL_WIDTH / 4 - 5) / 2 - 45) and bX <= ((VIRTUAL_WIDTH / 4 - 5) / 2 + 45) and 
                bY >= ((VIRTUAL_HEIGHT + 214) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT + 242) / 2 + 6.5) and continueShown then
            continue1 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT + 214, 0 / 255, 255 / 255, 127 / 255, 90, 18, 40)
            continue2 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT + 242, 50 / 255, 205 / 255, 50 / 255, 90, 13, 35)

            -- avoid restart button repeating sound when hovered over
            if not (cursorPointsGS[1] >= ((VIRTUAL_WIDTH / 4 - 5) / 2 - 45) and cursorPointsGS[1] <= ((VIRTUAL_WIDTH / 4 - 5) / 2 + 45) and
                cursorPointsGS[2] >= ((VIRTUAL_HEIGHT + 214) / 2 - 9) and cursorPointsGS[2] <= ((VIRTUAL_HEIGHT + 242) / 2 + 6.5)) then
                sounds['hover']:play()
            end

        elseif continueShown then
            continue1 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT + 214, 0 / 255, 225 / 255, 97 / 255, 90, 18, 40)
            continue2 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT + 242, 20 / 255, 175 / 255, 20 / 255, 90, 13, 30)
        end               
        
        -- home button aesthetics
        -- if mouse coordinates are within the button vertices
        if bX >= ((2 * VIRTUAL_WIDTH - 242) / 2 - 40) and bX <= ((2 * VIRTUAL_WIDTH - 242) / 2 + 40) and
                bY >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17) then
            home1 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 255 / 255, 127 / 255, 80, 18, 15)
            home2 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 + 7, 50 / 255, 205 / 255, 50 / 255, 80, 12, 2)

            -- avoid restart button repeating sound when hovered over
            if not (cursorPointsGS[1] >= ((2 * VIRTUAL_WIDTH - 242) / 2 - 40) and cursorPointsGS[1] <= ((2 * VIRTUAL_WIDTH - 242) / 2 + 40) and
                cursorPointsGS[2] >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and cursorPointsGS[2] <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17)) then
                sounds['hover']:play()
            end
        else
            home1 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 225 / 255, 97 / 255, 80, 18, 14)
            home2 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 + 7, 20 / 255, 175 / 255, 20 / 255, 80, 12, 1)
        end


        --[[ adding last mouse position to table. This prevents hover sound effect from playing everytime
             the update function is called. Instead the hover sound plays only if the current mouse x-y coordinates
             are inside the button vertices and are not the same as the last x-y coordinates saved in the table.
             i.e. the last x-y coordinates stored in the table has to be outside the button ]]

        cursorPointsGS = {
            soundGX, soundGY
        }

        -- buffer to avoid multiple mouse click registration
        if temp <= 5 then
            if love.mouse.isDown('1') then
                bufferX = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())
                bufferY = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())
            end
            temp = temp + 1
        else

            if love.mouse.isDown('1') then
                xPos = love.mouse.getX() * (VIRTUAL_WIDTH / love.graphics.getWidth())  -- scaling to fit phone display dimensions
                yPos = love.mouse.getY() * (VIRTUAL_WIDTH / love.graphics.getWidth())
                love.audio.setVolume(1)
                sounds['click']:play()
                serve = ""

                -- restart button function
                if bX >= ((VIRTUAL_WIDTH / 4 - 5) / 2 - 40) and bX <= ((VIRTUAL_WIDTH / 4 - 5) / 2 + 40) and
                    bY >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17) then
                    randomStart = 0
                    initializeGame()
                    player2Score = 0
                    player1Score = 0
                    waitingForInput = false
                    continueShown = false
                    continuation = ""
                end

                -- continue button function
                if bX >= ((VIRTUAL_WIDTH / 4 - 5) / 2 - 45) and bX <= ((VIRTUAL_WIDTH / 4 - 5) / 2 + 45) and 
                    bY >= ((VIRTUAL_HEIGHT + 214) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT + 242) / 2 + 6.5) and continueShown then
                        waitingForInput = false
                        continuation = ""
                        serve = ""
                        initializeGame()            -- resetting the game
                        continueShown = false

                end   
                
                -- home button function
                if bX >= ((2 * VIRTUAL_WIDTH - 242) / 2 - 40) and bX <= ((2 * VIRTUAL_WIDTH - 242) / 2 + 40) and
                    bY >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17) then
                        player1Selected = false
                        player2Selected = false
                        home = true
                        reset()
                end    

            if player1 then
                moveCounter = moveCounter + 1
                -- for each cell, if mouse is clicked, print x or o depending on the player
                if (xPos >= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2) + layout_column_width) and
                    (xPos <= VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2)) and
                    (yPos >= (VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2)) - 60 + layout_row_height) and
                    (yPos <= VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2) - 60)) and cell4 then

                    if player1 then
                        cross4 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 90, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val4 = 1
                    end

                    cell4 = false           -- setting boolean value to false so that cell does not accept anymore input

                end

                if (xPos >= (VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2) + layout_column_width) and
                    (xPos <= (row_x + layout_row_width)) and
                    (yPos >= (VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2)) - 60 + layout_row_height) and
                    (yPos <= VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2) - 60)) and cell5 then

                    if player1 then
                        cross5 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 90, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val5 = 1
                    end

                    cell5 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

                if (xPos >= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2) + layout_column_width) and
                        (xPos <= VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2)) and
                        (yPos >= (VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2)) - 60 + layout_row_height)  and
                        (yPos <= column_y - 60 + layout_column_height)) and cell7 then

                    if player1 then
                        cross7 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 + 46, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val7 = 1
                    end

                    cell7 = false           -- setting boolean value to false so that cell does not accept anymore input

                end

                if (xPos >= (VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2) + layout_column_width) and
                    (xPos <= (row_x + layout_row_width)) and
                    (yPos >= (VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2)) - 60 + layout_row_height) and
                    (yPos <= column_y - 60 + layout_column_height)) and cell8 then

                    if player1 then
                        cross8 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 + 46, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val8 = 1
                    end

                    cell8 = false           -- setting boolean value to false so that cell does not accept anymore input
                end


                if (xPos >= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2) + layout_column_width) and
                    xPos <= (VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2)) and
                    (yPos >= column_y - 60) and
                    (yPos <= VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2) - 60)) and cell1 then

                    if player1 then
                        cross1 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 230, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val1 = 1
                    end

                    cell1 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

                if (xPos >= (VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2) + layout_column_width) and
                    xPos <= (row_x + layout_row_width)) and
                    (yPos >= column_y - 60) and (yPos <= VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2) - 60) 
                    and cell2 then
                    if player1 then
                        cross2 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 225, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val2 = 1
                    end

                    cell2 = false           -- setting boolean value to false so that cell does not accept anymore input
                end


                if (xPos <= VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2) and
                        (xPos >= row_x) and (yPos >= ((VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2)) - 60 + layout_row_height)) and
                        (yPos <= VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2) - 60)) and cell3 then
                    if player1 then
                        cross3 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 90, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val3 = 1
                    end
                    cell3 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

                if (xPos >= row_x and xPos <= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2)) and
                        (yPos >= column_y - 60) and
                        (yPos <= VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2) - 60)) and cell0 then

                    if player1 then
                        cross0 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 225, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val0 = 1
                    end

                    cell0 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

                if (xPos >= row_x and xPos <= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2)) and
                        (yPos >= (VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2)) - 60 + layout_row_height) and
                        (yPos <= column_y - 60 + layout_column_height)) and cell6 then

                    if player1 then
                        cross6 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 + 46, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val6 = 1
                    end

                    cell6 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

            end  

        end

                         

            if (val0 == 1 and val1 == 1 and val2 == 1) or (val0 == 2 and val1 == 2 and val2 == 2) or
                (val3 == 1 and val4 == 1 and val5 == 1) or (val3 == 2 and val4 == 2 and val5 == 2) or
                (val6 == 1 and val7 == 1 and val8 == 1) or (val6 == 2 and val7 == 2 and val8 == 2) or
                (val0 == 1 and val3 == 1 and val6 == 1) or (val0 == 2 and val3 == 2 and val6 == 2) or
                (val1 == 1 and val4 == 1 and val7 == 1) or (val1 == 2 and val4 == 2 and val7 == 2) or
                (val2 == 1 and val5 == 1 and val8 == 1) or (val2 == 2 and val5 == 2 and val8 == 2) or
                (val2 == 1 and val4 == 1 and val6 == 1) or (val2 == 2 and val4 == 2 and val6 == 2) or
                (val0 == 1 and val4 == 1 and val8 == 1) or (val0 == 2 and val4 == 2 and val8 == 2) and player1Score ~= 5
                and player2Score ~= 5 then

                -- if a player has 3 straight Xs or Os, the board does not accept further inputs
                cell0 = false
                cell1 = false
                cell2 = false
                cell3 = false
                cell4 = false
                cell5 = false
                cell6 = false
                cell7 = false
                cell8 = false

                if player1 and not waitingForInput then
                    player2Score = player2Score + 1        -- player score updated depending on which player made the last move
                elseif player2 and not waitingForInput then
                    player1Score = player1Score + 1        -- player score updated depending on which player made the last move
                end
                waitingForInput = true
                continuation = "Touch to continue"
                showPath()

            -- tie function
            elseif (val0 ~= 0 and val1 ~= 0 and val2 ~= 0) and (val3 ~= 0 and val4 ~= 0 and val5 ~= 0) and
                    (val6 ~= 0 and val7 ~= 0 and val8 ~= 0) then
                waitingForInput = true
                continuation = "TIE"
            end


            -- if a player has 5 points, the game is over and winner is declared
            if player1Score == 5 or player2Score == 5 then
                if player1Score == 5 then
                    if winnerSound == 0 then
                        sounds['winner']:play()
                        winnerSound = winnerSound + 1
                    end
                    continuation = "You won"
                    waitingForInput = true
                else
                    if winnerSound == 0 then
                        sounds['winner']:play()
                        winnerSound = winnerSound + 1
                    end
                    continuation = "Computer won"
                    waitingForInput = true
                end
            end


            if player2 and continueShown == false then 
                timePassed = timePassed + 1 * dt
                serve = "Computer serves"
                if timePassed > timeToPass then
                    timePassed = 0
                    if player2 then
                        win()
                    end
                    x1 = inputFailed
                    if player2 then
                        twoCase()
                    end            
                    x2 = inputFailed
                    if player2 then
                        -- call ai method here
                        aiMove()
                    end  
                    x3 = inputFailed
        
                    if (x1 and x2 and x3) == true and player2 then
                       fillIn()
                    end   
                end

            end

            if player1 and (val0 ~= 0 or val1 ~= 0 or val2 ~= 0 or val3 ~= 0 or val4 ~= 0 or
                val5 ~= 0 or val6 ~= 0 or val7 ~= 0 or val8 ~= 0) then
                serve = ""
            end    

        end
    end    
end


-- this function deals with the keyboard inputs
function love.keypressed(key)
    if (key == 'enter' or key == 'return') and waitingForInput and player1Score ~= 5 and player2Score ~= 5 then
        waitingForInput = false
        continuation = ""
        serve = ""
        initializeGame()            -- resetting the game
        continueShown = false

    elseif (key == 'enter' or key == 'return') and (player1Score == 5 or player2Score == 5) then
        player1Score = 0
        player2Score = 0
        waitingForInput = false
        continuation = ""
        serve = ""
        initializeGame()            -- resetting the game
        continueShown = false
    end
end


function love.draw()

    love.graphics.push()

    -- scale horizontally
    love.graphics.scale(love.graphics.getWidth() / (VIRTUAL_WIDTH))

    -- while on startup screen
    if home then

        love.graphics.setColor(1,1,1,1)
        --draw the background image
        love.graphics.draw(bg_image)

        buttonLayer1:render()
        buttonLayer2:render()
        buttonLayer1:buttonText()
        buttonLayer2:buttonText()
        gameTitle:buttonText()
        button2Layer1:render()
        button2Layer2:render()
        button2Layer1:buttonText()
        inst1:render()
        inst2:render()
        inst1:buttonText()
        quit1:render()
        quit2:render()
        quit1:buttonText()
        love.graphics.setColor(0, 0, 205 / 255)
        love.graphics.setFont(fonts['scoreBoardFont'])
        love.graphics.printf(title2, 295, VIRTUAL_WIDTH / 4 - 67 - 30, VIRTUAL_HEIGHT - 32)

        love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

    elseif inst then

        love.graphics.setColor(1,1,1,1)
        --draw the background image
        love.graphics.draw(bg_image)

        love.graphics.setColor(0, 0, 205 / 255)
        love.graphics.setFont(fonts['instFont'])
        love.graphics.printf(string.format("%s",instruction1), 0, 140, VIRTUAL_WIDTH, 'center')
        love.graphics.printf(string.format("%s",instruction2), 0, 190, VIRTUAL_WIDTH, 'center')
        love.graphics.printf(string.format("%s",instruction3), 0, 280, VIRTUAL_WIDTH, 'center')

        home1:render()
        home2:render()
        home2:buttonText()
        love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

    -- while on gameplay screen
    elseif player2Selected then -----------------------------------------------------------------------
        buttonInside1:render()
        buttonInside2:render()
        buttonInside2:buttonText()
        home1:render()
        home2:render()
        home2:buttonText()


        love.graphics.setColor(0, 0, 205 / 255)
        love.graphics.setFont(fonts['titleFont'])
        love.graphics.printf(title, 75, VIRTUAL_WIDTH / 4 - 67 - 33, VIRTUAL_HEIGHT / 3 - 32)

        love.graphics.setColor(0, 0, 205 / 255)
        love.graphics.setFont(fonts['scoreBoardFontSmall'])
        love.graphics.printf(titleInside, 78, VIRTUAL_WIDTH / 4 + 37, VIRTUAL_HEIGHT - 32)

        -- player 1 score board
        love.graphics.setColor(0, 0, 205 / 255)
        love.graphics.setFont(fonts['scoreBoardFont'])
        love.graphics.printf("Player 1 | x", VIRTUAL_WIDTH - 197, VIRTUAL_HEIGHT / 2 - 2.2 * layout_gap - (layout_row_height / 2),
            VIRTUAL_HEIGHT / 3 - 32)

        -- player 2 score board
        love.graphics.printf("Player 2 | O", VIRTUAL_WIDTH - 198, VIRTUAL_HEIGHT / 2 - 0.1 * layout_gap - (layout_row_height / 2),
            VIRTUAL_HEIGHT / 3 - 32)

        love.graphics.setFont(fonts['winnerFont'])
        love.graphics.printf(player1Score .. "", VIRTUAL_WIDTH - 97, VIRTUAL_HEIGHT / 2 - 1.8 * layout_gap - (layout_row_height / 2),
            VIRTUAL_HEIGHT / 3 - 32)
        love.graphics.printf(player2Score .. "", VIRTUAL_WIDTH - 97, VIRTUAL_HEIGHT / 2 + 0.3 * layout_gap - (layout_row_height / 2),
            VIRTUAL_HEIGHT / 3 - 32)


        love.graphics.setBackgroundColor(30 / 255, 144 / 255, 255 / 255, 0 / 255)
        love.graphics.setColor(255 / 255, 255 / 255, 255 / 255)

        -- drawing the layout on the canvas
        column1:render()
        column2:render()
        row1:render()
        row2:render()

        -- drawing the crosses on the canvas
        cross0:render()
        cross1:render()
        cross2:render()
        cross3:render()
        cross4:render()
        cross5:render()
        cross6:render()
        cross7:render()
        cross8:render()

        -- drawing the circles on the canvas
        circle0:render()
        circle1:render()
        circle2:render()
        circle3:render()
        circle4:render()
        circle5:render()
        circle6:render()
        circle7:render()
        circle8:render()

        love.graphics.setColor(0, 0.3, 0.6)
        love.graphics.setFont(fonts['winnerFont'])
        love.graphics.printf(string.format("%s",text), 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(0, 0.3, 0.6)
        love.graphics.printf(string.format("%s",text), 0, 12, VIRTUAL_WIDTH, 'center')

        if waitingForInput then
            love.graphics.setFont(fonts['enterFont'])
            if string.match(continuation, "TIE") then
                love.graphics.printf(string.format("%s",continuation), 101.5, VIRTUAL_HEIGHT - 210, VIRTUAL_WIDTH)
            elseif string.match(continuation, "won") then
                love.graphics.printf(string.format("%s",continuation), 53, VIRTUAL_HEIGHT - 210, VIRTUAL_WIDTH)
            
            end    
        end


        if (waitingForInput and player1Score ~= 5 and player2Score ~= 5) or (player1Score == 5 or player2Score == 5) 
                and not string.match(continuation, "won") then
            continue1:render()
            continue2:render()
            continue2:buttonText()
            continueShown = true
        end

        love.graphics.setFont(fonts['enterFont'])
        love.graphics.printf(string.format("%s",serve), 40, VIRTUAL_HEIGHT - 160, VIRTUAL_WIDTH)

        love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

    elseif player1Selected then -------------------------------------------------------------------------
        buttonInside1:render()
        buttonInside2:render()
        buttonInside2:buttonText() 
        home1:render()
        home2:render()
        home2:buttonText()

        love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

        love.graphics.setColor(0, 0, 205 / 255)
        love.graphics.setFont(fonts['titleFont'])
        love.graphics.printf(title, 75, VIRTUAL_WIDTH / 4 - 67 - 33, VIRTUAL_HEIGHT / 3 - 32)

        love.graphics.setColor(0, 0, 205 / 255)
        love.graphics.setFont(fonts['scoreBoardFontSmall'])
        love.graphics.printf(titleInside, 78, VIRTUAL_WIDTH / 4 + 37, VIRTUAL_HEIGHT - 32)

        -- player 1 score board
        love.graphics.setColor(0, 0, 205 / 255)
        love.graphics.setFont(fonts['scoreBoardFont'])
        love.graphics.printf("You | x", VIRTUAL_WIDTH - 152, VIRTUAL_HEIGHT / 2 - 2.2 * layout_gap - (layout_row_height / 2),
            VIRTUAL_HEIGHT / 3 - 32)

        -- player 2 score board
        love.graphics.printf("Computer | O", VIRTUAL_WIDTH - 207, VIRTUAL_HEIGHT / 2 - 0.1 * layout_gap - (layout_row_height / 2),
            VIRTUAL_HEIGHT / 3 - 32)

        love.graphics.setFont(fonts['winnerFont'])
        love.graphics.printf(player1Score .. "", VIRTUAL_WIDTH - 97, VIRTUAL_HEIGHT / 2 - 1.8 * layout_gap - (layout_row_height / 2),
            VIRTUAL_HEIGHT / 3 - 32)
        love.graphics.printf(player2Score .. "", VIRTUAL_WIDTH - 97, VIRTUAL_HEIGHT / 2 + 0.3 * layout_gap - (layout_row_height / 2),
            VIRTUAL_HEIGHT / 3 - 32)


        love.graphics.setBackgroundColor(30 / 255, 144 / 255, 255 / 255, 0 / 255)
        love.graphics.setColor(255 / 255, 255 / 255, 255 / 255)

        -- drawing the layout on the canvas
        column1:render()
        column2:render()
        row1:render()
        row2:render()

        -- drawing the crosses on the canvas
        cross0:render()
        cross1:render()
        cross2:render()
        cross3:render()
        cross4:render()
        cross5:render()
        cross6:render()
        cross7:render()
        cross8:render()

        -- drawing the circles on the canvas
        circle0:render()
        circle1:render()
        circle2:render()
        circle3:render()
        circle4:render()
        circle5:render()
        circle6:render()
        circle7:render()
        circle8:render()

        love.graphics.setColor(0, 0.3, 0.6)
        love.graphics.setFont(fonts['winnerFont'])
        love.graphics.printf(string.format("%s",text), 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(0, 0.3, 0.6)
        love.graphics.printf(string.format("%s",text), 0, 12, VIRTUAL_WIDTH, 'center')

        if waitingForInput then
            love.graphics.setFont(fonts['enterFont'])
            if string.match(continuation, "TIE") then
                love.graphics.printf(string.format("%s",continuation), 101.5, VIRTUAL_HEIGHT - 210, VIRTUAL_WIDTH)
            elseif string.match(continuation, "You won") then
                love.graphics.printf(string.format("%s",continuation), 75, VIRTUAL_HEIGHT - 210, VIRTUAL_WIDTH)
            elseif string.match(continuation, "Computer won") then
                love.graphics.printf(string.format("%s",continuation), 50, VIRTUAL_HEIGHT - 210, VIRTUAL_WIDTH)
                  
            end    
        end


        if (waitingForInput and player1Score ~= 5 and player2Score ~= 5) or (player1Score == 5 or player2Score == 5) 
                and not string.match(continuation, "won") then
            continue1:render()
            continue2:render()
            continue2:buttonText()
            continueShown = true
        end

        love.graphics.setFont(fonts['enterFont'])
        if player1 and player1Score ~= 5 and player2Score ~= 5 then
            love.graphics.printf(string.format("%s",serve), 66, VIRTUAL_HEIGHT - 160, VIRTUAL_WIDTH)
        elseif player2 and player1Score ~= 5 and player2Score ~= 5 then
            love.graphics.printf(string.format("%s",serve), 37, VIRTUAL_HEIGHT - 160, VIRTUAL_WIDTH)
        end    

        if player2 and continueShown == false and (player1Score ~= 5 and player2Selected ~= 5) then
            local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
            love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], 98, 320, 0, 1/12)
        end

    end
    love.graphics.pop()
end

-- this function initializes the gameplay screen layout
function initializeGame()

    winnerSound = 0

    -- initializing the grid
    column1 = Layout(VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2), column_y - 60, layout_column_width, layout_column_height)
    column2 = Layout(VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2), column_y - 60, layout_column_width, layout_column_height)
    row1 = Layout(row_x, (VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2)) - 60, layout_row_width, layout_row_height)
    row2 = Layout(row_x, (VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2)) - 60, layout_row_width, layout_row_height)

    -- initializing the 'O's
    circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 140, 38, 133 / 255, 155 / 255, 213 / 255, 0)
    circle1 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 140, 38, 133 / 255, 155 / 255, 213 / 255, 0)
    circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 140, 38, 133 / 255, 155 / 255, 213 / 255, 0)
    circle3 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2, 38, 133 / 255, 155 / 255, 213 / 255, 0)
    circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 38, 133 / 255, 155 / 255, 213 / 255, 0)
    circle5 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2, 38, 133 / 255, 155 / 255, 213 / 255, 0)
    circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 140, 38, 133 / 255, 155 / 255, 213 / 255, 0)
    circle7 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 + 140, 38, 133 / 255, 155 / 255, 213 / 255, 0)
    circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 140, 38, 133 / 255, 155 / 255, 213 / 255, 0)

    -- initializing the 'x's
    cross0 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 171, 65, 133 / 255, 155 / 255, 213 / 255 ,0)
    cross1 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 172, 65, 133 / 255, 155 / 255, 213 / 255, 0)
    cross2 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 172, 65, 133 / 255, 155 / 255, 213 / 255, 0)
    cross3 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 29, 65, 133 / 255, 155 / 255, 213 / 255, 0)
    cross4 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 31, 65, 133 / 255, 155 / 255, 213 / 255, 0)
    cross5 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 31, 65, 133 / 255, 155 / 255, 213 / 255, 0)
    cross6 = Cross(VIRTUAL_WIDTH / 3 - 5, VIRTUAL_HEIGHT / 2 + 110, 65, 133 / 255, 155 / 255, 213 / 255, 0)
    cross7 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 + 107, 65, 133 / 255, 155 / 255, 213 / 255, 0)
    cross8 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 + 107, 65, 133 / 255, 155 / 255, 213 / 255, 0)

    -- initializing boolean values, i.e. every cell is ready to receive an input
    cell0 = true
    cell1 = true
    cell2 = true
    cell3 = true
    cell4 = true
    cell5 = true
    cell6 = true
    cell7 = true
    cell8 = true

    if randomStart == 0 then
        num = love.math.random(2)           -- player to serve selected randomly at the start of the game

        if num == 1 then
            player1 = true
            player2 = false
        elseif num == 2 then
            player1 = false
            player2 = true
        end
    else                                    -- alternating serve
        if num % 2 == 0 then
            player1 = false
            player2 = true
        else
            player1 = true
            player2 = false
        end
    end

    -- cell values stored depending on the input from a particular player, 0 initially, 1 for player 1, 2 for player 2
    val0 = 0
    val1 = 0
    val2 = 0
    val3 = 0
    val4 = 0
    val5 = 0
    val6 = 0
    val7 = 0
    val8 = 0

    randomStart = randomStart + 1
    num = num + 1
end

-- this function highlights how a player has won a round, by changing colour of the Xs or Os
function showPath()
    if (val0 == 1 and val1 == 1 and val2 == 1) or (val0 == 2 and val1 == 2 and val2 == 2) then

        if val0 == 1 then
            cross0 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 225, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross1 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 230, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross2 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 225, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val0 == 2 then
            circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 200, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle1 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 195, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 200, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

        if continueShown == false then
            love.audio.setVolume(5)
            sounds['gameWon']:play()
        end    
        love.audio.setVolume(1)
        continueShown = true

    elseif (val3 == 1 and val4 == 1 and val5 == 1) or (val3 == 2 and val4 == 2 and val5 == 2) then

        if val3 == 1 then
            cross3 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 90, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross4 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 90, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross5 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 90, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val3 == 2 then
            circle3 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 60, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle5 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 60, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

        if continueShown == false then
            love.audio.setVolume(5)
            sounds['gameWon']:play()
        end    
        love.audio.setVolume(1)
        continueShown = true

    elseif (val6 == 1 and val7 == 1 and val8 == 1) or (val6 == 2 and val7 == 2 and val8 == 2) then

        if val6 == 1 then
            cross6 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 + 46, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross7 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 + 46, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross8 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 + 46, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val6 == 2 then
            circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 81, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle7 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 + 76, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 80, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

        if continueShown == false then
            love.audio.setVolume(5)
            sounds['gameWon']:play()
        end    
        love.audio.setVolume(1)
        continueShown = true

    elseif (val0 == 1 and val3 == 1 and val6 == 1) or (val0 == 2 and val3 == 2 and val6 == 2) then

        if val3 == 1 then
            cross0 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 225, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross3 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 90, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross6 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 + 46, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val3 == 2 then
            circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 200, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle3 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 60, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 81, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

        if continueShown == false then
            love.audio.setVolume(5)
            sounds['gameWon']:play()
        end    
        love.audio.setVolume(1)
        continueShown = true

    elseif (val1 == 1 and val4 == 1 and val7 == 1) or (val1 == 2 and val4 == 2 and val7 == 2) then

        if val4 == 1 then
            cross1 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 230, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross4 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 90, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross7 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 + 46, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val4 == 2 then
            circle1 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 195, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle7 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 + 76, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

        if continueShown == false then
            love.audio.setVolume(5)
            sounds['gameWon']:play()
        end    
        love.audio.setVolume(1)
        continueShown = true

    elseif (val2 == 1 and val5 == 1 and val8 == 1) or (val2 == 2 and val5 == 2 and val8 == 2) then

        if val5 == 1 then
            cross2 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 225, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross5 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 90, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross8 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 + 46, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val5 == 2 then
            circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 200, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle5 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 60, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 80, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

        if continueShown == false then
            love.audio.setVolume(5)
            sounds['gameWon']:play()
        end    
        love.audio.setVolume(1)
        continueShown = true

    elseif (val0 == 1 and val4 == 1 and val8 == 1) or (val0 == 2 and val4 == 2 and val8 == 2) then

        if val8 == 1 then
            cross0 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 225, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross4 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 90, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross8 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 + 46, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val8 == 2 then
            circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 200, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 80, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

        if continueShown == false then
            love.audio.setVolume(5)
            sounds['gameWon']:play()
        end    
        love.audio.setVolume(1)
        continueShown = true

    elseif (val2 == 1 and val4 == 1 and val6 == 1) or (val2 == 2 and val4 == 2 and val6 == 2) then

        if val6 == 1 then
            cross2 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 225, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross4 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 90, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross6 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 + 46, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val6 == 2 then
            circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 200, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 81, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

        if continueShown == false then
            love.audio.setVolume(5)
            sounds['gameWon']:play()
        end    
        love.audio.setVolume(1)
        continueShown = true

    end
end


function aiMove()
    
        list = {0, 2, 4, 6, 8}
        x = love.math.random(5)
        
        if list[x] == 0 and cell0 then
            circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

            -- switching player turn
            player2 = false
            player1 = true
            val0 = 2
            cell0 = false

        elseif list[x] == 2 and cell2 then
            circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

            -- switching player turn
            player2 = false
            player1 = true
            val2 = 2
            cell2 = false 

        elseif list[x] == 4 and cell4 then
            circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

            -- switching player turn
            player2 = false
            player1 = true
            val4 = 2
            cell4 = false
        elseif list[x] == 6 and cell6 then
            circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 81, 38, 255 / 255, 255 / 255, 255 / 255, 1)

            -- switching player turn
            player2 = false
            player1 = true
            val6 = 2
            cell6 = false

        elseif list[x] == 8 and cell8 then
            circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 80, 38, 255 / 255, 255 / 255, 255 / 255, 1)

            -- switching player turn
            player2 = false
            player1 = true
            val8 = 2
            cell8 = false
        else
            inputFailed = true

        end

end    


function twoCase()
    if val0 == 1 and val1 == 1 and cell2 == true then
        circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val2 = 2
        cell2 = false 

    elseif cell0 == true and val1 == 1 and val2 == 1 then
        circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val0 = 2
        cell0 = false    

    elseif val0 == 1 and cell1 == true and val2 == 1 then
        circle1 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 195, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val1 = 2
        cell1 = false

    elseif cell3 == true and val4 == 1 and val5 == 1 then
        circle3 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val3 = 2 
        cell3 = false

    elseif val3 == 1 and cell4 == true and val5 == 1 then
        circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val4 = 2
        cell4 = false

    elseif val3 == 1 and val4 == 1 and cell5 == true then
        circle5 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val5 = 2
        cell5 = false
        
    elseif cell6 == true and val7 == 1 and val8 == 1 then
        circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 81, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val6 = 2
        cell6 = false

    elseif val6 == 1 and cell7 == true and val8 == 1 then
        circle7 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 + 76, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val7 = 2
        cell7 = false

    elseif val6 == 1 and val7 == 1 and cell8 == true then
        circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 80, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val8 = 2
        cell8 = false

    elseif cell0 == true and val3 == 1 and val6 == 1 then
        circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val0 = 2
        cell0 = false   

    elseif val0 == 1 and cell3 == true and val6 == 1 then
        circle3 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val3 = 2 
        cell3 = false

    elseif val0 == 1 and val3 == 1 and cell6 == true then
        circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 81, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val6 = 2
        cell6 = false

    elseif cell1 == true and val4 == 1 and val7 == 1 then
        circle1 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 195, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val1 = 2
        cell1 = false
        
    elseif val1 == 1 and cell4 == true and val7 == 1 then
        circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val4 = 2
        cell4 = false

    elseif val1 == 1 and val4 == 1 and cell7 == true then
        circle7 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 + 76, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val7 = 2
        cell7 = false

    elseif cell2 == true and val5 == 1 and val8 == 1 then
        circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val2 = 2
        cell2 = false 
        
    elseif val2 == 1 and cell5 == true and val8 == 1 then
        circle5 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val5 = 2
        cell5 = false
        
    elseif val2 == 1 and val5 == 1 and cell8 == true then
        circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 80, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val8 = 2
        cell8 = false
        
    elseif cell0 == true and val4 == 1 and val8 == 1 then
        circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val0 = 2
        cell0 = false    
    elseif val0 == 1 and cell4 == true and val8 == 1 then
        circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val4 = 2
        cell4 = false
        
    elseif val0 == 1 and val4 == 1 and cell8 == true then
        circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 80, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val8 = 2
        cell8 = false
        
    elseif cell2 == true and val4 == 1 and val6 == 1 then
        circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val2 = 2
        cell2 = false 

    elseif val2 == 1 and cell4 == true and val6 == 1 then
        circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val4 = 2
        cell4 = false

    elseif val2 == 1 and val4 == 1 and cell6 == true then
        circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 81, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val6 = 2
        cell6 = false 
        
    else    
        inputFailed = true
    end    

end    

-------------------------------

function win()
    if val0 == 2 and val1 == 2 and cell2 == true then
        circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val2 = 2
        cell2 = false 

    elseif cell0 == true and val1 == 2 and val2 == 2 then
        circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val0 = 2
        cell0 = false    

    elseif val0 == 2 and cell1 == true and val2 == 2 then
        circle1 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 195, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val1 = 2
        cell1 = false

    elseif cell3 == true and val4 == 2 and val5 == 2 then
        circle3 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val3 = 2 
        cell3 = false

    elseif val3 == 2 and cell4 == true and val5 == 2 then
        circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val4 = 2
        cell4 = false

    elseif val3 == 2 and val4 == 2 and cell5 == true then
        circle5 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val5 = 2
        cell5 = false
        
    elseif cell6 == true and val7 == 2 and val8 == 2 then
        circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 81, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val6 = 2
        cell6 = false

    elseif val6 == 2 and cell7 == true and val8 == 2 then
        circle7 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 + 76, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val7 = 2
        cell7 = false

    elseif val6 == 2 and val7 == 2 and cell8 == true then
        circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 80, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val8 = 2
        cell8 = false

    elseif cell0 == true and val3 == 2 and val6 == 2 then
        circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val0 = 2
        cell0 = false   

    elseif val0 == 2 and cell3 == true and val6 == 2 then
        circle3 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val3 = 2 
        cell3 = false

    elseif val0 == 2 and val3 == 2 and cell6 == true then
        circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 81, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val6 = 2
        cell6 = false

    elseif cell1 == true and val4 == 2 and val7 == 2 then
        circle1 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 195, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val1 = 2
        cell1 = false
        
    elseif val1 == 2 and cell4 == true and val7 == 2 then
        circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val4 = 2
        cell4 = false

    elseif val1 == 2 and val4 == 2 and cell7 == true then
        circle7 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 + 76, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val7 = 2
        cell7 = false

    elseif cell2 == true and val5 == 2 and val8 == 2 then
        circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val2 = 2
        cell2 = false 
        
    elseif val2 == 2 and cell5 == true and val8 == 2 then
        circle5 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val5 = 2
        cell5 = false
        
    elseif val2 == 2 and val5 == 2 and cell8 == true then
        circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 80, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val8 = 2
        cell8 = false
        
    elseif cell0 == true and val4 == 2 and val8 == 2 then
        circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val0 = 2
        cell0 = false    
    elseif val0 == 2 and cell4 == true and val8 == 2 then
        circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val4 = 2
        cell4 = false
        
    elseif val0 == 2 and val4 == 2 and cell8 == true then
        circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 80, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val8 = 2
        cell8 = false
        
    elseif cell2 == true and val4 == 2 and val6 == 2 then
        circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val2 = 2
        cell2 = false 

    elseif val2 == 2 and cell4 == true and val6 == 2 then
        circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val4 = 2
        cell4 = false

    elseif val2 == 2 and val4 == 2 and cell6 == true then
        circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 81, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val6 = 2
        cell6 = false    
    else 
        inputFailed = true    
    end    

end    

function fillIn()
    if cell0 == true then
        circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val0 = 2
        cell0 = false  
    elseif cell1 == true then
        circle1 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 195, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val1 = 2
        cell1 = false
    elseif cell2 == true then
        circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 200, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val2 = 2
        cell2 = false 
    elseif cell3 == true then 
        circle3 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val3 = 2 
        cell3 = false
    elseif cell4 == true then
        circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val4 = 2
        cell4 = false
    elseif cell5 == true then
        circle5 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 60, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val5 = 2
        cell5 = false
    elseif cell6 == true then
        circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 81, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val6 = 2
        cell6 = false
    elseif cell7 == true then
        circle7 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 + 76, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val7 = 2
        cell7 = false
    elseif cell8 == true then
        circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 80, 38, 255 / 255, 255 / 255, 255 / 255, 1)

        -- switching player turn
        player2 = false
        player1 = true
        val8 = 2
        cell8 = false
    end        
    inputFailed = false
    
end    

function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};
 
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
 
    animation.duration = duration or 1
    animation.currentTime = 0
 
    return animation
end

function reset()

WINDOW_WIDTH = 960
WINDOW_HEIGHT = 540

VIRTUAL_WIDTH = 960
VIRTUAL_HEIGHT = 540

layout_column_width = 5
layout_column_height = 382

layout_gap = 70

layout_row_width = 406
layout_row_height = 6

column_y = 80
row_x = 279

title = "Tic\nTac\nToe"
title2 = "R   E   M   A   S   T   E   R   E   D"
titleInside = "REMASTERED"
text = ""
player1Score = 0
player2Score = 0
waitingForInput = false
continuation = ""
continueShown = false
home = true     -- user starts with home screen
player1Selected = false
player2Selected = false
inst = false
serve = ""
randomStart = 0
instruction1 = "Get 3 crosses(X) or noughts(O) in a row to win a game"
instruction2 = "Crosses(X) or noughts(O) need to align horizontally/vertically/diagonally"
instruction3 = "Get to 5 points first to be elected as the\nwinner of the round"

-- mouse position table for start screen
cursorPointsSS = {
            0, 0
}

-- mouse position table for gameplay screen
cursorPointsGS = {
            0, 0
}


-- This block makes UI slow
--------------------------------------------------------------
-- fonts table
--[[fonts = {
    ['titleFont'] = love.graphics.newFont("fonts/AlloyInk.ttf", 44),
    ['winnerFont'] = love.graphics.newFont("fonts/Maler.ttf", 32),
    ['instFont'] = love.graphics.newFont("fonts/Maler.ttf", 23),
    ['scoreBoardFont'] = love.graphics.newFont("fonts/Maler.ttf", 16),
    ['scoreBoardFontSmall'] = love.graphics.newFont("fonts/Maler.ttf", 12),
    ['enterFont'] = love.graphics.newFont("fonts/Maler.ttf", 18)
}


-- sounds table
sounds = {
    ['background'] = love.audio.newSource('sounds/background.mp3', 'static'),
    ['winner']  = love.audio.newSource('sounds/winner.mp3', 'static'),
    ['hover']  = love.audio.newSource('sounds/hover.mp3', 'static'),
    ['click']  = love.audio.newSource('sounds/click.mp3', 'static'),
    ['gameWon'] = love.audio.newSource('sounds/gameWon.mp3', 'static')
}]]
-------------------------------------------------------------

    -- set the title of the application window
    love.window.setTitle('TicTacToe')
    home = true
    moveCounter = 0
    inputFailed = false
    randomStart = 0
    timePassed = 0
    timeToPass = 2.2
    

    gameTitle = Buttons(VIRTUAL_WIDTH, VIRTUAL_HEIGHT + 50, 20 / 255, 175 / 255, 20 / 255, 150, 50, 50)
    buttonLayer1 = Buttons(VIRTUAL_WIDTH + 150, VIRTUAL_HEIGHT - 50, 0.3, 0.6, 0.5, 150, 50, 40)
    buttonLayer2 = Buttons(VIRTUAL_WIDTH + 150, VIRTUAL_HEIGHT + 50, 0.4, 0.7, 0.5, 150, 50, 50)

    button2Layer1 = Buttons(VIRTUAL_WIDTH + 150, VIRTUAL_HEIGHT - 50, 0.3, 0.6, 0.5, 150, 50, 40)
    button2Layer2 = Buttons(VIRTUAL_WIDTH + 150, VIRTUAL_HEIGHT + 50, 0.4, 0.7, 0.5, 150, 50, 50)

    inst1 = Buttons(VIRTUAL_WIDTH - 250, VIRTUAL_HEIGHT + 130, 0 / 255, 225 / 255, 97 / 255, 200, 30, 78)
    inst2 = Buttons(VIRTUAL_WIDTH - 250, VIRTUAL_HEIGHT + 190, 50 / 255, 175 / 255, 20 / 255, 200, 30, 100)

    quit1 = Buttons(VIRTUAL_WIDTH + 250, VIRTUAL_HEIGHT + 130, 0 / 255, 225 / 255, 97 / 255, 200, 30, 88)
    quit2 = Buttons(VIRTUAL_WIDTH + 250, VIRTUAL_HEIGHT + 190, 50 / 255, 175 / 255, 20 / 255, 200, 30, 100)

    buttonInside1 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT / 4 - 15, 0.3, 0.6, 0.5, 80, 18, 14)
    buttonInside2 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT / 4 + 7, 0.7, 0.6, 0.5, 80, 12, 14)

    continue1 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT + 214, 0 / 255, 255 / 255, 97 / 255, 90, 18, 30)
    continue2 = Buttons(VIRTUAL_WIDTH / 4 - 5, VIRTUAL_HEIGHT + 242, 20 / 255, 175 / 255, 20 / 255, 90, 13, 30)

    home1 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 255 / 255, 127 / 255, 80, 18, 1)
    home2 = Buttons(2 * VIRTUAL_WIDTH - 242, VIRTUAL_HEIGHT / 4 + 7, 0 / 255, 255 / 255, 127 / 255, 80, 18, 1)

    animation = newAnimation(love.graphics.newImage("sprite/loading.png"), 500, 500, 1)
    bg_image = love.graphics.newImage("img/background.png")

    initializeGame()
end    