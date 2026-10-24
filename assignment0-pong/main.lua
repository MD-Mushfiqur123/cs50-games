-- CS50 Games (2018) - Assignment 0: Pong
-- AI Paddle Implementation

push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Pong - CS50G Assignment 0')

    math.randomseed(os.time())

    -- Retro-style default font
    smallFont = love.graphics.newFont(8)
    largeFont = love.graphics.newFont(16)
    scoreFont = love.graphics.newFont(32)
    love.graphics.setFont(smallFont)

    -- Sound table (generated procedurally if assets not present)
    sounds = {}

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 50, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    player1Score = 0
    player2Score = 0

    servingPlayer = 1
    winningPlayer = 0

    -- Game modes: 'two_player' or 'ai'
    -- CS50 Assignment 0 requirement: Player 2 (or either player) controlled by AI
    gameMode = 'ai'

    gameState = 'start'

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        -- Collision with Player 1
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        -- Collision with Player 2
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        -- Collision with top and bottom bounds
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end

        -- Scoring
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1

            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1

            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    -- Player 1 Input (Human)
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- Player 2 Control (AI or Human)
    -- ==========================================
    -- CS50G ASSIGNMENT 0: AI CONTROLLED PADDLE
    -- ==========================================
    if gameMode == 'ai' then
        -- AI tracks the ball's Y position to keep center of paddle aligned with ball
        local paddleCenter = player2.y + player2.height / 2
        local ballCenter = ball.y + ball.height / 2
        local deadzone = 4 -- Prevent jitter when aligned

        if gameState == 'play' then
            -- Optional optimization: only react when ball is moving towards AI or in center
            if ballCenter < paddleCenter - deadzone then
                player2.dy = -PADDLE_SPEED
            elseif ballCenter > paddleCenter + deadzone then
                player2.dy = PADDLE_SPEED
            else
                player2.dy = 0
            end
        else
            player2.dy = 0
        end
    else
        -- Human Player 2
        if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
        end
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    elseif key == 'tab' then
        -- Toggle between AI and 2-Player mode
        if gameMode == 'ai' then
            gameMode = 'human'
        else
            gameMode = 'ai'
        end
    end
end

function love.draw()
    push:start()

    love.graphics.clear(40/255, 45/255, 52/255, 1)

    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Mode: [' .. string.upper(gameMode) .. '] (Press TAB to toggle AI)', 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- Gameplay screen
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- Render scores
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    -- Render paddles and ball
    player1:render()
    player2:render()
    ball:render()

    -- Render net
    love.graphics.setLineWidth(1)
    for y = 0, VIRTUAL_HEIGHT, 10 do
        love.graphics.line(VIRTUAL_WIDTH / 2, y, VIRTUAL_WIDTH / 2, y + 5)
    end

    displayFPS()

    push:finish()
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end
