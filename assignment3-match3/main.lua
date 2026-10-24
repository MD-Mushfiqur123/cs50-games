-- CS50 Games - Assignment 3: Match 3
-- Requirements:
-- 1. Guaranteed valid matches on swap: Only allow tile swap if it results in at least one match of 3 or more. Otherwise swap back!
-- 2. Shiny / Special Tiles: Tiles that, when matched, clear their entire row or column.
-- 3. Guaranteed initial board has at least one valid match available.

push = require 'push'
Class = require 'class'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

BOARD_SIZE = 8
TILE_SIZE = 32
BOARD_OFFSET_X = (VIRTUAL_WIDTH - (BOARD_SIZE * TILE_SIZE)) / 2
BOARD_OFFSET_Y = (VIRTUAL_HEIGHT - (BOARD_SIZE * TILE_SIZE)) / 2

Tile = Class{}
function Tile:init(x, y, color, variety, shiny)
    self.gridX = x
    self.gridY = y
    self.color = color or math.random(6)
    self.variety = variety or 1
    -- CS50 Requirement: Shiny / Special Tile (clears entire row or column)
    self.shiny = shiny or (math.random(12) == 1)
end

function Tile:render(boardX, boardY, isSelected)
    local drawX = boardX + (self.gridX - 1) * TILE_SIZE
    local drawY = boardY + (self.gridY - 1) * TILE_SIZE

    local colors = {
        {0.9, 0.2, 0.2}, -- Red
        {0.2, 0.8, 0.2}, -- Green
        {0.2, 0.5, 0.95}, -- Blue
        {0.95, 0.8, 0.1}, -- Yellow
        {0.75, 0.2, 0.85}, -- Purple
        {0.95, 0.5, 0.15} -- Orange
    }

    local c = colors[self.color]
    love.graphics.setColor(c[1], c[2], c[3], 1)
    love.graphics.rectangle('fill', drawX + 2, drawY + 2, TILE_SIZE - 4, TILE_SIZE - 4, 6, 6)

    -- If Shiny, render radiant animated border / star
    if self.shiny then
        local pulse = math.sin(love.timer.getTime() * 8) * 0.5 + 0.5
        love.graphics.setColor(1, 1, 1, 0.7 + pulse * 0.3)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle('line', drawX + 1, drawY + 1, TILE_SIZE - 2, TILE_SIZE - 2, 6, 6)
        -- Shiny center jewel
        love.graphics.circle('fill', drawX + TILE_SIZE/2, drawY + TILE_SIZE/2, 4)
    end

    if isSelected then
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle('line', drawX, drawY, TILE_SIZE, TILE_SIZE, 4, 4)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Board Class
Board = Class{}
function Board:init()
    self.tiles = {}
    self:initializeTiles()
end

function Board:initializeTiles()
    repeat
        for y = 1, BOARD_SIZE do
            self.tiles[y] = {}
            for x = 1, BOARD_SIZE do
                self.tiles[y][x] = Tile(x, y, math.random(6), 1)
            end
        end
        -- Remove any initial matches so board starts clean
        while #self:calculateMatches() > 0 do
            for y = 1, BOARD_SIZE do
                for x = 1, BOARD_SIZE do
                    self.tiles[y][x] = Tile(x, y, math.random(6), 1)
                end
            end
        end
    until self:hasAvailableMatches() -- Ensure the player can actually make moves!
end

function Board:calculateMatches()
    local matches = {}
    local matchNum = 1

    -- Horizontal matches
    for y = 1, BOARD_SIZE do
        local colorToMatch = self.tiles[y][1].color
        matchNum = 1

        for x = 2, BOARD_SIZE do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color
                if matchNum >= 3 then
                    local match = {}
                    local rowHasShiny = false
                    for x2 = x - 1, x - matchNum, -1 do
                        table.insert(match, self.tiles[y][x2])
                        if self.tiles[y][x2].shiny then rowHasShiny = true end
                    end
                    -- If any matched tile is shiny, clear the ENTIRE row!
                    if rowHasShiny then
                        match = {}
                        for fullX = 1, BOARD_SIZE do
                            table.insert(match, self.tiles[y][fullX])
                        end
                    end
                    table.insert(matches, match)
                end
                matchNum = 1
            end
        end

        if matchNum >= 3 then
            local match = {}
            local rowHasShiny = false
            for x = BOARD_SIZE, BOARD_SIZE - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
                if self.tiles[y][x].shiny then rowHasShiny = true end
            end
            if rowHasShiny then
                match = {}
                for fullX = 1, BOARD_SIZE do
                    table.insert(match, self.tiles[y][fullX])
                end
            end
            table.insert(matches, match)
        end
    end

    -- Vertical matches
    for x = 1, BOARD_SIZE do
        local colorToMatch = self.tiles[1][x].color
        matchNum = 1

        for y = 2, BOARD_SIZE do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color
                if matchNum >= 3 then
                    local match = {}
                    local colHasShiny = false
                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                        if self.tiles[y2][x].shiny then colHasShiny = true end
                    end
                    -- If any matched tile is shiny, clear the ENTIRE column!
                    if colHasShiny then
                        match = {}
                        for fullY = 1, BOARD_SIZE do
                            table.insert(match, self.tiles[fullY][x])
                        end
                    end
                    table.insert(matches, match)
                end
                matchNum = 1
            end
        end

        if matchNum >= 3 then
            local match = {}
            local colHasShiny = false
            for y = BOARD_SIZE, BOARD_SIZE - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
                if self.tiles[y][x].shiny then colHasShiny = true end
            end
            if colHasShiny then
                match = {}
                for fullY = 1, BOARD_SIZE do
                    table.insert(match, self.tiles[fullY][x])
                end
            end
            table.insert(matches, match)
        end
    end

    return matches
end

-- Check if any swap creates a valid match (Guaranteed playable board)
function Board:hasAvailableMatches()
    for y = 1, BOARD_SIZE do
        for x = 1, BOARD_SIZE do
            -- Try swapping with right tile
            if x < BOARD_SIZE then
                self:swap(x, y, x + 1, y)
                local matches = self:calculateMatches()
                self:swap(x, y, x + 1, y) -- swap back
                if #matches > 0 then return true end
            end
            -- Try swapping with bottom tile
            if y < BOARD_SIZE then
                self:swap(x, y, x, y + 1)
                local matches = self:calculateMatches()
                self:swap(x, y, x, y + 1) -- swap back
                if #matches > 0 then return true end
            end
        end
    end
    return false
end

function Board:swap(x1, y1, x2, y2)
    local t1 = self.tiles[y1][x1]
    local t2 = self.tiles[y2][x2]
    self.tiles[y1][x1] = t2
    self.tiles[y2][x2] = t1
    t1.gridX, t1.gridY = x2, y2
    t2.gridX, t2.gridY = x1, y1
end

function Board:removeMatches(matches)
    for _, match in ipairs(matches) do
        for _, tile in ipairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end
end

function Board:collapse()
    for x = 1, BOARD_SIZE do
        local emptyY = nil
        for y = BOARD_SIZE, 1, -1 do
            local tile = self.tiles[y][x]
            if not tile and not emptyY then
                emptyY = y
            elseif tile and emptyY then
                self.tiles[emptyY][x] = tile
                tile.gridY = emptyY
                self.tiles[y][x] = nil
                emptyY = emptyY - 1
            end
        end

        -- Fill new tiles from the top
        for y = BOARD_SIZE, 1, -1 do
            if not self.tiles[y][x] then
                self.tiles[y][x] = Tile(x, y, math.random(6), 1)
            end
        end
    end
end

-- Main Game Variables
local board
local cursorX, cursorY = 1, 1
local selectedTile = nil
local score = 0
local timer = 60
local gameOver = false

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Match 3 - CS50G Assignment 3')
    math.randomseed(os.time())

    smallFont = love.graphics.newFont(12)
    mediumFont = love.graphics.newFont(18)
    largeFont = love.graphics.newFont(28)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    board = Board()
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if gameOver then
        if key == 'enter' or key == 'return' or key == 'space' then
            score = 0
            timer = 60
            gameOver = false
            board = Board()
        end
        return
    end

    -- Cursor navigation
    if key == 'up' or key == 'w' then
        cursorY = math.max(1, cursorY - 1)
    elseif key == 'down' or key == 's' then
        cursorY = math.min(BOARD_SIZE, cursorY + 1)
    elseif key == 'left' or key == 'a' then
        cursorX = math.max(1, cursorX - 1)
    elseif key == 'right' or key == 'd' then
        cursorX = math.min(BOARD_SIZE, cursorX + 1)
    elseif key == 'space' or key == 'enter' or key == 'return' then
        if not selectedTile then
            selectedTile = {x = cursorX, y = cursorY}
        else
            -- Check adjacency
            local dx = math.abs(cursorX - selectedTile.x)
            local dy = math.abs(cursorY - selectedTile.y)
            if (dx == 1 and dy == 0) or (dx == 0 and dy == 1) then
                -- Perform test swap
                board:swap(selectedTile.x, selectedTile.y, cursorX, cursorY)
                local matches = board:calculateMatches()

                -- CS50 Requirement: Revert swap if NO match occurs!
                if #matches == 0 then
                    board:swap(selectedTile.x, selectedTile.y, cursorX, cursorY) -- Revert
                else
                    -- Valid match! Resolve cascading matches
                    while #matches > 0 do
                        for _, match in ipairs(matches) do
                            score = score + #match * 50
                            timer = math.min(60, timer + #match)
                        end
                        board:removeMatches(matches)
                        board:collapse()
                        matches = board:calculateMatches()
                    end

                    -- Check if board has valid moves left; reshuffle if deadlocked
                    if not board:hasAvailableMatches() then
                        board:initializeTiles()
                    end
                end
            end
            selectedTile = nil
        end
    end
end

function love.update(dt)
    if not gameOver then
        timer = timer - dt
        if timer <= 0 then
            timer = 0
            gameOver = true
        end
    end
end

function love.draw()
    push:start()
    love.graphics.clear(35/255, 30/255, 45/255, 1)

    -- Render Board Background
    love.graphics.setColor(20/255, 15/255, 25/255, 0.8)
    love.graphics.rectangle('fill', BOARD_OFFSET_X - 8, BOARD_OFFSET_Y - 8,
        (BOARD_SIZE * TILE_SIZE) + 16, (BOARD_SIZE * TILE_SIZE) + 16, 8, 8)

    -- Render Tiles
    for y = 1, BOARD_SIZE do
        for x = 1, BOARD_SIZE do
            local t = board.tiles[y][x]
            if t then
                local isSel = (selectedTile and selectedTile.x == x and selectedTile.y == y)
                t:render(BOARD_OFFSET_X, BOARD_OFFSET_Y, isSel)
            end
        end
    end

    -- Render Cursor
    local cx = BOARD_OFFSET_X + (cursorX - 1) * TILE_SIZE
    local cy = BOARD_OFFSET_Y + (cursorY - 1) * TILE_SIZE
    love.graphics.setColor(1, 1, 0, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', cx, cy, TILE_SIZE, TILE_SIZE, 4, 4)

    -- HUD
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(largeFont)
    love.graphics.print('MATCH 3', 20, 20)

    love.graphics.setFont(mediumFont)
    love.graphics.print('Score: ' .. tostring(score), 20, 70)
    love.graphics.print('Time: ' .. string.format('%.1f', timer) .. 's', 20, 100)

    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf("Controls:\nWASD/Arrows: Move\nSpace/Enter: Select\nOnly valid swaps allowed!\nShiny tiles wipe entire rows/columns!", 20, 160, 110)

    if gameOver then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(largeFont)
        love.graphics.printf('GAME OVER', 0, 100, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(mediumFont)
        love.graphics.printf('Final Score: ' .. tostring(score), 0, 140, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to Restart', 0, 180, VIRTUAL_WIDTH, 'center')
    end

    push:finish()
end
