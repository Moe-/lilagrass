class "Food" {
  x = 0;
  y = 0;
  scale = 0.5;
}

function Food:__init(image, x, y)
  self.x = x
  self.y = y
  self.image = image
  self.quad = love.graphics.newQuad(0, 0, 1024, 1024, self.scale * self.image:getWidth(), self.scale * self.image:getHeight())
  self.width = self.image:getWidth()
  self.height = self.image:getHeight()
end

function Food:draw()
  love.graphics.draw(self.image, self.quad, self.x, self.y)
end

function Food:update(dt)
  
end

function Food:getPosition()
  return self.x + self.scale * self.width / 2, self.y + self.scale * self.height / 2
end
