class "ShipPiece" {
  x = 0;
  y = 0;
}

function ShipPiece:__init(image, x, y)
  self.x = x
  self.y = y
  self.image = image
  self.quad = love.graphics.newQuad(0, 0, 1024, 1024, self.image:getWidth(), self.image:getHeight())
  self.width = self.image:getWidth()
  self.height = self.image:getHeight()
end

function ShipPiece:draw()
  love.graphics.setColor(0, 0, 0, 127)
  love.graphics.draw(self.image, self.quad, self.x + 2, self.y + 2)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.image, self.quad, self.x, self.y)
end

function ShipPiece:update(dt)
  
end

function ShipPiece:getPosition()
  return self.x + self.width / 2, self.y + self.height / 2
end
