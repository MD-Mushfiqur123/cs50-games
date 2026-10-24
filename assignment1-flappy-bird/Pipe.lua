-- Pipe Class
Class = require 'class'

Pipe = Class{}

PIPE_WIDTH = 70
PIPE_HEIGHT = 288
PIPE_SPEED = 60

function Pipe:init(orientation, y)
    self.x = VIRTUAL_WIDTH + 64
    self.y = y
    self.width = PIPE_WIDTH
    self.height = PIPE_HEIGHT
    self.orientation = orientation
end

function Pipe:update(dt)
    -- X coordinate updated by PipePair
end

function Pipe:render()
    love.graphics.setColor(0.2, 0.75, 0.2, 1)
    love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y), self.width, self.height)
    -- Pipe rim
    love.graphics.setColor(0.15, 0.6, 0.15, 1)
    if self.orientation == 'top' then
        love.graphics.rectangle('fill', math.floor(self.x - 2), math.floor(self.y + self.height - 16), self.width + 4, 16)
    else
        love.graphics.rectangle('fill', math.floor(self.x - 2), math.floor(self.y), self.width + 4, 16)
    end
    love.graphics.setColor(1, 1, 1, 1)
end
