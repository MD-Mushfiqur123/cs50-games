-- CS50 Games - Assignment 5: The Legend of Zelda
-- Requirements:
-- 1. Pot lifting & carrying above player's head
-- 2. Pot throwing mechanics (travels in facing direction, collides with wall/enemy, shatters)
-- 3. Room transitions through doorways
-- 4. Enemy AI patrolling and attacking

push = require 'push'
Class = require 'class'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

MAP_WIDTH = 22
MAP_HEIGHT = 12
TILE_SIZE = 16

ROOM_OFFSET_X = (VIRTUAL_WIDTH - (MAP_WIDTH * TILE_SIZE)) / 2
ROOM_OFFSET_Y = (VIRTUAL_HEIGHT - (MAP_HEIGHT * TILE_SIZE)) / 2

-- Pot Entity
Pot = Class{}
function Pot:init(x, y)
    self.x = x
    self.y = y
    self.width = 14
    self.height = 14
    self.state = 'idle' -- 'idle', 'carried', 'thrown', 'shattered'
    self.dx = 0
    self.dy = 0
    self.speed = 180
    self.distanceTravelled = 0
    self.maxDistance = 64
end

function Pot:update(dt, room)
    if self.state == 'thrown' then
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
        self.distanceTravelled = self.distanceTravelled + self.speed * dt

        -- Check wall collision or travel distance limit
        if self.distanceTravelled >= self.maxDistance or
           self.x <= ROOM_OFFSET_X + TILE_SIZE or self.x >= ROOM_OFFSET_X + (MAP_WIDTH - 2) * TILE_SIZE or
           self.y <= ROOM_OFFSET_Y + TILE_SIZE or self.y >= ROOM_OFFSET_Y + (MAP_HEIGHT - 2) * TILE_SIZE then
            self.state = 'shattered'
        end

        -- Check enemy collisions
        for _, enemy in ipairs(room.enemies) do
            if enemy.alive and not (self.x + self.width < enemy.x or self.x > enemy.x + enemy.width or
                                    self.y + self.height < enemy.y or self.y > enemy.y + enemy.height) then
                enemy.alive = false
                self.state = 'shattered'
            end
        end
    end
end

function Pot:render()
    if self.state == 'shattered' then return end

    -- Clay Pot
    love.graphics.setColor(0.78, 0.45, 0.2, 1)
    love.graphics.rectangle('fill', math.floor(self.x + 2), math.floor(self.y + 3), self.width - 4, self.height - 3, 2, 2)
    -- Pot Rim
    love.graphics.setColor(0.6, 0.35, 0.15, 1)
    love.graphics.rectangle('fill', math.floor(self.x + 1), math.floor(self.y), self.width - 2, 3, 1, 1)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Enemy Class
Enemy = Class{}
function Enemy:init(x, y)
    self.x = x
    self.y = y
    self.width = 16
    self.height = 16
    self.direction = 'down'
    self.moveTimer = 0
    self.speed = 30
    self.alive = true
end

function Enemy:update(dt)
    if not self.alive then return end

    self.moveTimer = self.moveTimer + dt
    if self.moveTimer > 1.5 then
        self.moveTimer = 0
        local dirs = {'up', 'down', 'left', 'right'}
        self.direction = dirs[math.random(#dirs)]
    end

    if self.direction == 'up' then
        self.y = math.max(ROOM_OFFSET_Y + TILE_SIZE, self.y - self.speed * dt)
    elseif self.direction == 'down' then
        self.y = math.min(ROOM_OFFSET_Y + (MAP_HEIGHT - 2) * TILE_SIZE - self.height, self.y + self.speed * dt)
    elseif self.direction == 'left' then
        self.x = math.max(ROOM_OFFSET_X + TILE_SIZE, self.x - self.speed * dt)
    elseif self.direction == 'right' then
        self.x = math.min(ROOM_OFFSET_X + (MAP_WIDTH - 2) * TILE_SIZE - self.width, self.x + self.speed * dt)
    end
end

function Enemy:render()
    if not self.alive then return end
    -- Dark Skeleton/Mob
    love.graphics.setColor(0.85, 0.25, 0.25, 1)
    love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y), self.width, self.height, 3, 3)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle('fill', math.floor(self.x + 4), math.floor(self.y + 5), 2)
    love.graphics.circle('fill', math.floor(self.x + 12), math.floor(self.y + 5), 2)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.circle('fill', math.floor(self.x + 4), math.floor(self.y + 5), 1)
    love.graphics.circle('fill', math.floor(self.x + 12), math.floor(self.y + 5), 1)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Player Class
Player = Class{}
function Player:init()
    self.x = VIRTUAL_WIDTH / 2 - 8
    self.y = VIRTUAL_HEIGHT / 2 - 8
    self.width = 16
    self.height = 16
    self.direction = 'down'
    self.speed = 85
    self.health = 6
    self.carriedPot = nil
    self.swordSwing = false
    self.swordTimer = 0
end

function Player:update(dt, room)
    local moveX, moveY = 0, 0

    if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
        moveY = -1
        self.direction = 'up'
    elseif love.keyboard.isDown('s') or love.keyboard.isDown('down') then
        moveY = 1
        self.direction = 'down'
    end

    if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        moveX = -1
        self.direction = 'left'
    elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        moveX = 1
        self.direction = 'right'
    end

    self.x = math.max(ROOM_OFFSET_X + TILE_SIZE, math.min(ROOM_OFFSET_X + (MAP_WIDTH - 2) * TILE_SIZE - self.width, self.x + moveX * self.speed * dt))
    self.y = math.max(ROOM_OFFSET_Y + TILE_SIZE, math.min(ROOM_OFFSET_Y + (MAP_HEIGHT - 2) * TILE_SIZE - self.height, self.y + moveY * self.speed * dt))

    -- If carrying pot, update pot position directly above player's head
    if self.carriedPot then
        self.carriedPot.x = self.x + 1
        self.carriedPot.y = self.y - 12
    end

    -- Sword swing timer
    if self.swordSwing then
        self.swordTimer = self.swordTimer - dt
        if self.swordTimer <= 0 then
            self.swordSwing = false
        end
    end
end

function Player:render()
    -- Link tunic
    love.graphics.setColor(0.18, 0.65, 0.28, 1)
    love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y), self.width, self.height, 2, 2)
    -- Cap & hair
    love.graphics.setColor(0.85, 0.7, 0.2, 1)
    love.graphics.rectangle('fill', math.floor(self.x + 2), math.floor(self.y + 2), self.width - 4, 4)

    -- Sword attack hitbox visualization
    if self.swordSwing then
        love.graphics.setColor(0.9, 0.9, 0.95, 1)
        if self.direction == 'up' then
            love.graphics.rectangle('fill', self.x + 6, self.y - 12, 4, 12)
        elseif self.direction == 'down' then
            love.graphics.rectangle('fill', self.x + 6, self.y + 16, 4, 12)
        elseif self.direction == 'left' then
            love.graphics.rectangle('fill', self.x - 12, self.y + 6, 12, 4)
        elseif self.direction == 'right' then
            love.graphics.rectangle('fill', self.x + 16, self.y + 6, 12, 4)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Room Class
Room = Class{}
function Room:init(roomX, roomY)
    self.roomX = roomX or 0
    self.roomY = roomY or 0
    self.pots = {}
    self.enemies = {}

    -- Spawn pots
    table.insert(self.pots, Pot(ROOM_OFFSET_X + 4 * TILE_SIZE, ROOM_OFFSET_Y + 4 * TILE_SIZE))
    table.insert(self.pots, Pot(ROOM_OFFSET_X + 17 * TILE_SIZE, ROOM_OFFSET_Y + 4 * TILE_SIZE))
    table.insert(self.pots, Pot(ROOM_OFFSET_X + 4 * TILE_SIZE, ROOM_OFFSET_Y + 7 * TILE_SIZE))
    table.insert(self.pots, Pot(ROOM_OFFSET_X + 17 * TILE_SIZE, ROOM_OFFSET_Y + 7 * TILE_SIZE))

    -- Spawn enemies
    table.insert(self.enemies, Enemy(ROOM_OFFSET_X + 8 * TILE_SIZE, ROOM_OFFSET_Y + 5 * TILE_SIZE))
    table.insert(self.enemies, Enemy(ROOM_OFFSET_X + 14 * TILE_SIZE, ROOM_OFFSET_Y + 5 * TILE_SIZE))
end

function Room:update(dt)
    for _, pot in ipairs(self.pots) do
        pot:update(dt, self)
    end
    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt)
    end
end

function Room:render()
    -- Dungeon Floor
    love.graphics.setColor(0.35, 0.32, 0.42, 1)
    love.graphics.rectangle('fill', ROOM_OFFSET_X, ROOM_OFFSET_Y, MAP_WIDTH * TILE_SIZE, MAP_HEIGHT * TILE_SIZE)

    -- Dungeon Walls
    love.graphics.setColor(0.18, 0.16, 0.25, 1)
    love.graphics.rectangle('fill', ROOM_OFFSET_X, ROOM_OFFSET_Y, MAP_WIDTH * TILE_SIZE, TILE_SIZE)
    love.graphics.rectangle('fill', ROOM_OFFSET_X, ROOM_OFFSET_Y + (MAP_HEIGHT - 1) * TILE_SIZE, MAP_WIDTH * TILE_SIZE, TILE_SIZE)
    love.graphics.rectangle('fill', ROOM_OFFSET_X, ROOM_OFFSET_Y, TILE_SIZE, MAP_HEIGHT * TILE_SIZE)
    love.graphics.rectangle('fill', ROOM_OFFSET_X + (MAP_WIDTH - 1) * TILE_SIZE, ROOM_OFFSET_Y, TILE_SIZE, MAP_HEIGHT * TILE_SIZE)

    -- Doorways (North, South, East, West)
    love.graphics.setColor(0.1, 0.1, 0.12, 1)
    -- Top door
    love.graphics.rectangle('fill', ROOM_OFFSET_X + (MAP_WIDTH/2 - 1) * TILE_SIZE, ROOM_OFFSET_Y, TILE_SIZE * 2, TILE_SIZE)
    -- Bottom door
    love.graphics.rectangle('fill', ROOM_OFFSET_X + (MAP_WIDTH/2 - 1) * TILE_SIZE, ROOM_OFFSET_Y + (MAP_HEIGHT - 1) * TILE_SIZE, TILE_SIZE * 2, TILE_SIZE)

    -- Render Pots and Enemies
    for _, pot in ipairs(self.pots) do
        pot:render()
    end
    for _, enemy in ipairs(self.enemies) do
        enemy:render()
    end
end

local player, currentRoom
local roomX, roomY = 0, 0
local keysPressed = {}

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Legend of Zelda - CS50G Assignment 5')
    math.randomseed(os.time())

    font = love.graphics.newFont(10)
    scoreFont = love.graphics.newFont(14)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    player = Player()
    currentRoom = Room(0, 0)
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'space' then
        -- Sword attack or throw pot
        if player.carriedPot then
            -- CS50 Requirement: Throw pot
            local pot = player.carriedPot
            pot.state = 'thrown'
            pot.distanceTravelled = 0
            if player.direction == 'up' then
                pot.dx = 0; pot.dy = -pot.speed
            elseif player.direction == 'down' then
                pot.dx = 0; pot.dy = pot.speed
            elseif player.direction == 'left' then
                pot.dx = -pot.speed; pot.dy = 0
            elseif player.direction == 'right' then
                pot.dx = pot.speed; pot.dy = 0
            end
            player.carriedPot = nil
        else
            -- Sword swing
            player.swordSwing = true
            player.swordTimer = 0.2
            -- Check enemy hit
            for _, enemy in ipairs(currentRoom.enemies) do
                if enemy.alive then
                    local hit = false
                    if player.direction == 'up' and math.abs(enemy.x - player.x) < 16 and (player.y - enemy.y) < 24 and (player.y - enemy.y) > 0 then hit = true end
                    if player.direction == 'down' and math.abs(enemy.x - player.x) < 16 and (enemy.y - player.y) < 24 and (enemy.y - player.y) > 0 then hit = true end
                    if player.direction == 'left' and math.abs(enemy.y - player.y) < 16 and (player.x - enemy.x) < 24 and (player.x - enemy.x) > 0 then hit = true end
                    if player.direction == 'right' and math.abs(enemy.y - player.y) < 16 and (enemy.x - player.x) < 24 and (enemy.x - player.x) > 0 then hit = true end
                    if hit then enemy.alive = false end
                end
            end
        end
    elseif key == 'e' or key == 'return' then
        -- CS50 Requirement: Lift pot if facing and adjacent to idle pot
        if not player.carriedPot then
            for _, pot in ipairs(currentRoom.pots) do
                if pot.state == 'idle' then
                    local dx = math.abs((player.x + 8) - (pot.x + 7))
                    local dy = math.abs((player.y + 8) - (pot.y + 7))
                    if dx < 18 and dy < 18 then
                        player.carriedPot = pot
                        pot.state = 'carried'
                        break
                    end
                end
            end
        end
    end
end

function love.update(dt)
    player:update(dt, currentRoom)
    currentRoom:update(dt)

    -- Room Transition through North / South doorways
    if player.y <= ROOM_OFFSET_Y + TILE_SIZE and math.abs(player.x - (ROOM_OFFSET_X + (MAP_WIDTH/2 - 1) * TILE_SIZE)) < 24 then
        -- North transition
        roomY = roomY - 1
        currentRoom = Room(roomX, roomY)
        player.y = ROOM_OFFSET_Y + (MAP_HEIGHT - 2) * TILE_SIZE - player.height
    elseif player.y >= ROOM_OFFSET_Y + (MAP_HEIGHT - 2) * TILE_SIZE - player.height and math.abs(player.x - (ROOM_OFFSET_X + (MAP_WIDTH/2 - 1) * TILE_SIZE)) < 24 then
        -- South transition
        roomY = roomY + 1
        currentRoom = Room(roomX, roomY)
        player.y = ROOM_OFFSET_Y + TILE_SIZE + 2
    end
end

function love.draw()
    push:start()
    love.graphics.clear(20/255, 18/255, 24/255, 1)

    -- Render Room
    currentRoom:render()

    -- Render Player
    player:render()

    -- HUD: Hearts and Dungeon info
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('Room: (' .. roomX .. ', ' .. roomY .. ')', 10, 6)
    love.graphics.print('Hearts: ', VIRTUAL_WIDTH - 100, 6)
    for i = 1, 3 do
        love.graphics.setColor(0.95, 0.2, 0.3, 1)
        love.graphics.circle('fill', VIRTUAL_WIDTH - 50 + (i * 12), 11, 4)
    end

    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.printf('WASD: Walk | SPACE: Sword / Throw Pot | E: Lift Pot | Doors: Room Transition', 0, VIRTUAL_HEIGHT - 12, VIRTUAL_WIDTH, 'center')

    push:finish()
end
