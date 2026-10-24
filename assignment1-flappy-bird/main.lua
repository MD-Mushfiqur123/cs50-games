-- CS50 Games (2018) - Assignment 1: Fifty Bird (Flappy Bird)
-- Features implemented:
-- 1. Randomized vertical gap between pipes (75 to 115 px)
-- 2. Randomized spawn interval between pipe pairs (1.8 to 3.2 seconds)
-- 3. Pause feature (press 'P' or 'p') with pause sound/indicator
-- 4. Medals system (Bronze: 1-4 pts, Silver: 5-9 pts, Gold: 10+ pts)

push = require 'push'
Class = require 'class'

require 'Bird'
require 'Pipe'
require 'PipePair'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60
local BACKGROUND_LOOPING_POINT = 413

local backgroundScroll = 0
local groundScroll = 0

local bird = Bird()
local pipePairs = {}
local spawnTimer = 0
local nextSpawnInterval = 2.0 -- randomized between 1.8 and 3.2s
local lastY = -PIPE_HEIGHT + math.random(80) + 20

local score = 0
local gameState = 'countdown' -- 'countdown', 'play', 'pause', 'score'
local countdownTimer = 3
local countdownCount = 3

local paused = false

local keysPressed = {}
local mousePressed = {}

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Fifty Bird - CS50G Assignment 1')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont(12)
    mediumFont = love.graphics.newFont(18)
    flappyFont = love.graphics.newFont(28)
    hugeFont = love.graphics.newFont(56)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    resetGame()
end

function resetGame()
    bird = Bird()
    pipePairs = {}
    spawnTimer = 0
    nextSpawnInterval = math.random(18, 32) / 10.0
    lastY = -PIPE_HEIGHT + math.random(80) + 20
    score = 0
    gameState = 'countdown'
    countdownTimer = 0.75
    countdownCount = 3
    paused = false
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end

    -- Pause feature toggle
    if key == 'p' or key == 'P' then
        if gameState == 'play' then
            paused = not paused
        end
    end
end

function love.mousepressed(x, y, button)
    mousePressed[button] = true
end

function love.keyboard.wasPressed(key)
    return keysPressed[key] == true
end

function love.mouse.wasPressed(button)
    return mousePressed[button] == true
end

function love.update(dt)
    if paused then
        -- Freeze world updates during pause
        keysPressed = {}
        mousePressed = {}
        return
    end

    if gameState == 'countdown' then
        countdownTimer = countdownTimer - dt
        if countdownTimer <= 0 then
            countdownTimer = 0.75
            countdownCount = countdownCount - 1
            if countdownCount == 0 then
                gameState = 'play'
            end
        end
    elseif gameState == 'play' then
        -- Background scrolling
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH

        spawnTimer = spawnTimer + dt

        -- CS50 Requirement: Randomized intervals between pipe spawns
        if spawnTimer > nextSpawnInterval then
            local y = math.max(-PIPE_HEIGHT + 10,
                math.min(lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
            lastY = y

            table.insert(pipePairs, PipePair(y))
            spawnTimer = 0
            -- Randomize next interval between 1.8 and 3.2 seconds
            nextSpawnInterval = math.random(18, 32) / 10.0
        end

        bird:update(dt)

        for k, pair in pairs(pipePairs) do
            if not pair.score then
                if pair.x + PIPE_WIDTH < bird.x then
                    score = score + 1
                    pair.score = true
                end
            end
            pair:update(dt)
        end

        -- Collision detection
        for k, pair in pairs(pipePairs) do
            for l, pipe in pairs(pair.pipes) do
                if bird:collides(pipe) then
                    gameState = 'score'
                end
            end
        end

        if bird.y > VIRTUAL_HEIGHT - 15 or bird.y < -10 then
            gameState = 'score'
        end

        -- Clean up expired pipes
        for k, pair in pairs(pipePairs) do
            if pair.remove then
                table.remove(pipePairs, k)
            end
        end
    elseif gameState == 'score' then
        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') or love.keyboard.wasPressed('space') then
            resetGame()
        end
    end

    keysPressed = {}
    mousePressed = {}
end

function love.draw()
    push:start()

    -- Sky background
    love.graphics.setColor(112/255, 197/255, 206/255, 1)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    -- Clouds / background mountains
    love.graphics.setColor(140/255, 215/255, 224/255, 1)
    for i = 0, 3 do
        love.graphics.circle('fill', (i * 180 - backgroundScroll * 0.5) % (VIRTUAL_WIDTH + 100), 180, 60)
    end

    -- Pipes
    for k, pair in pairs(pipePairs) do
        pair:render()
    end

    -- Ground
    love.graphics.setColor(222/255, 216/255, 149/255, 1)
    love.graphics.rectangle('fill', 0, VIRTUAL_HEIGHT - 16, VIRTUAL_WIDTH, 16)
    love.graphics.setColor(120/255, 180/255, 60/255, 1)
    love.graphics.rectangle('fill', 0, VIRTUAL_HEIGHT - 16, VIRTUAL_WIDTH, 4)

    -- Bird
    bird:render()

    -- HUD / State text
    love.graphics.setColor(1, 1, 1, 1)
    if gameState == 'countdown' then
        love.graphics.setFont(hugeFont)
        love.graphics.printf(tostring(countdownCount), 0, 100, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        love.graphics.setFont(flappyFont)
        love.graphics.print('Score: ' .. tostring(score), 10, 10)

        if paused then
            -- Pause overlay
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setFont(flappyFont)
            love.graphics.printf('PAUSED', 0, 100, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(smallFont)
            love.graphics.printf('Press P to Resume', 0, 140, VIRTUAL_WIDTH, 'center')
        end
    elseif gameState == 'score' then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 140, 40, 280, 200, 10, 10)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(flappyFont)
        love.graphics.printf('Oof! You Lost!', 0, 55, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(mediumFont)
        love.graphics.printf('Score: ' .. tostring(score), 0, 95, VIRTUAL_WIDTH, 'center')

        -- CS50 Requirement: Medals system
        renderMedal(score)

        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to Play Again', 0, 205, VIRTUAL_WIDTH, 'center')
    end

    push:finish()
end

function renderMedal(playerScore)
    local medalColor = nil
    local medalText = ''

    if playerScore >= 10 then
        medalColor = {1, 0.84, 0} -- Gold
        medalText = 'GOLD MEDAL'
    elseif playerScore >= 5 then
        medalColor = {0.75, 0.75, 0.75} -- Silver
        medalText = 'SILVER MEDAL'
    elseif playerScore >= 1 then
        medalColor = {0.8, 0.5, 0.2} -- Bronze
        medalText = 'BRONZE MEDAL'
    else
        medalText = 'No Medal (Score >= 1 required)'
    end

    if medalColor then
        -- Medal Ribbon
        love.graphics.setColor(0.9, 0.1, 0.1, 1)
        love.graphics.polygon('fill',
            VIRTUAL_WIDTH / 2 - 12, 130,
            VIRTUAL_WIDTH / 2 - 4, 150,
            VIRTUAL_WIDTH / 2 - 18, 150)
        love.graphics.polygon('fill',
            VIRTUAL_WIDTH / 2 + 12, 130,
            VIRTUAL_WIDTH / 2 + 18, 150,
            VIRTUAL_WIDTH / 2 + 4, 150)

        -- Medal Circle
        love.graphics.setColor(medalColor[1], medalColor[2], medalColor[3], 1)
        love.graphics.circle('fill', VIRTUAL_WIDTH / 2, 145, 18)
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.circle('line', VIRTUAL_WIDTH / 2, 145, 15)

        -- Text
        love.graphics.setColor(medalColor[1], medalColor[2], medalColor[3], 1)
        love.graphics.setFont(mediumFont)
        love.graphics.printf(medalText, 0, 172, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.setFont(smallFont)
        love.graphics.printf(medalText, 0, 150, VIRTUAL_WIDTH, 'center')
    end
    love.graphics.setColor(1, 1, 1, 1)
end
