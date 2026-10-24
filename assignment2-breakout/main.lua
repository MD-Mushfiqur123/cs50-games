-- CS50 Games - Assignment 2: Breakout
-- Requirements:
-- 1. Locked Brick (cannot be broken without key pickup)
-- 2. Powerups: Key Powerup + Multi-Ball Powerup (spawns 2 extra balls)
-- 3. Paddle growth on score milestone / Paddle shrinkage penalty on losing a ball/life

push = require 'push'
Class = require 'class'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Brick Class
Brick = Class{}
function Brick:init(x, y, tier, color, isLocked)
    self.x = x
    self.y = y
    self.width = 32
    self.height = 16
    self.tier = tier or 1
    self.color = color or 1
    self.isLocked = isLocked or false
    self.inPlay = true
end

function Brick:hit(hasKey)
    if self.isLocked then
        if hasKey then
            self.isLocked = false
            self.inPlay = false
            return 2500, true -- High bonus for unlocking brick
        else
            return 0, false -- Cannot destroy without key
        end
    else
        self.inPlay = false
        return self.tier * 200 + self.color * 25, false
    end
end

function Brick:render()
    if not self.inPlay then return end

    if self.isLocked then
        -- Gold / Bronze Metallic brick with lock icon
        love.graphics.setColor(0.85, 0.65, 0.13, 1)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 2, 2)
        -- Keyhole icon
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
        love.graphics.circle('fill', self.x + self.width/2, self.y + 6, 2.5)
        love.graphics.rectangle('fill', self.x + self.width/2 - 1, self.y + 7, 2, 5)
    else
        local palette = {
            {0.39, 0.61, 1},   -- Blue
            {0.42, 0.75, 0.18}, -- Green
            {0.85, 0.25, 0.2},  -- Red
            {0.78, 0.48, 0.9},  -- Purple
            {0.95, 0.6, 0.07}   -- Orange
        }
        local c = palette[((self.color - 1) % #palette) + 1]
        love.graphics.setColor(c[1], c[2], c[3], 1)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 2, 2)
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.line(self.x, self.y, self.x + self.width, self.y)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Powerup Class (Key and Multi-Ball)
Powerup = Class{}
function Powerup:init(x, y, pType)
    self.x = x
    self.y = y
    self.width = 16
    self.height = 16
    self.type = pType -- 'multiball' or 'key'
    self.dy = 50
    self.inPlay = true
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
    if self.y > VIRTUAL_HEIGHT then
        self.inPlay = false
    end
end

function Powerup:collides(paddle)
    return not (self.x + self.width < paddle.x or self.x > paddle.x + paddle.width or
                self.y + self.height < paddle.y or self.y > paddle.y + paddle.height)
end

function Powerup:render()
    if not self.inPlay then return end
    if self.type == 'key' then
        -- Gold glowing key
        love.graphics.setColor(1, 0.85, 0.1, 1)
        love.graphics.circle('line', self.x + 8, self.y + 5, 4)
        love.graphics.line(self.x + 8, self.y + 9, self.x + 8, self.y + 15)
        love.graphics.line(self.x + 8, self.y + 12, self.x + 11, self.y + 12)
        love.graphics.line(self.x + 8, self.y + 15, self.x + 11, self.y + 15)
    else
        -- Blue glowing double/triple ball icon
        love.graphics.setColor(0.2, 0.8, 1, 1)
        love.graphics.circle('fill', self.x + 5, self.y + 6, 3)
        love.graphics.circle('fill', self.x + 11, self.y + 6, 3)
        love.graphics.circle('fill', self.x + 8, self.y + 11, 3)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Paddle Class with dynamic resizing
Paddle = Class{}
function Paddle:init()
    self.size = 2 -- 1: Small (32), 2: Medium (64), 3: Large (96), 4: Giant (128)
    self.widths = {32, 64, 96, 128}
    self.width = self.widths[self.size]
    self.height = 12
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT - 24
    self.dx = 0
    self.speed = 240
end

function Paddle:grow()
    self.size = math.min(4, self.size + 1)
    local oldWidth = self.width
    self.width = self.widths[self.size]
    self.x = self.x - (self.width - oldWidth) / 2
end

function Paddle:shrink()
    self.size = math.max(1, self.size - 1)
    local oldWidth = self.width
    self.width = self.widths[self.size]
    self.x = self.x + (oldWidth - self.width) / 2
end

function Paddle:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
        self.dx = -self.speed
    elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
        self.dx = self.speed
    else
        self.dx = 0
    end
    self.x = math.max(0, math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt))
end

function Paddle:render()
    love.graphics.setColor(0.3, 0.7, 0.9, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 4, 4)
    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height, 4, 4)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Ball Class
Ball = Class{}
function Ball:init(x, y)
    self.width = 8
    self.height = 8
    self.x = x or (VIRTUAL_WIDTH / 2 - 4)
    self.y = y or (VIRTUAL_HEIGHT - 34)
    self.dx = math.random(-80, 80)
    self.dy = -140
    self.inPlay = true
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- Left/Right boundary
    if self.x <= 0 then
        self.x = 0
        self.dx = -self.dx
    elseif self.x >= VIRTUAL_WIDTH - self.width then
        self.x = VIRTUAL_WIDTH - self.width
        self.dx = -self.dx
    end

    -- Top boundary
    if self.y <= 0 then
        self.y = 0
        self.dy = -self.dy
    end

    -- Bottom boundary (loss)
    if self.y > VIRTUAL_HEIGHT then
        self.inPlay = false
    end
end

function Ball:collides(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                self.y + self.height < target.y or self.y > target.y + target.height)
end

function Ball:render()
    if not self.inPlay then return end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle('fill', self.x + 4, self.y + 4, 4)
end

-- Game State Management
local paddle, balls, bricks, powerups
local score, lives, hasKey, level
local gameState, powerupTimer

function initLevel()
    bricks = {}
    local rows = 4
    local cols = 10
    local startX = 24
    local startY = 30
    local hasLockedBrick = false

    for r = 1, rows do
        for c = 1, cols do
            local isLocked = false
            -- Place a locked brick in row 1 or 2
            if not hasLockedBrick and r == 2 and c == 5 then
                isLocked = true
                hasLockedBrick = true
            end
            table.insert(bricks, Brick(startX + (c - 1) * 38, startY + (r - 1) * 20, 1, r, isLocked))
        end
    end
end

function resetBall()
    balls = { Ball(paddle.x + paddle.width/2 - 4, paddle.y - 10) }
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Breakout - CS50G Assignment 2')
    math.randomseed(os.time())

    smallFont = love.graphics.newFont(10)
    scoreFont = love.graphics.newFont(16)
    largeFont = love.graphics.newFont(24)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    score = 0
    lives = 3
    level = 1
    hasKey = false
    paddle = Paddle()
    powerups = {}
    powerupTimer = 0
    initLevel()
    resetBall()
    gameState = 'serve'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'space' or key == 'return' or key == 'enter' then
        if gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'gameover' or gameState == 'victory' then
            score = 0
            lives = 3
            level = 1
            hasKey = false
            paddle = Paddle()
            initLevel()
            resetBall()
            gameState = 'serve'
        end
    end
end

function love.update(dt)
    if gameState == 'serve' then
        paddle:update(dt)
        balls[1].x = paddle.x + paddle.width / 2 - 4
        balls[1].y = paddle.y - 10
        return
    end

    if gameState ~= 'play' then return end

    paddle:update(dt)

    -- Randomly spawn powerups
    powerupTimer = powerupTimer + dt
    if powerupTimer > 9 then
        powerupTimer = 0
        local pType = (not hasKey and math.random(2) == 1) and 'key' or 'multiball'
        table.insert(powerups, Powerup(math.random(30, VIRTUAL_WIDTH - 30), 20, pType))
    end

    -- Update powerups & check paddle collection
    for i = #powerups, 1, -1 do
        local p = powerups[i]
        p:update(dt)
        if p:collides(paddle) then
            if p.type == 'key' then
                hasKey = true
            elseif p.type == 'multiball' then
                -- CS50 Requirement: Spawn 2 extra balls
                local b1 = Ball(paddle.x + paddle.width/2 - 4, paddle.y - 10)
                b1.dx = math.random(-150, -50)
                b1.dy = -150
                local b2 = Ball(paddle.x + paddle.width/2 - 4, paddle.y - 10)
                b2.dx = math.random(50, 150)
                b2.dy = -150
                table.insert(balls, b1)
                table.insert(balls, b2)
            end
            table.remove(powerups, i)
        elseif not p.inPlay then
            table.remove(powerups, i)
        end
    end

    -- Update balls and handle collisions
    for i = #balls, 1, -1 do
        local b = balls[i]
        b:update(dt)

        -- Ball Paddle Collision with angle deflection
        if b:collides(paddle) and b.dy > 0 then
            b.dy = -b.dy
            b.y = paddle.y - b.height
            -- Deflection based on offset from center
            local hitOffset = (b.x + b.width / 2) - (paddle.x + paddle.width / 2)
            b.dx = hitOffset * 7 + math.random(-10, 10)
        end

        -- Ball Brick Collisions
        for _, brick in ipairs(bricks) do
            if brick.inPlay and b:collides(brick) then
                local pts, unlocked = brick:hit(hasKey)
                score = score + pts

                -- Paddle growth on score milestone
                if score >= 3000 and paddle.size < 3 then
                    paddle:grow()
                elseif score >= 7000 and paddle.size < 4 then
                    paddle:grow()
                end

                -- Collision resolution
                if b.x + 2 < brick.x and b.dx > 0 then
                    b.dx = -b.dx
                    b.x = brick.x - b.width
                elseif b.x + b.width - 2 > brick.x + brick.width and b.dx < 0 then
                    b.dx = -b.dx
                    b.x = brick.x + brick.width
                elseif b.y < brick.y then
                    b.dy = -b.dy
                    b.y = brick.y - b.height
                else
                    b.dy = -b.dy
                    b.y = brick.y + brick.height
                end
                break
            end
        end

        if not b.inPlay then
            table.remove(balls, i)
        end
    end

    -- If all balls lost
    if #balls == 0 then
        lives = lives - 1
        -- CS50 Requirement: Paddle shrinkage penalty upon losing a life/ball
        paddle:shrink()

        if lives == 0 then
            gameState = 'gameover'
        else
            resetBall()
            gameState = 'serve'
        end
    end

    -- Check win condition
    local remaining = 0
    for _, br in ipairs(bricks) do
        if br.inPlay then remaining = remaining + 1 end
    end
    if remaining == 0 then
        gameState = 'victory'
    end
end

function love.draw()
    push:start()
    love.graphics.clear(25/255, 30/255, 42/255, 1)

    -- Render Bricks
    for _, br in ipairs(bricks) do
        br:render()
    end

    -- Render Powerups
    for _, p in ipairs(powerups) do
        p:render()
    end

    -- Render Paddle and Balls
    paddle:render()
    for _, b in ipairs(balls) do
        b:render()
    end

    -- Render HUD
    love.graphics.setFont(scoreFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('Score: ' .. tostring(score), 10, 8)

    -- Hearts for lives
    love.graphics.print('Lives: ', VIRTUAL_WIDTH - 120, 8)
    for i = 1, lives do
        love.graphics.setColor(1, 0.2, 0.3, 1)
        love.graphics.circle('fill', VIRTUAL_WIDTH - 70 + (i * 12), 16, 4)
    end
    love.graphics.setColor(1, 1, 1, 1)

    -- Key Status
    if hasKey then
        love.graphics.setColor(1, 0.85, 0.1, 1)
        love.graphics.print('[KEY ACTIVE]', VIRTUAL_WIDTH / 2 - 40, 8)
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- State overlays
    if gameState == 'serve' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Press Space to Serve!', 0, VIRTUAL_HEIGHT / 2 + 10, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'gameover' then
        love.graphics.setFont(largeFont)
        love.graphics.setColor(1, 0.3, 0.3, 1)
        love.graphics.printf('GAME OVER', 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf('Press Space to Restart', 0, VIRTUAL_HEIGHT / 2 + 15, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(largeFont)
        love.graphics.setColor(0.3, 1, 0.4, 1)
        love.graphics.printf('VICTORY!', 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf('Press Space to Play Again', 0, VIRTUAL_HEIGHT / 2 + 15, VIRTUAL_WIDTH, 'center')
    end

    push:finish()
end
