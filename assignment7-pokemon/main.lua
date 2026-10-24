-- CS50 Games - Assignment 7: Pokemon
-- Requirements:
-- 1. Experience Bar UI (smooth animation / calculation based on level)
-- 2. Level up stat increases (HP, Attack, Defense, Speed)
-- 3. Wild Pokemon encounters and turn-based battle state machine

push = require 'push'
Class = require 'class'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

-- Pokemon Class
Pokemon = Class{}
function Pokemon:init(name, level, maxHP, attack, defense, speed, isPlayer)
    self.name = name
    self.level = level or 1
    self.maxHP = maxHP or 30
    self.currentHP = self.maxHP
    self.attack = attack or 10
    self.defense = defense or 8
    self.speed = speed or 10
    self.isPlayer = isPlayer or false

    self.currentExp = 0
    self.expToLevel = self:calculateExpToLevel()
end

function Pokemon:calculateExpToLevel()
    -- Cubic / Quadratic Pokemon exp curve
    return math.floor(self.level * self.level * 15)
end

function Pokemon:gainExp(amount)
    self.currentExp = self.currentExp + amount
    local leveledUp = false
    local statGains = {}

    while self.currentExp >= self.expToLevel do
        self.currentExp = self.currentExp - self.expToLevel
        self.level = self.level + 1
        self.expToLevel = self:calculateExpToLevel()

        -- CS50 Requirement: Stat increases on level up
        local hpInc = math.random(2, 5)
        local atkInc = math.random(1, 3)
        local defInc = math.random(1, 3)
        local spdInc = math.random(1, 3)

        self.maxHP = self.maxHP + hpInc
        self.currentHP = self.currentHP + hpInc
        self.attack = self.attack + atkInc
        self.defense = self.defense + defInc
        self.speed = self.speed + spdInc

        table.insert(statGains, {
            hp = hpInc,
            atk = atkInc,
            def = defInc,
            spd = spdInc
        })
        leveledUp = true
    end

    return leveledUp, statGains
end

function Pokemon:takeDamage(dmg)
    self.currentHP = math.max(0, self.currentHP - dmg)
    return self.currentHP == 0
end

-- Battle State
local playerPokemon, enemyPokemon
local gameState = 'field' -- 'field', 'battle_menu', 'battle_dialogue', 'battle_levelup'
local battleMessage = ''
local dialogueQueue = {}
local playerX, playerY = 60, 60
local playerSpeed = 80

function startBattle()
    gameState = 'battle_menu'
    local enemyNames = {'Pidgey', 'Rattata', 'Zubat', 'Caterpie'}
    local name = enemyNames[math.random(#enemyNames)]
    local enemyLvl = math.random(1, 3)
    enemyPokemon = Pokemon(name, enemyLvl, 15 + enemyLvl * 5, 6 + enemyLvl * 2, 4 + enemyLvl, 5 + enemyLvl, false)
    battleMessage = 'A wild ' .. enemyPokemon.name .. ' appeared!'
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Pokemon - CS50G Assignment 7')
    math.randomseed(os.time())

    font = love.graphics.newFont(10)
    menuFont = love.graphics.newFont(14)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    playerPokemon = Pokemon('Pikachu', 3, 35, 14, 10, 15, true)
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if gameState == 'battle_menu' then
        if key == '1' or key == 'space' or key == 'return' then
            -- Player Attacks
            local dmg = math.max(1, math.floor((2 * playerPokemon.level / 5 + 2) * playerPokemon.attack * 10 / enemyPokemon.defense / 10))
            local fainted = enemyPokemon:takeDamage(dmg)
            battleMessage = playerPokemon.name .. ' attacked for ' .. dmg .. ' damage!'

            if fainted then
                local expYield = math.floor(enemyPokemon.level * 25)
                local leveledUp, gains = playerPokemon:gainExp(expYield)
                if leveledUp then
                    gameState = 'battle_levelup'
                    battleMessage = enemyPokemon.name .. ' fainted! ' .. playerPokemon.name .. ' gained ' .. expYield .. ' EXP and grew to LV ' .. playerPokemon.level .. '!'
                else
                    gameState = 'battle_dialogue'
                    battleMessage = enemyPokemon.name .. ' fainted! Gained ' .. expYield .. ' EXP!'
                end
            else
                -- Enemy retaliation
                gameState = 'battle_dialogue'
            end
        elseif key == '2' then
            -- Run
            gameState = 'field'
        end
    elseif gameState == 'battle_dialogue' then
        if key == 'space' or key == 'return' then
            if enemyPokemon.currentHP == 0 then
                gameState = 'field'
            else
                -- Enemy turns to attack
                local eDmg = math.max(1, math.floor(enemyPokemon.attack - playerPokemon.defense * 0.3))
                playerPokemon:takeDamage(eDmg)
                battleMessage = enemyPokemon.name .. ' attacked ' .. playerPokemon.name .. ' for ' .. eDmg .. ' DMG!'
                gameState = 'battle_menu'
            end
        end
    elseif gameState == 'battle_levelup' then
        if key == 'space' or key == 'return' then
            gameState = 'field'
        end
    end
end

function love.update(dt)
    if gameState == 'field' then
        local moved = false
        if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
            playerY = playerY - playerSpeed * dt; moved = true
        elseif love.keyboard.isDown('s') or love.keyboard.isDown('down') then
            playerY = playerY + playerSpeed * dt; moved = true
        end

        if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
            playerX = playerX - playerSpeed * dt; moved = true
        elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
            playerX = playerX + playerSpeed * dt; moved = true
        end

        -- Check grass patch encounters
        if moved and playerX > 180 and playerX < 320 and playerY > 50 and playerY < 180 then
            if math.random(140) == 1 then
                startBattle()
            end
        end
    end
end

function love.draw()
    push:start()

    if gameState == 'field' then
        -- Overworld Field
        love.graphics.clear(100/255, 180/255, 90/255, 1)

        -- Tall Grass patch
        love.graphics.setColor(60/255, 140/255, 50/255, 1)
        love.graphics.rectangle('fill', 180, 50, 140, 130)

        -- Path
        love.graphics.setColor(210/255, 190/255, 130/255, 1)
        love.graphics.rectangle('fill', 0, 80, 180, 40)
        love.graphics.rectangle('fill', 70, 0, 40, VIRTUAL_HEIGHT)

        -- Trainer
        love.graphics.setColor(0.9, 0.2, 0.2, 1)
        love.graphics.rectangle('fill', playerX, playerY, 14, 16, 3, 3)

        -- Instructions
        love.graphics.setFont(font)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print('Walk into Tall Grass (Right) to trigger Wild Battle!', 10, 10)
    else
        -- Battle Arena
        love.graphics.clear(240/255, 245/255, 240/255, 1)

        -- Enemy Platform
        love.graphics.setColor(0.7, 0.8, 0.7, 1)
        love.graphics.ellipse('fill', VIRTUAL_WIDTH - 90, 80, 60, 20)
        -- Enemy Pokemon placeholder
        love.graphics.setColor(0.4, 0.6, 0.9, 1)
        love.graphics.circle('fill', VIRTUAL_WIDTH - 90, 65, 18)

        -- Enemy Info Card
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.rectangle('fill', 20, 20, 130, 40, 4, 4)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setFont(font)
        love.graphics.print(enemyPokemon.name .. '  Lv.' .. enemyPokemon.level, 25, 25)
        -- Enemy HP Bar
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.rectangle('fill', 25, 42, 100, 6)
        love.graphics.setColor(0.2, 0.8, 0.3, 1)
        love.graphics.rectangle('fill', 25, 42, (enemyPokemon.currentHP / enemyPokemon.maxHP) * 100, 6)

        -- Player Platform
        love.graphics.setColor(0.7, 0.8, 0.7, 1)
        love.graphics.ellipse('fill', 90, 145, 60, 20)
        -- Player Pokemon placeholder (Pikachu)
        love.graphics.setColor(0.95, 0.85, 0.15, 1)
        love.graphics.circle('fill', 90, 130, 20)

        -- Player Info Card
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH - 150, 105, 135, 52, 4, 4)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setFont(font)
        love.graphics.print(playerPokemon.name .. '  Lv.' .. playerPokemon.level, VIRTUAL_WIDTH - 145, 110)
        love.graphics.print('HP: ' .. playerPokemon.currentHP .. ' / ' .. playerPokemon.maxHP, VIRTUAL_WIDTH - 145, 122)

        -- Player HP Bar
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH - 145, 135, 110, 6)
        love.graphics.setColor(0.2, 0.8, 0.3, 1)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH - 145, 135, (playerPokemon.currentHP / playerPokemon.maxHP) * 110, 6)

        -- ========================================================
        -- CS50G ASSIGNMENT 7: EXPERIENCE BAR UI
        -- ========================================================
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH - 145, 144, 110, 4)
        love.graphics.setColor(0.2, 0.6, 1.0, 1) -- Blue EXP Bar
        local expPct = math.min(1.0, playerPokemon.currentExp / playerPokemon.expToLevel)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH - 145, 144, expPct * 110, 4)

        -- Bottom Dialogue & Menu Box
        love.graphics.setColor(0.1, 0.1, 0.15, 0.9)
        love.graphics.rectangle('fill', 10, VIRTUAL_HEIGHT - 50, VIRTUAL_WIDTH - 20, 44, 4, 4)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(font)
        love.graphics.printf(battleMessage, 20, VIRTUAL_HEIGHT - 44, VIRTUAL_WIDTH - 130, 'left')

        if gameState == 'battle_menu' then
            love.graphics.setColor(0.9, 0.9, 0.2, 1)
            love.graphics.print('[1] Fight', VIRTUAL_WIDTH - 90, VIRTUAL_HEIGHT - 44)
            love.graphics.print('[2] Run', VIRTUAL_WIDTH - 90, VIRTUAL_HEIGHT - 28)
        else
            love.graphics.setColor(0.7, 0.7, 0.7, 1)
            love.graphics.print('Press Space ->', VIRTUAL_WIDTH - 90, VIRTUAL_HEIGHT - 28)
        end
    end

    push:finish()
end
