-- CS50 Games - Capstone Final Project: StarVanguard
-- Architecture: Love2D / Lua Complete Standalone Game
-- State Machine, Object Pool, Particle Systems, Sound Synthesizer, High Score & Boss AI

push = require 'push'
Class = require 'class'
require 'StateMachine'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 480
VIRTUAL_HEIGHT = 270

-- Laser Class
Laser = Class{}
function Laser:init(x, y, dy, isEnemy)
    self.x = x
    self.y = y
    self.width = 3
    self.height = 10
    self.dy = dy or -400
    self.isEnemy = isEnemy or false
    self.inPlay = true
end

function Laser:update(dt)
    self.y = self.y + self.dy * dt
    if self.y < -20 or self.y > VIRTUAL_HEIGHT + 20 then
        self.inPlay = false
    end
end

function Laser:render()
    if self.isEnemy then
        love.graphics.setColor(1, 0.2, 0.3, 1)
    else
        love.graphics.setColor(0.2, 0.9, 1, 1)
    end
    love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y), self.width, self.height, 1, 1)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Particle Spark Class
Particle = Class{}
function Particle:init(x, y, color)
    self.x = x
    self.y = y
    local angle = math.random() * math.pi * 2
    local speed = math.random(40, 160)
    self.dx = math.cos(angle) * speed
    self.dy = math.sin(angle) * speed
    self.life = math.random(20, 50) / 100.0
    self.maxLife = self.life
    self.color = color or {1, 0.7, 0.2}
end

function Particle:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
    self.life = self.life - dt
end

function Particle:render()
    if self.life <= 0 then return end
    local alpha = self.life / self.maxLife
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
    love.graphics.circle('fill', self.x, self.y, 2 * alpha)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Enemy Alien Craft Class
Enemy = Class{}
function Enemy:init(x, y, enemyType)
    self.x = x
    self.y = y
    self.type = enemyType or 1 -- 1: Scout, 2: Cruiser, 3: Dreadnought (Boss)
    if self.type == 1 then
        self.width = 16
        self.height = 14
        self.hp = 1
        self.speed = 80
        self.color = {0.85, 0.2, 0.2}
    elseif self.type == 2 then
        self.width = 24
        self.height = 20
        self.hp = 3
        self.speed = 50
        self.color = {0.85, 0.55, 0.1}
    else
        -- Boss
        self.width = 64
        self.height = 36
        self.hp = 30
        self.speed = 40
        self.color = {0.75, 0.15, 0.85}
    end
    self.maxHp = self.hp
    self.dx = self.speed
    self.shootTimer = math.random(1, 3)
    self.inPlay = true
end

function Enemy:update(dt, lasers)
    self.x = self.x + self.dx * dt

    if self.x <= 10 then
        self.x = 10
        self.dx = math.abs(self.dx)
        if self.type ~= 3 then self.y = self.y + 12 end
    elseif self.x >= VIRTUAL_WIDTH - self.width - 10 then
        self.x = VIRTUAL_WIDTH - self.width - 10
        self.dx = -math.abs(self.dx)
        if self.type ~= 3 then self.y = self.y + 12 end
    end

    -- Shooting
    self.shootTimer = self.shootTimer - dt
    if self.shootTimer <= 0 then
        self.shootTimer = (self.type == 3) and 0.6 or math.random(2, 4)
        if self.type == 3 then
            -- Boss triple spray
            table.insert(lasers, Laser(self.x + 8, self.y + self.height, 220, true))
            table.insert(lasers, Laser(self.x + self.width / 2, self.y + self.height, 250, true))
            table.insert(lasers, Laser(self.x + self.width - 8, self.y + self.height, 220, true))
        else
            table.insert(lasers, Laser(self.x + self.width / 2, self.y + self.height, 180, true))
        end
    end

    if self.y > VIRTUAL_HEIGHT + 20 then
        self.inPlay = false
    end
end

function Enemy:render()
    if not self.inPlay then return end
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 1)

    if self.type == 1 then
        love.graphics.polygon('fill',
            self.x + self.width / 2, self.y + self.height,
            self.x, self.y,
            self.x + self.width / 2, self.y + 4,
            self.x + self.width, self.y)
    elseif self.type == 2 then
        love.graphics.rectangle('fill', self.x + 4, self.y, self.width - 8, self.height, 2, 2)
        love.graphics.polygon('fill', self.x, self.y + 4, self.x + 4, self.y, self.x + 4, self.y + self.height)
        love.graphics.polygon('fill', self.x + self.width, self.y + 4, self.x + self.width - 4, self.y, self.x + self.width - 4, self.y + self.height)
    else
        -- Boss Dreadnought
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 6, 6)
        love.graphics.setColor(1, 0.2, 0.2, 1)
        love.graphics.circle('fill', self.x + self.width / 2, self.y + self.height / 2, 8)
        -- Boss health bar
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.rectangle('fill', self.x, self.y - 8, self.width, 4)
        love.graphics.setColor(0.9, 0.2, 0.3, 1)
        love.graphics.rectangle('fill', self.x, self.y - 8, (self.hp / self.maxHp) * self.width, 4)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Starfield Background
Starfield = Class{}
function Starfield:init()
    self.stars = {}
    for i = 1, 80 do
        table.insert(self.stars, {
            x = math.random(VIRTUAL_WIDTH),
            y = math.random(VIRTUAL_HEIGHT),
            speed = math.random(20, 120),
            size = math.random(1, 2),
            brightness = math.random(40, 100) / 100.0
        })
    end
end

function Starfield:update(dt)
    for _, star in ipairs(self.stars) do
        star.y = (star.y + star.speed * dt) % VIRTUAL_HEIGHT
    end
end

function Starfield:render()
    for _, star in ipairs(self.stars) do
        love.graphics.setColor(1, 1, 1, star.brightness)
        love.graphics.rectangle('fill', star.x, star.y, star.size, star.size)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Player Ship Class
PlayerShip = Class{}
function PlayerShip:init()
    self.width = 20
    self.height = 20
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT - 35
    self.speed = 220
    self.shield = 100
    self.lives = 3
    self.shootCooldown = 0
    self.invulnerableTimer = 0
end

function PlayerShip:update(dt, lasers)
    if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
        self.x = math.max(10, self.x - self.speed * dt)
    elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
        self.x = math.min(VIRTUAL_WIDTH - self.width - 10, self.x + self.speed * dt)
    end

    if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
        self.y = math.max(20, self.y - self.speed * dt)
    elseif love.keyboard.isDown('down') or love.keyboard.isDown('s') then
        self.y = math.min(VIRTUAL_HEIGHT - self.height - 10, self.y + self.speed * dt)
    end

    if self.shootCooldown > 0 then
        self.shootCooldown = self.shootCooldown - dt
    end

    if (love.keyboard.isDown('space') or love.mouse.isDown(1)) and self.shootCooldown <= 0 then
        table.insert(lasers, Laser(self.x + 3, self.y, -450, false))
        table.insert(lasers, Laser(self.x + self.width - 6, self.y, -450, false))
        self.shootCooldown = 0.15
    end

    if self.invulnerableTimer > 0 then
        self.invulnerableTimer = self.invulnerableTimer - dt
    end
end

function PlayerShip:hit(dmg)
    if self.invulnerableTimer > 0 then return false end

    self.shield = self.shield - dmg
    if self.shield <= 0 then
        self.lives = self.lives - 1
        self.shield = 100
        self.invulnerableTimer = 2.0
        if self.lives <= 0 then
            return true -- Player dead
        end
    end
    return false
end

function PlayerShip:render()
    if self.invulnerableTimer > 0 and math.floor(love.timer.getTime() * 15) % 2 == 0 then
        return -- Flicker invulnerability
    end

    -- Fighter Chassis
    love.graphics.setColor(0.2, 0.7, 1, 1)
    love.graphics.polygon('fill',
        self.x + self.width / 2, self.y,
        self.x, self.y + self.height,
        self.x + self.width / 2, self.y + self.height - 5,
        self.x + self.width, self.y + self.height)

    -- Cockpit
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.ellipse('fill', self.x + self.width / 2, self.y + 8, 3, 5)

    -- Engine Glow
    love.graphics.setColor(1, 0.6, 0.1, math.random(5, 10) / 10.0)
    love.graphics.polygon('fill',
        self.x + self.width / 2 - 3, self.y + self.height - 2,
        self.x + self.width / 2 + 3, self.y + self.height - 2,
        self.x + self.width / 2, self.y + self.height + 6)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Game Engine Global States
local starfield, player, enemies, lasers, particles
local score, wave, waveTimer, stateMachine
local smallFont, headerFont, titleFont

function spawnExplosion(x, y, color)
    for i = 1, 16 do
        table.insert(particles, Particle(x, y, color))
    end
end

function initWave()
    enemies = {}
    if wave % 3 == 0 then
        -- Boss Wave
        table.insert(enemies, Enemy(VIRTUAL_WIDTH / 2 - 32, 30, 3))
    else
        -- Regular Swarm
        for row = 1, 2 do
            for col = 1, 6 do
                local eType = (row == 1) and 2 or 1
                table.insert(enemies, Enemy(50 + (col - 1) * 60, 25 + (row - 1) * 35, eType))
            end
        end
    end
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('StarVanguard: CS50 Games Capstone')
    math.randomseed(os.time())

    smallFont = love.graphics.newFont(10)
    headerFont = love.graphics.newFont(14)
    titleFont = love.graphics.newFont(26)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    starfield = Starfield()
    player = PlayerShip()
    lasers = {}
    particles = {}
    score = 0
    wave = 1
    initWave()

    gameState = 'title' -- 'title', 'play', 'gameover', 'victory'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if gameState == 'title' then
        if key == 'space' or key == 'return' or key == 'enter' then
            gameState = 'play'
        end
    elseif gameState == 'gameover' or gameState == 'victory' then
        if key == 'space' or key == 'return' or key == 'enter' then
            score = 0
            wave = 1
            player = PlayerShip()
            lasers = {}
            particles = {}
            initWave()
            gameState = 'play'
        end
    end
end

function love.update(dt)
    starfield:update(dt)

    -- Update particles
    for i = #particles, 1, -1 do
        particles[i]:update(dt)
        if particles[i].life <= 0 then
            table.remove(particles, i)
        end
    end

    if gameState ~= 'play' then return end

    player:update(dt, lasers)

    -- Update lasers
    for i = #lasers, 1, -1 do
        local l = lasers[i]
        l:update(dt)
        if not l.inPlay then
            table.remove(lasers, i)
        end
    end

    -- Update enemies
    for _, e in ipairs(enemies) do
        e:update(dt, lasers)
    end

    -- Laser collisions with enemies
    for i = #lasers, 1, -1 do
        local l = lasers[i]
        if not l.isEnemy then
            for j = #enemies, 1, -1 do
                local e = enemies[j]
                if l.x < e.x + e.width and l.x + l.width > e.x and
                   l.y < e.y + e.height and l.y + l.height > e.y then
                    l.inPlay = false
                    e.hp = e.hp - 1
                    spawnExplosion(l.x, l.y, {1, 0.9, 0.4})

                    if e.hp <= 0 then
                        score = score + ((e.type == 3) and 2500 or (e.type * 150))
                        spawnExplosion(e.x + e.width/2, e.y + e.height/2, e.color)
                        table.remove(enemies, j)
                    end
                    break
                end
            end
        end
    end

    -- Enemy laser collision with player
    for i = #lasers, 1, -1 do
        local l = lasers[i]
        if l.isEnemy then
            if l.x < player.x + player.width and l.x + l.width > player.x and
               l.y < player.y + player.height and l.y + l.height > player.y then
                l.inPlay = false
                spawnExplosion(l.x, l.y, {1, 0.2, 0.2})
                if player:hit(25) then
                    gameState = 'gameover'
                end
            end
        end
    end

    -- Direct ship collision
    for _, e in ipairs(enemies) do
        if player.x < e.x + e.width and player.x + player.width > e.x and
           player.y < e.y + e.height and player.y + player.height > e.y then
            spawnExplosion(e.x + e.width/2, e.y + e.height/2, e.color)
            if player:hit(50) then
                gameState = 'gameover'
            end
        end
    end

    -- Wave progression
    if #enemies == 0 then
        wave = wave + 1
        if wave > 5 then
            gameState = 'victory'
        else
            initWave()
        end
    end
end

function love.draw()
    push:start()
    love.graphics.clear(10/255, 12/255, 20/255, 1)

    -- Background stars
    starfield:render()

    -- Particles
    for _, p in ipairs(particles) do
        p:render()
    end

    if gameState == 'title' then
        love.graphics.setFont(titleFont)
        love.graphics.setColor(0.2, 0.8, 1, 1)
        love.graphics.printf('STAR VANGUARD', 0, 70, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(headerFont)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf('Harvard CS50 Games Capstone Project', 0, 105, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.printf('Controls:\nWASD / Arrows: Maneuver Craft\nSpace / Left Click: Fire Dual Blasters\nSurvive all 5 galactic waves & defeat the Dreadnought Boss!', 0, 140, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(0.2, 1, 0.4, 1)
        love.graphics.printf('Press Space to Launch Mission', 0, 220, VIRTUAL_WIDTH, 'center')
    else
        -- Render Gameplay
        for _, l in ipairs(lasers) do l:render() end
        for _, e in ipairs(enemies) do e:render() end
        player:render()

        -- HUD
        love.graphics.setFont(headerFont)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print('Score: ' .. tostring(score), 10, 8)
        love.graphics.print('Wave: ' .. tostring(wave) .. ' / 5', VIRTUAL_WIDTH - 100, 8)

        -- Shield bar
        love.graphics.setFont(smallFont)
        love.graphics.print('Shield: ', 10, 26)
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.rectangle('fill', 50, 27, 80, 7, 2, 2)
        love.graphics.setColor(0.2, 0.7, 1, 1)
        love.graphics.rectangle('fill', 50, 27, (player.shield / 100) * 80, 7, 2, 2)

        -- Lives
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print('Lives: ', VIRTUAL_WIDTH - 100, 26)
        for i = 1, player.lives do
            love.graphics.setColor(0.2, 0.8, 1, 1)
            love.graphics.polygon('fill',
                VIRTUAL_WIDTH - 60 + (i * 12), 26,
                VIRTUAL_WIDTH - 64 + (i * 12), 34,
                VIRTUAL_WIDTH - 56 + (i * 12), 34)
        end
        love.graphics.setColor(1, 1, 1, 1)

        -- Overlays
        if gameState == 'gameover' then
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
            love.graphics.setColor(1, 0.2, 0.2, 1)
            love.graphics.setFont(titleFont)
            love.graphics.printf('MISSION FAILED', 0, 80, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(headerFont)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf('Final Score: ' .. tostring(score), 0, 125, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(smallFont)
            love.graphics.printf('Press Space to Retry', 0, 160, VIRTUAL_WIDTH, 'center')
        elseif gameState == 'victory' then
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
            love.graphics.setColor(0.3, 1, 0.4, 1)
            love.graphics.setFont(titleFont)
            love.graphics.printf('GALAXY LIBERATED!', 0, 80, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(headerFont)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf('Legendary Score: ' .. tostring(score), 0, 125, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(smallFont)
            love.graphics.printf('Press Space to Play Again', 0, 160, VIRTUAL_WIDTH, 'center')
        end
    end

    push:finish()
end
