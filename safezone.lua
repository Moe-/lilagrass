class "SafeZone" {
  x = 0;
  y = 0;
  size = 0;
}

function SafeZone:__init(image, x, y, size)
  self.x = x
  self.y = y
  self.size = size
  self.image = image
  self.quad = love.graphics.newQuad(0, 0, size, size, self.image:getWidth(), self.image:getHeight())
end

function SafeZone:draw()
  love.graphics.draw(self.image, self.quad, self.x, self.y)
end

function SafeZone:update(dt)
  
end

function SafeZone:inside(x, y)
  if x > self.x and x < self.x + self.size and y > self.y and y < self.y + self.size then
      return true
  end
  return false
end
