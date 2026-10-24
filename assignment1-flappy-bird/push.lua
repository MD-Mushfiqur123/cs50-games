-- Push is a library that will allow us to draw our game at a virtual
-- resolution, almost like we're in a retro console.
--
-- https://github.com/Ulydev/push

local push = {
  defaults = {
    fullscreen = false,
    resizable = false,
    pixelperfect = false,
    highdpi = true,
    canvas = true
  }
}
setmetatable(push, push)

function push:applyStyle(style)
  love.graphics.setDefaultFilter(style, style)
end

function push:setupScreen(WWIDTH, WHEIGHT, RWIDTH, RHEIGHT, df)
  df = df or {}
  self._RWIDTH = RWIDTH
  self._RHEIGHT = RHEIGHT
  self._WWIDTH = WWIDTH
  self._WHEIGHT = WHEIGHT

  self._SETTINGS = {
    fullscreen = df.fullscreen or self.defaults.fullscreen,
    resizable = df.resizable or self.defaults.resizable,
    pixelperfect = df.pixelperfect or self.defaults.pixelperfect,
    highdpi = df.highdpi or self.defaults.highdpi,
    canvas = df.canvas or self.defaults.canvas
  }

  self:initValues()
  self:applyStyle("nearest")

  love.window.setMode(self._RWIDTH, self._RHEIGHT, {
    fullscreen = self._SETTINGS.fullscreen,
    resizable = self._SETTINGS.resizable,
    highdpi = self._SETTINGS.highdpi
  })

  self:setupCanvas({ "default" })
end

function push:setupCanvas(canvases)
  if not self._SETTINGS.canvas then return end
  table.insert(canvases, { name = "_render" })
  self._canvas = true
  self.canvases = {}
  for _, c in ipairs(canvases) do
    self.canvases[c.name] = {
      canvas = love.graphics.newCanvas(self._WWIDTH, self._WHEIGHT),
      shader = c.shader
    }
  end
end

function push:initValues()
  self._SCALE = {
    x = self._RWIDTH / self._WWIDTH,
    y = self._RHEIGHT / self._WHEIGHT
  }
  if self._SETTINGS.pixelperfect then
    local scale = math.min(self._SCALE.x, self._SCALE.y)
    self._SCALE.x = math.floor(scale)
    self._SCALE.y = math.floor(scale)
  end
  self._OFFSET = {
    x = (self._RWIDTH - self._WWIDTH * self._SCALE.x) / 2,
    y = (self._RHEIGHT - self._WHEIGHT * self._SCALE.y) / 2
  }
end

function push:resize(w, h)
  self._RWIDTH = w
  self._RHEIGHT = h
  self:initValues()
end

function push:start()
  if self._canvas then
    love.graphics.push()
    love.graphics.setCanvas(self.canvases["_render"].canvas)
    love.graphics.clear()
  else
    love.graphics.push()
    love.graphics.translate(self._OFFSET.x, self._OFFSET.y)
    love.graphics.scale(self._SCALE.x, self._SCALE.y)
  end
end

function push:finish()
  if self._canvas then
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas()
    love.graphics.draw(
      self.canvases["_render"].canvas,
      self._OFFSET.x,
      self._OFFSET.y,
      0,
      self._SCALE.x,
      self._SCALE.y
    )
  else
    love.graphics.pop()
  end
end

function push:toReal(x, y)
  return (x - self._OFFSET.x) / self._SCALE.x, (y - self._OFFSET.y) / self._SCALE.y
end

return push
