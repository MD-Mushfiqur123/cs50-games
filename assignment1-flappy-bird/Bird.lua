-- Bird Class
Class = require 'class'

Bird = Class{}

local GRAVITY = 20

function Bird:init()
    self.image = nil -- rendered as retro procedural bird if sprite is absent
    self.width = 38
    self.height = 24

    self.x = VIRTUAL_WIDTH / 2 - (self.width / 2)
    self.y = VIRTUAL_HEIGHT / 2 - (self.height / 2)

    self.dy = 0
end

function Bird:collides(pipe)
    if (self.x + 2) + (self.width - 4) >= pipe.x and self.x + 2 <= pipe.x + PIPE_WIDTH then
        if (self.y + 2) + (self.height - 4) >= pipe.y and self.y + 2 <= pipe.y + PIPE_HEIGHT then
            return true
        end
    end
    return false
end

function Bird:update(dt)
    self.dy = self.dy + GRAVITY * dt

    if love.keyboard.wasPressed('space') or love.mouse.wasPressed(1) then
        self.dy = -5
    end

    self.y = self.y + self.dy
end

function Bird:render()
    love.graphics.setColor(1, 0.8, 0.2, 1)
    love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y), self.width, self.height, 4, 4)
    -- Eye and beak
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle('fill', math.floor(self.x + 28), math.floor(self.y + 7), 4)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.circle('fill', math.floor(self.x + 30), math.floor(self.y + 7), 2)
    love.graphics.setColor(1, 0.4, 0.1, 1)
    love.graphics.polygon('fill', self.x + 34, self.y + 12, self.x + 42, self.y + 15, self.x + 34, self.y + 18)
    love.graphics.setColor(1, 1, 1, 1)
end
