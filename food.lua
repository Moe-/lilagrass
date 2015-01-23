class "Food" {
  x = 0;
  y = 0;
}

function Food:__init(image, x, y)
  self.x = x
  self.y = y
  self.image = image
  self.quad = love.graphics.newQuad(0, 0, 1024, 1024, self.image:getWidth(), self.image:getHeight())
end

function Food:draw()
  love.graphics.draw(self.image, self.quad, self.x, self.y)
end

function Food:update(dt)
  
end

function Food:getPosition()
  return self.x, self.y
end
