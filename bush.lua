class "Bush" {
  x = 0;
  y = 0;
  regrow = 20;
}

function Bush:__init(image, x, y)
  self.x = x
  self.y = y
  self.image = image
  self.bushType = math.random(1, 3)
  self.berryType = math.random(1, 4)
  self.width = 24
  self.height = 32
  self:setQuad()
end

function Bush:draw()
	love.graphics.draw(self.image, self.quad, self.x, self.y)
end

function Bush:setQuad()
  self.quad = love.graphics.newQuad((self.bushType - 1) * self.width, 2 * self.height, self.width, self.height, self.image:getWidth(), self.image:getHeight())
end

function Bush:update(dt)
  if self.bushType == 2 then
    self.regrow = self.regrow - dt
    if self.regrow < 0 then
      self.bushType = 1
      self:setQuad()
    end
  end
end

function Bush:getPosition()
  return self.x + self.width / 2, self.y + self.height / 2
end

function Bush:takeBerries()
  if self.bushType == 1 then
    self.regrow = 20
    self.bushType = 2
    self:setQuad()
    return true
  end
  return false
end

function Bush:getBerryType()
  if self.berryType == 1 then
    return 'tasty'
  elseif self.berryType == 2 then
    return 'poison'
  elseif self.berryType == 3 then
    return 'spicy'
  else
    return 'useless'
  end
end
