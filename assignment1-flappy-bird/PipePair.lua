-- PipePair Class
-- CS50 Assignment 1 Requirement:
-- 1. Randomized gap height between pipes
Class = require 'class'
require 'Pipe'

PipePair = Class{}

function PipePair:init(y)
    self.x = VIRTUAL_WIDTH + 32
    self.score = false
    self.remove = false

    -- Assignment 1 feature: Randomized gap height between top and bottom pipe
    -- Normal fixed gap was ~90. We randomize gap height between 75 and 115.
    self.gap = math.random(75, 115)

    self.y = y

    -- Top pipe
    self.pipes = {
        ['upper'] = Pipe('top', self.y),
        ['lower'] = Pipe('bottom', self.y + PIPE_HEIGHT + self.gap)
    }
end

function PipePair:update(dt)
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        self.pipes['upper'].x = self.x
        self.pipes['lower'].x = self.x
    else
        self.remove = true
    end
end

function PipePair:render()
    for k, pipe in pairs(self.pipes) do
        pipe:render()
    end
end
