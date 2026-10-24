-- CS50 Games - Assignment 6: Angry Birds (Fifty Bird Physics)
-- Requirements:
-- 1. Slingshot projectile launching physics (Love2D / Box2D physics simulation)
-- 2. Alien split mechanic: While in flight, clicking/tapping the screen splits the launched alien
--    into three separate aliens with distinct upward and downward trajectory deviations!
-- 3. Obstacle destruction and target elimination

push = require 'push'
Class = require 'class'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 640
VIRTUAL_HEIGHT = 360

-- Alien Class
Alien = Class{}
function Alien:init(world, x, y, isChild)
    self.body = love.physics.newBody(world, x, y, 'dynamic')
    self.shape = love.physics.newCircleShape(12)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setRestitution(0.4)
    self.fixture:setUserData('Alien')
    self.isChild = isChild or false
    self.hasSplit = isChild or false
    self.alive = true
end

function Alien:render()
    if not self.alive then return end
    local x, y = self.body:getPosition()

    -- Round alien body
    love.graphics.setColor(0.3, 0.8, 0.95, 1)
    love.graphics.circle('fill', x, y, 12)

    -- Alien eyes
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle('fill', x - 4, y - 3, 3)
    love.graphics.circle('fill', x + 4, y - 3, 3)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.circle('fill', x - 3, y - 3, 1.5)
    love.graphics.circle('fill', x + 5, y - 3, 1.5)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Obstacle Class
Obstacle = Class{}
function Obstacle:init(world, x, y, width, height)
    self.width = width
    self.height = height
    self.body = love.physics.newBody(world, x, y, 'dynamic')
    self.shape = love.physics.newRectangleShape(width, height)
    self.fixture = love.physics.newFixture(self.body, self.shape, 2)
    self.fixture:setRestitution(0.1)
    self.fixture:setUserData('Obstacle')
end

function Obstacle:render()
    local x, y = self.body:getPosition()
    local angle = self.body:getAngle()

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)

    -- Wooden crate / beam
    love.graphics.setColor(0.72, 0.52, 0.35, 1)
    love.graphics.rectangle('fill', -self.width / 2, -self.height / 2, self.width, self.height)
    love.graphics.setColor(0.5, 0.35, 0.2, 1)
    love.graphics.rectangle('line', -self.width / 2, -self.height / 2, self.width, self.height)

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

-- Target Pig/Alien Class
Target = Class{}
function Target:init(world, x, y)
    self.body = love.physics.newBody(world, x, y, 'dynamic')
    self.shape = love.physics.newCircleShape(14)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setRestitution(0.3)
    self.fixture:setUserData('Target')
    self.destroyed = false
end

function Target:render()
    if self.destroyed then return end
    local x, y = self.body:getPosition()
    love.graphics.setColor(0.4, 0.85, 0.3, 1)
    love.graphics.circle('fill', x, y, 14)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.circle('fill', x - 4, y - 2, 2)
    love.graphics.circle('fill', x + 4, y - 2, 2)
    -- Snout
    love.graphics.setColor(0.3, 0.7, 0.2, 1)
    love.graphics.ellipse('fill', x, y + 4, 6, 4)
    love.graphics.setColor(1, 1, 1, 1)
end

local world, groundBody, groundShape, groundFixture
local aliens = {}
local obstacles = {}
local targets = {}

local slingshotX, slingshotY = 120, 260
local dragging = false
local launched = false
local mouseX, mouseY = 0, 0

function initPhysicsLevel()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81 * 64, true)

    -- Ground
    groundBody = love.physics.newBody(world, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT - 10, 'static')
    groundShape = love.physics.newRectangleShape(VIRTUAL_WIDTH, 20)
    groundFixture = love.physics.newFixture(groundBody, groundShape)

    -- Obstacles tower
    obstacles = {}
    table.insert(obstacles, Obstacle(world, 480, 280, 20, 90))
    table.insert(obstacles, Obstacle(world, 540, 280, 20, 90))
    table.insert(obstacles, Obstacle(world, 510, 230, 80, 16))
    table.insert(obstacles, Obstacle(world, 510, 180, 20, 80))

    -- Target Pig
    targets = { Target(world, 510, 215) }

    -- Primary alien
    aliens = {}
    launched = false
    dragging = false
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Angry Birds - CS50G Assignment 6')

    font = love.graphics.newFont(12)
    bigFont = love.graphics.newFont(20)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    initPhysicsLevel()
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.mousepressed(x, y, button)
    local rx, ry = push:toReal(x, y)
    if button == 1 then
        if not launched then
            local dist = math.sqrt((rx - slingshotX)^2 + (ry - slingshotY)^2)
            if dist < 40 then
                dragging = true
            end
        else
            -- ========================================================
            -- CS50G ASSIGNMENT 6: ALIEN SPLIT MECHANIC
            -- ========================================================
            -- When clicking in mid-air, split alien into 3 independent aliens!
            if #aliens > 0 and not aliens[1].hasSplit then
                local mainAlien = aliens[1]
                mainAlien.hasSplit = true

                local ax, ay = mainAlien.body:getPosition()
                local vx, vy = mainAlien.body:getLinearVelocity()

                -- Child Alien 1: Higher trajectory arc (deviated upward)
                local child1 = Alien(world, ax, ay - 14, true)
                child1.body:setLinearVelocity(vx, vy - 90)
                table.insert(aliens, child1)

                -- Child Alien 2: Lower trajectory arc (deviated downward)
                local child2 = Alien(world, ax, ay + 14, true)
                child2.body:setLinearVelocity(vx, vy + 90)
                table.insert(aliens, child2)
            end
        end
    end
end

function love.mousereleased(x, y, button)
    local rx, ry = push:toReal(x, y)
    if button == 1 and dragging then
        dragging = false
        launched = true

        local alien = Alien(world, rx, ry, false)
        local impulseX = (slingshotX - rx) * 12
        local impulseY = (slingshotY - ry) * 12
        alien.body:setLinearVelocity(impulseX, impulseY)
        table.insert(aliens, alien)
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'r' or key == 'space' then
        initPhysicsLevel()
    end
end

function love.update(dt)
    world:update(dt)
end

function love.draw()
    push:start()

    -- Sky background
    love.graphics.setColor(0.55, 0.78, 0.95, 1)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    -- Ground
    love.graphics.setColor(0.3, 0.65, 0.25, 1)
    love.graphics.rectangle('fill', 0, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 20)

    -- Slingshot frame
    love.graphics.setColor(0.45, 0.28, 0.15, 1)
    love.graphics.rectangle('fill', slingshotX - 4, slingshotY, 8, VIRTUAL_HEIGHT - slingshotY - 20)
    love.graphics.line(slingshotX - 12, slingshotY - 14, slingshotX, slingshotY)
    love.graphics.line(slingshotX + 12, slingshotY - 14, slingshotX, slingshotY)

    -- Slingshot elastic band while dragging
    if dragging then
        local mx, my = push:toReal(love.mouse.getPosition())
        love.graphics.setColor(0.2, 0.1, 0.05, 1)
        love.graphics.setLineWidth(3)
        love.graphics.line(slingshotX - 10, slingshotY - 10, mx, my)
        love.graphics.line(slingshotX + 10, slingshotY - 10, mx, my)

        -- Held alien
        love.graphics.setColor(0.3, 0.8, 0.95, 1)
        love.graphics.circle('fill', mx, my, 12)
    end

    -- Render Obstacles & Targets
    for _, obs in ipairs(obstacles) do
        obs:render()
    end
    for _, t in ipairs(targets) do
        t:render()
    end

    -- Render Aliens
    for _, a in ipairs(aliens) do
        a:render()
    end

    -- UI / Instructions
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.setFont(font)
    love.graphics.print('Drag Slingshot & Release to Launch Alien', 15, 15)
    love.graphics.print('CLICK IN MID-AIR TO SPLIT INTO 3 ALIENS (CS50 Requirement)!', 15, 30)
    love.graphics.print('Press R to Reset Level', 15, 45)

    push:finish()
end
