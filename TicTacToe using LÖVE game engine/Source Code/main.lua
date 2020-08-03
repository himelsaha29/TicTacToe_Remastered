--[[
  Author: HimelSaha

]]

-- associating other required classes

-- push is a library that will allows to draw the game at a virtual
-- resolution, instead of however large the window is.
-- https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library facilitates representation of anything in
-- the game as code, rather than keeping track of many disparate variables and
-- methods
Class = require 'class'

require 'Layout'        -- draws the grid on gameplay screen
require 'Circle'        -- draws circle on canvas
require 'Cross'         -- draws cross on canvas
require 'Buttons'       -- draws buttons on canvas

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

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
text = ""
player1Score = 0
player2Score = 0
waitingForInput = false
continuation = ""
serve = ""
randomStart = 0

-- mouse position table for start screen
cursorPointsSS = {
            0, 0
}

-- mouse position table for gameplay screen
cursorPointsGS = {
            0, 0
}


-- fonts table
fonts = {
    ['titleFont'] = love.graphics.newFont("fonts/AlloyInk.ttf", 64),
    ['winnerFont'] = love.graphics.newFont("fonts/Maler.ttf", 32),
    ['scoreBoardFont'] = love.graphics.newFont("fonts/Maler.ttf", 16),
    ['enterFont'] = love.graphics.newFont("fonts/Maler.ttf", 22),
}


-- sounds table
sounds = {
    ['background'] = love.audio.newSource('sounds/background.mp3', 'static'),
    ['winner']  = love.audio.newSource('sounds/winner.mp3', 'static'),
    ['hover']  = love.audio.newSource('sounds/hover.mp3', 'static'),
    ['click']  = love.audio.newSource('sounds/click.mp3', 'static')
}



function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, VIRTUAL_WIDTH, VIRTUAL_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- set the title of the application window
    love.window.setTitle('TicTacToe')
    startUp = true

    buttonLayer1 = Buttons(VIRTUAL_WIDTH, VIRTUAL_HEIGHT - 50, 0.3, 0.6, 0.5, 150, 50, 40)
    buttonLayer2 = Buttons(VIRTUAL_WIDTH, VIRTUAL_HEIGHT + 50, 0.4, 0.7, 0.5, 150, 50, 50)

    buttonInside1 = Buttons(VIRTUAL_WIDTH / 4 - 35, VIRTUAL_HEIGHT / 4 - 15, 0.3, 0.6, 0.5, 80, 18, 40)
    buttonInside2 = Buttons(VIRTUAL_WIDTH / 4 - 35, VIRTUAL_HEIGHT / 4 + 7, 0.7, 0.6, 0.5, 80, 12, 20)

    initializeGame()
end

function love.update(dt)
    if startUp then                         -- while on start screen
        temp = 0
        local x, y = love.mouse.getPosition()

        -- when left clicked on the button, proceed to gameplay
        if love.mouse.isDown('1') then
            a = love.mouse.getX()
            b = love.mouse.getY()

            -- if mouse coordinates are within the button vertices
            if a >= (VIRTUAL_WIDTH / 2 - 75) and a <= (VIRTUAL_WIDTH / 2 + 75)
                    and b >= (VIRTUAL_HEIGHT / 2 - 50) and b <= (VIRTUAL_HEIGHT / 2 + 50) then
                startUp = false
                temp = 1
                sounds['click']:play()
            end
        end

        local soundSX, soundSY = love.mouse.getPosition()

        -- show mouse cursor hovering effect and play corresponding sound effect
        if x >= (VIRTUAL_WIDTH / 2 - 75) and x <= (VIRTUAL_WIDTH / 2 + 75)
                and y >= (VIRTUAL_HEIGHT / 2 - 50) and y <= (VIRTUAL_HEIGHT / 2 + 50) then
            buttonLayer1 = Buttons(VIRTUAL_WIDTH, VIRTUAL_HEIGHT - 50, 0 / 255, 255 / 255, 127 / 255, 150, 50, 45)
            buttonLayer2 = Buttons(VIRTUAL_WIDTH, VIRTUAL_HEIGHT + 50, 50 / 255, 205 / 255, 50 / 255, 150, 50, 50)

            -- avoid repeating sound
            if not (cursorPointsSS[1] >= (VIRTUAL_WIDTH / 2 - 75) and cursorPointsSS[1] <= (VIRTUAL_WIDTH / 2 + 75)
                and cursorPointsSS[2] >= (VIRTUAL_HEIGHT / 2 - 50) and cursorPointsSS[2] <= (VIRTUAL_HEIGHT / 2 + 50)) then
                sounds['hover']:play()
            end
        else

            buttonLayer1 = Buttons(VIRTUAL_WIDTH, VIRTUAL_HEIGHT - 50, 0 / 255, 225 / 255, 97 / 255, 150, 50, 40)
            buttonLayer2 = Buttons(VIRTUAL_WIDTH, VIRTUAL_HEIGHT + 50, 20 / 255, 175 / 255, 20 / 255, 150, 50, 50)

        end

        --[[ adding last mouse position to table. This prevents hover sound effect from playing everytime
             the update function is called. Instead the hover sound plays only if the current mouse x-y coordinates
             are inside the button vertices and are not the same as the last x-y coordinates saved in the table.
             i.e. the last x-y coordinates stored in the table has to be outside the button ]]

        cursorPointsSS = {
            soundSX, soundSY
        }

    else
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

        -- restart button function
        local bX, bY = love.mouse.getPosition()
        local soundGX, soundGY = love.mouse.getPosition()

        -- restart button aesthetics
        -- if mouse coordinates are within the button vertices
        if bX >= ((VIRTUAL_WIDTH / 4 - 35) / 2 - 40) and bX <= ((VIRTUAL_WIDTH / 4 - 35) / 2 + 40) and
                bY >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17) then
            buttonInside1 = Buttons(VIRTUAL_WIDTH / 4 - 35, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 255 / 255, 127 / 255, 80, 18, 15)
            buttonInside2 = Buttons(VIRTUAL_WIDTH / 4 - 35, VIRTUAL_HEIGHT / 4 + 7, 50 / 255, 205 / 255, 50 / 255, 80, 12, 15)

            -- avoid restart button repeating sound when hovered over
            if not (cursorPointsGS[1] >= ((VIRTUAL_WIDTH / 4 - 35) / 2 - 40) and cursorPointsGS[1] <= ((VIRTUAL_WIDTH / 4 - 35) / 2 + 40) and
                cursorPointsGS[2] >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and cursorPointsGS[2] <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17)) then
                sounds['hover']:play()
            end
        else
            buttonInside1 = Buttons(VIRTUAL_WIDTH / 4 - 35, VIRTUAL_HEIGHT / 4 - 15, 0 / 255, 225 / 255, 97 / 255, 80, 18, 14)
            buttonInside2 = Buttons(VIRTUAL_WIDTH / 4 - 35, VIRTUAL_HEIGHT / 4 + 7, 20 / 255, 175 / 255, 20 / 255, 80, 12, 14)
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
                bufferX = love.mouse.getX()
                bufferY = love.mouse.getY()
            end
            temp = temp + 1
        else

            if love.mouse.isDown('1') then
                xPos = love.mouse.getX()
                yPos = love.mouse.getY()
                love.audio.setVolume(1)
                sounds['click']:play()
                serve = ""

                if bX >= ((VIRTUAL_WIDTH / 4 - 35) / 2 - 40) and bX <= ((VIRTUAL_WIDTH / 4 - 35) / 2 + 40) and
                    bY >= ((VIRTUAL_HEIGHT / 4 - 15) / 2 - 9) and bY <= ((VIRTUAL_HEIGHT / 4 - 15) / 2 + 17) then
                    initializeGame()
                    player2Score = 0
                    player1Score = 0
                    continuation = ""
                end

                -- for each cell, if mouse is clicked, print x or o depending on the player
                if (xPos >= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2) + 5) and
                    (xPos <= VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2)) and
                    (yPos >= VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2) + 6) and
                    (yPos <= VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2))) and cell4 then

                    if player1 then
                        cross4 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 31, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val4 = 1
                    elseif player2 then
                        circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val4 = 2
                    end

                    cell4 = false           -- setting boolean value to false so that cell does not accept anymore input

                end

                if (xPos >= (VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2) + 5) and
                    (xPos <= (row_x + layout_row_width)) and
                    (yPos >= VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2) + 6) and
                    (yPos <= VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2))) and cell5 then

                    if player1 then
                        cross5 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 31, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val5 = 1
                    elseif player2 then
                        circle5 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val5 = 2
                    end

                    cell5 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

                if (xPos >= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2) + 5) and
                        (xPos <= VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2)) and
                        (yPos >= (VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2) + 6))  and
                        (yPos <= column_y + layout_column_height)) and cell7 then

                    if player1 then
                        cross7 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 + 107, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val7 = 1
                    elseif player2 then
                        circle7 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 + 140, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val7 = 2
                    end

                    cell7 = false           -- setting boolean value to false so that cell does not accept anymore input

                end

                if (xPos >= (VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2) + 5) and
                    (xPos <= (row_x + layout_row_width)) and
                    (yPos >= (VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2) + 6)) and
                    (yPos <= column_y + layout_column_height)) and cell8 then

                    if player1 then
                        cross8 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 + 107, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val8 = 1
                    elseif player2 then
                        circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 140, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val8 = 2
                    end

                    cell8 = false           -- setting boolean value to false so that cell does not accept anymore input
                end


                if (xPos >= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2) + 5) and
                    xPos <= (VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2)) and
                    (yPos >= column_y) and
                    (yPos <= VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2))) and cell1 then

                    if player2 then
                        circle1 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 140, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val1 = 2
                    elseif player1 then
                        cross1 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 172, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val1 = 1
                    end

                    cell1 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

                if (xPos >= (VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2) + 5) and
                    xPos <= (row_x + layout_row_width)) and
                    (yPos >= column_y) and
                    (yPos <= VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2)) and cell2 then
                    if player1 then
                        cross2 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 172, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val2 = 1
                    elseif player2 then
                        circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 140, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val2 = 2
                    end

                    cell2 = false           -- setting boolean value to false so that cell does not accept anymore input
                end


                if (xPos <= VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2) and
                        (xPos >= row_x) and (yPos >= (VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2) + 6)) and
                        (yPos <= VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2))) and cell3 then
                    if player1 then
                        cross3 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 33, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val3 = 1
                    elseif player2 then
                        circle3 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val3 = 2
                    end
                    cell3 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

                if (xPos >= row_x and xPos <= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2)) and
                        (yPos >= column_y) and
                        (yPos <= VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2))) and cell0 then

                    if player1 then
                        cross0 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 173, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val0 = 1
                    elseif player2 then
                        circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 140, 38, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player2 = false
                        player1 = true
                        val0 = 2
                    end

                    cell0 = false           -- setting boolean value to false so that cell does not accept anymore input
                end

                if (xPos >= row_x and xPos <= (VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2)) and
                        (yPos >= (VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2) + 6)) and
                        (yPos <= column_y + layout_column_height)) and cell6 then

                    if player1 then
                        cross6 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 + 107, 65, 255 / 255, 255 / 255, 255 / 255, 1)

                        -- switching player turn
                        player1 = false
                        player2 = true
                        val6 = 1
                    elseif player2 then
                        circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 140, 38, 255 / 255, 255 / 255, 255 / 255, 1)

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
                continuation = "Press Enter or Return to continue"
                showPath()

            -- tie function
            elseif (val0 ~= 0 and val1 ~= 0 and val2 ~= 0) and (val3 ~= 0 and val4 ~= 0 and val5 ~= 0) and
                    (val6 ~= 0 and val7 ~= 0 and val8 ~= 0) then
                waitingForInput = true
                continuation = "TIE - Press Enter or Return to continue"
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
    end

end


-- this function deals with the keyboard inputs
function love.keypressed(key)
    if (key == 'enter' or key == 'return') and waitingForInput and player1Score ~= 5 and player2Score ~= 5 then
        waitingForInput = false
        continuation = ""
        serve = ""
        initializeGame()            -- resetting the game

    elseif (key == 'enter' or key == 'return') and (player1Score == 5 or player2Score == 5) then
        player1Score = 0
        player2Score = 0
        waitingForInput = false
        continuation = ""
        serve = ""
        initializeGame()            -- resetting the game
    end
end


function love.draw()

    -- while on startup screen
    if startUp then
        love.graphics.setBackgroundColor(255 / 255, 127 / 255, 80 / 255, 0 / 255)
        buttonLayer1:render()
        buttonLayer2:render()
        buttonLayer1:buttonText()
        buttonLayer2:buttonText()
        buttonLayer2:creator()

    -- while on gameplay screen
    else
        buttonInside1:render()
        buttonInside2:render()
        buttonInside2:buttonText()

        love.graphics.setColor(0, 0, 205 / 255)
        love.graphics.setFont(fonts['titleFont'])
        love.graphics.printf(title, 50, VIRTUAL_WIDTH / 4 - 67, VIRTUAL_HEIGHT / 3 - 32)

        -- player 1 score board
        love.graphics.setColor(0, 0, 205 / 255)
        love.graphics.setFont(fonts['scoreBoardFont'])
        love.graphics.printf("Player 1 | x", VIRTUAL_WIDTH - 167, VIRTUAL_HEIGHT / 2 - 1.4 * layout_gap - (layout_row_height / 2),
            VIRTUAL_HEIGHT / 3 - 32)

        -- player 2 score board
        love.graphics.printf("Player 2 | O", VIRTUAL_WIDTH - 167, VIRTUAL_HEIGHT / 2 + 0.8 * layout_gap - (layout_row_height / 2),
            VIRTUAL_HEIGHT / 3 - 32)

        love.graphics.setFont(fonts['winnerFont'])
        love.graphics.printf(player1Score .. "", VIRTUAL_WIDTH - 67, VIRTUAL_HEIGHT / 2 - 1.1 * layout_gap - (layout_row_height / 2),
            VIRTUAL_HEIGHT / 3 - 32)
        love.graphics.printf(player2Score .. "", VIRTUAL_WIDTH - 67, VIRTUAL_HEIGHT / 2 + 1.1 * layout_gap - (layout_row_height / 2),
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

        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(fonts['winnerFont'])
        love.graphics.printf(string.format("%s",text), 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(0, 0.3, 0.6)
        love.graphics.printf(string.format("%s",text), 0, 12, VIRTUAL_WIDTH, 'center')

        if waitingForInput then
            love.graphics.setFont(fonts['enterFont'])
            love.graphics.printf(string.format("%s",continuation), 10, VIRTUAL_HEIGHT - 35, VIRTUAL_WIDTH, 'center')
        end

        love.graphics.setFont(fonts['enterFont'])
        love.graphics.printf(string.format("%s",serve), 10, VIRTUAL_HEIGHT - 35, VIRTUAL_WIDTH, 'center')
    end
end

-- this function initializes the gameplay screen layout
function initializeGame()

    winnerSound = 0

    -- initializing the grid
    column1 = Layout(VIRTUAL_WIDTH / 2 - layout_gap - (layout_column_width / 2), column_y, layout_column_width, layout_column_height)
    column2 = Layout(VIRTUAL_WIDTH / 2 + layout_gap + (layout_column_width / 2), column_y, layout_column_width, layout_column_height)
    row1 = Layout(row_x, VIRTUAL_HEIGHT / 2 - layout_gap - (layout_row_height / 2), layout_row_width, layout_row_height)
    row2 = Layout(row_x, VIRTUAL_HEIGHT / 2 + layout_gap - (layout_row_height / 2), layout_row_width, layout_row_height)

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
            cross0 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 173, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross1 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 172, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross2 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 172, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val0 == 2 then
            circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle1 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

    elseif (val3 == 1 and val4 == 1 and val5 == 1) or (val3 == 2 and val4 == 2 and val5 == 2) then

        if val3 == 1 then
            cross3 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 33, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross4 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 31, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross5 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 31, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val3 == 2 then
            circle3 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle5 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

    elseif (val6 == 1 and val7 == 1 and val8 == 1) or (val6 == 2 and val7 == 2 and val8 == 2) then

        if val6 == 1 then
            cross6 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 + 107, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross7 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 + 107, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross8 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 + 107, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val6 == 2 then
            circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle7 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 + 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

    elseif (val0 == 1 and val3 == 1 and val6 == 1) or (val0 == 2 and val3 == 2 and val6 == 2) then

        if val3 == 1 then
            cross0 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 173, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross3 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 33, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross6 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 + 107, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val3 == 2 then
            circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle3 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

    elseif (val1 == 1 and val4 == 1 and val7 == 1) or (val1 == 2 and val4 == 2 and val7 == 2) then

        if val4 == 1 then
            cross1 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 172, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross4 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 31, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross7 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 + 107, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val4 == 2 then
            circle1 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle7 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 + 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

    elseif (val2 == 1 and val5 == 1 and val8 == 1) or (val2 == 2 and val5 == 2 and val8 == 2) then

        if val5 == 1 then
            cross2 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 172, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross5 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 31, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross8 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 + 107, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val5 == 2 then
            circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle5 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

    elseif (val0 == 1 and val4 == 1 and val8 == 1) or (val0 == 2 and val4 == 2 and val8 == 2) then

        if val8 == 1 then
            cross0 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 - 173, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross4 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 31, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross8 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 + 107, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val8 == 2 then
            circle0 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 - 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle8 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 + 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

    elseif (val2 == 1 and val4 == 1 and val6 == 1) or (val2 == 2 and val4 == 2 and val6 == 2) then

        if val6 == 1 then
            cross2 = Cross(VIRTUAL_WIDTH / 3 + 274, VIRTUAL_HEIGHT / 2 - 172, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross4 = Cross(VIRTUAL_WIDTH / 3 + 128, VIRTUAL_HEIGHT / 2 - 31, 65, 120 / 255, 248 / 255, 205 / 255, 1)
            cross6 = Cross(VIRTUAL_WIDTH / 3 - 18, VIRTUAL_HEIGHT / 2 + 107, 65, 120 / 255, 248 / 255, 205 / 255, 1)
        elseif val6 == 2 then
            circle2 = Circle('line', VIRTUAL_WIDTH / 2 + 146, VIRTUAL_HEIGHT / 2 - 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle4 = Circle('line', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 38, 120 / 255, 248 / 255, 205 / 255, 1)
            circle6 = Circle('line', VIRTUAL_WIDTH / 2 - 146, VIRTUAL_HEIGHT / 2 + 140, 38, 120 / 255, 248 / 255, 205 / 255, 1)
        end

    end
end