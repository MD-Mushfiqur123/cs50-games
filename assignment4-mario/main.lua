-- CS50 Games - Assignment 4: Super Mario Bros.
-- Requirements:
-- 1. Jumping physics with gravity and ground collision
-- 2. Procedural level generation with chasms, hills, and bushes
-- 3. Key Block & Lock Block mechanic (unlocking Lock Block spawns Goal Post / Flag)
-- 4. Gem pickups with score
-- 5. Flagpole collision triggers next level / victory

push = require 'push'
Class = require 'class'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 256
VIRTUAL_HEIGHT = 144

TILE_SIZE = 16
LEVEL_WIDTH = 100

-- Tile IDs
TILE_EMPTY = 0
TILE_GROUND = 1
TILE_GRASS = 2

-- Game Object Types
OBJ_KEY = 1
OBJ_LOCK = 2
OBJ_GEM = 3
OBJ_FLAG = 4

GameObject = Class{}
function GameObject:init(params)
    self.type = params.type
    self.x = params.x
    self.y = params.y
    self.width = params.width or 16
    self.height = params.height or 16
    self.consumed = false
    self.solid = params.solid or false
end

function GameObject:render()
    if self.consumed then return end
    if self.type == OBJ_KEY then
        -- Gold Key
        love.graphics.setColor(1, 0.85, 0.1, 1)
        love.graphics.circle('line', self.x + 6, self.y + 6, 4)
        love.graphics.line(self.x + 10, self.y + 6, self.x + 15, self.y + 6)
        love.graphics.line(self.x + 13, self.y + 6, self.x + 13, self.y + 10)
    elseif self.type == OBJ_LOCK then
        -- Lock Block
        love.graphics.setColor(0.7, 0.5, 0.2, 1)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 2, 2)
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
        love.graphics.circle('fill', self.x + 8, self.y + 6, 3)
        love.graphics.rectangle('fill', self.x + 7, self.y + 8, 2, 4)
    elseif self.type == OBJ_GEM then
        -- Sparkling Gem
        local pulse = math.sin(love.timer.getTime() * 10) * 0.2 + 0.8
        love.graphics.setColor(0.2 * pulse, 0.9 * pulse, 1 * pulse, 1)
        love.graphics.polygon('fill',
            self.x + 8, self.y + 2,
            self.x + 14, self.y + 8,
            self.x + 8, self.y + 14,
            self.x + 2, self.y + 8
        )
    elseif self.type == OBJ_FLAG then
        -- Flag pole and victory flag
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.rectangle('fill', self.x + 2, self.y - 32, 2, 48)
        love.graphics.setColor(0.1, 0.8, 0.2, 1)
        love.graphics.polygon('fill',
            self.x + 4, self.y - 32,
            self.x + 20, self.y - 24,
            self.x + 4, self.y - 16
        )
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Player Class
Player = Class{}
function Player:init(x, y)
    self.x = x
    self.y = y
    self.width = 12
    self.height = 14
    self.dx = 0
    self.dy = 0
    self.speed = 100
    self.gravity = 600
    self.jumpVelocity = -220
    self.grounded = false
    self.hasKey = false
    self.score = 0
    self.direction = 'right'
end

function Player:update(dt, level)
    -- Horizontal movement
    if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
        self.dx = -self.speed
        self.direction = 'left'
    elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
        self.dx = self.speed
        self.direction = 'right'
    else
        self.dx = 0
    end

    -- Jumping
    if (love.keyboard.wasPressed('space') or love.keyboard.wasPressed('w') or love.keyboard.wasPressed('up')) and self.grounded then
        self.dy = self.jumpVelocity
        self.grounded = false
    end

    -- Apply Gravity
    self.dy = self.dy + self.gravity * dt

    -- Update X
    self.x = self.x + self.dx * dt
    self:checkHorizontalCollisions(level)

    -- Update Y
    self.y = self.y + self.dy * dt
    self:checkVerticalCollisions(level)

    -- Bottom chasm death
    if self.y > VIRTUAL_HEIGHT + 32 then
        return 'die'
    end

    return 'alive'
end

function Player:checkHorizontalCollisions(level)
    local tileLeft = math.floor(self.x / TILE_SIZE) + 1
    local tileRight = math.floor((self.x + self.width - 1) / TILE_SIZE) + 1
    local tileTop = math.floor(self.y / TILE_SIZE) + 1
    local tileBottom = math.floor((self.y + self.height - 1) / TILE_SIZE) + 1

    if self.dx < 0 then
        if level:isSolid(tileLeft, tileTop) or level:isSolid(tileLeft, tileBottom) then
            self.x = tileLeft * TILE_SIZE
            self.dx = 0
        end
    elseif self.dx > 0 then
        if level:isSolid(tileRight, tileTop) or level:isSolid(tileRight, tileBottom) then
            self.x = (tileRight - 1) * TILE_SIZE - self.width
            self.dx = 0
        end
    end
end

function Player:checkVerticalCollisions(level)
    local tileLeft = math.floor(self.x / TILE_SIZE) + 1
    local tileRight = math.floor((self.x + self.width - 1) / TILE_SIZE) + 1
    local tileTop = math.floor(self.y / TILE_SIZE) + 1
    local tileBottom = math.floor((self.y + self.height - 1) / TILE_SIZE) + 1

    if self.dy > 0 then
        if level:isSolid(tileLeft, tileBottom) or level:isSolid(tileRight, tileBottom) then
            self.y = (tileBottom - 1) * TILE_SIZE - self.height
            self.dy = 0
            self.grounded = true
        else
            self.grounded = false
        end
    elseif self.dy < 0 then
        if level:isSolid(tileLeft, tileTop) or level:isSolid(tileRight, tileTop) then
            self.y = tileTop * TILE_SIZE
            self.dy = 0
        end
    end
end

function Player:render()
    -- Retro Mario-styled character
    love.graphics.setColor(0.9, 0.15, 0.15, 1) -- Red shirt/hat
    love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y), self.width, self.height)
    love.graphics.setColor(0.1, 0.2, 0.85, 1) -- Blue overalls
    love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y + 8), self.width, 6)
    love.graphics.setColor(1, 0.8, 0.6, 1) -- Face
    local faceOffset = (self.direction == 'right') and 6 or 0
    love.graphics.rectangle('fill', math.floor(self.x + faceOffset), math.floor(self.y + 2), 6, 5)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Level Generator
Level = Class{}
function Level:init(width)
    self.width = width
    self.height = math.floor(VIRTUAL_HEIGHT / TILE_SIZE)
    self.tiles = {}
    self.objects = {}
    self.lockBlock = nil
    self.flag = nil
    self:generate()
end

function Level:generate()
    for y = 1, self.height do
        self.tiles[y] = {}
        for x = 1, self.width do
            self.tiles[y][x] = TILE_EMPTY
        end
    end

    local groundLevel = self.height - 2

    for x = 1, self.width do
        -- Chasms (random pits)
        if x > 5 and x < self.width - 10 and math.random(8) == 1 then
            -- Chasm pit (empty)
        else
            self.tiles[groundLevel][x] = TILE_GRASS
            for y = groundLevel + 1, self.height do
                self.tiles[y][x] = TILE_GROUND
            end

            -- Gems
            if math.random(5) == 1 then
                table.insert(self.objects, GameObject{
                    type = OBJ_GEM,
                    x = (x - 1) * TILE_SIZE + 4,
                    y = (groundLevel - 2) * TILE_SIZE
                })
            end
        end
    end

    -- Key Block & Lock Block placement
    local keyX = math.random(15, 30)
    table.insert(self.objects, GameObject{
        type = OBJ_KEY,
        x = (keyX - 1) * TILE_SIZE,
        y = (groundLevel - 3) * TILE_SIZE
    })

    local lockX = math.random(35, 55)
    self.lockBlock = GameObject{
        type = OBJ_LOCK,
        x = (lockX - 1) * TILE_SIZE,
        y = (groundLevel - 3) * TILE_SIZE,
        solid = true
    }
    table.insert(self.objects, self.lockBlock)
end

function Level:spawnFlag()
    -- Spawns goal flag post at end of level after lock block is unlocked
    local flagX = (self.width - 5) * TILE_SIZE
    local flagY = (self.height - 2) * TILE_SIZE
    self.flag = GameObject{
        type = OBJ_FLAG,
        x = flagX,
        y = flagY
    }
    table.insert(self.objects, self.flag)
end

function Level:isSolid(x, y)
    if x < 1 or x > self.width or y < 1 or y > self.height then
        return false
    end
    return self.tiles[y][x] ~= TILE_EMPTY
end

function Level:render(cameraX)
    -- Tiles
    for y = 1, self.height do
        for x = 1, self.width do
            local t = self.tiles[y][x]
            local drawX = (x - 1) * TILE_SIZE - cameraX
            local drawY = (y - 1) * TILE_SIZE

            if t == TILE_GRASS then
                love.graphics.setColor(0.3, 0.75, 0.2, 1)
                love.graphics.rectangle('fill', drawX, drawY, TILE_SIZE, TILE_SIZE)
                love.graphics.setColor(0.4, 0.85, 0.3, 1)
                love.graphics.rectangle('fill', drawX, drawY, TILE_SIZE, 3)
            elseif t == TILE_GROUND then
                love.graphics.setColor(0.55, 0.35, 0.15, 1)
                love.graphics.rectangle('fill', drawX, drawY, TILE_SIZE, TILE_SIZE)
            end
        end
    end

    -- Objects
    for _, obj in ipairs(self.objects) do
        local oldX = obj.x
        obj.x = obj.x - cameraX
        obj:render()
        obj.x = oldX
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Game Lifecycle
local player, level, cameraX, gameState
local currentLevel = 1
local keysPressed = {}

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Super Mario - CS50G Assignment 4')
    math.randomseed(os.time())

    font = love.graphics.newFont(10)
    bigFont = love.graphics.newFont(16)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    startNewGame()
end

function startNewGame()
    currentLevel = 1
    loadLevel()
end

function loadLevel()
    level = Level(LEVEL_WIDTH)
    player = Player(20, (level.height - 4) * TILE_SIZE)
    cameraX = 0
    gameState = 'play'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    keysPressed[key] = true
    if key == 'escape' then
        love.event.quit()
    elseif (key == 'return' or key == 'space') and (gameState == 'gameover' or gameState == 'victory') then
        startNewGame()
    end
end

function love.keyboard.wasPressed(key)
    return keysPressed[key] == true
end

function love.update(dt)
    if gameState == 'play' then
        local status = player:update(dt, level)
        if status == 'die' then
            gameState = 'gameover'
        end

        -- Camera follows player centered horizontally
        cameraX = math.max(0, math.min(player.x - VIRTUAL_WIDTH / 2 + player.width / 2, (level.width * TILE_SIZE) - VIRTUAL_WIDTH))

        -- Object collisions
        for _, obj in ipairs(level.objects) do
            if not obj.consumed then
                if player.x < obj.x + obj.width and player.x + player.width > obj.x and
                   player.y < obj.y + obj.height and player.y + player.height > obj.y then

                    if obj.type == OBJ_KEY then
                        obj.consumed = true
                        player.hasKey = true
                        player.score = player.score + 500
                    elseif obj.type == OBJ_LOCK and player.hasKey then
                        obj.consumed = true
                        player.hasKey = false
                        player.score = player.score + 1000
                        -- CS50 Requirement: Unlocking lock block spawns flagpole!
                        level:spawnFlag()
                    elseif obj.type == OBJ_GEM then
                        obj.consumed = true
                        player.score = player.score + 100
                    elseif obj.type == OBJ_FLAG then
                        gameState = 'victory'
                    end
                end
            end
        end
    end

    keysPressed = {}
end

function love.draw()
    push:start()

    -- Sky background
    love.graphics.setColor(108/255, 140/255, 255/255, 1)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    -- Background clouds
    love.graphics.setColor(1, 1, 1, 0.4)
    for i = 0, 10 do
        love.graphics.circle('fill', (i * 120 - cameraX * 0.2) % (VIRTUAL_WIDTH + 100), 25, 20)
    end

    -- Render Level and Player
    level:render(cameraX)

    local oldPX = player.x
    player.x = player.x - cameraX
    player:render()
    player.x = oldPX

    -- HUD
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('Score: ' .. tostring(player.score), 8, 6)
    love.graphics.print('Level: ' .. tostring(currentLevel), 80, 6)

    if player.hasKey then
        love.graphics.setColor(1, 0.85, 0.1, 1)
        love.graphics.print('[KEY READY]', 130, 6)
        love.graphics.setColor(1, 1, 1, 1)
    end

    if gameState == 'gameover' then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        love.graphics.setFont(bigFont)
        love.graphics.setColor(1, 0.3, 0.3, 1)
        love.graphics.printf('GAME OVER', 0, 50, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(font)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf('Press Space to Restart', 0, 80, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        love.graphics.setFont(bigFont)
        love.graphics.setColor(0.3, 1, 0.4, 1)
        love.graphics.printf('LEVEL COMPLETE!', 0, 50, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(font)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf('Press Space to Play Next Level', 0, 80, VIRTUAL_WIDTH, 'center')
    end

    push:finish()
end
