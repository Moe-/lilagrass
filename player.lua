class "Player" {
  x = 0;
  y = 0;
  dx = 0;
  dy = 0;
  air = 100;
  hunger = 100;
  thurst = 100;
  dead = false;
}

function Player:__init(x, y)
  self.x = x
  self.y = y
  self.image = love.graphics.newImage("gfx/player.png")
  self.quad = love.graphics.newQuad(0, 0, 64, 128, self.image:getWidth(), self.image:getHeight())
  self.width = self.image:getWidth()
  self.height = self.image:getHeight()
end

function Player:draw()
  if self.dead then
    love.graphics.setColor(192, 0, 0, 255);
    love.graphics.circle("fill", self.x + self.width / 2, self.y + self.height / 2 + 20, 50, 100); -- Draw white circle with 100 segments.
  end
  love.graphics.draw(self.image, self.quad, self.x, self.y)
  
  love.graphics.setColor(0, 0, 255, 255)
  love.graphics.print(tostring(self.air), self.x, self.y - 50)
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.print(tostring(self.hunger), self.x, self.y - 32)
  love.graphics.setColor(0, 255, 255, 255)
  love.graphics.print(tostring(self.thurst), self.x, self.y - 16)
  love.graphics.setColor(255, 255, 255, 255)
end

function Player:update(dt)
  self.x = self.x + 25 * self.dx * dt
  self.y = self.y + 25 * self.dy * dt
  if self.dead then
    return
  end
  self.air = self.air - 5 * dt
  self.thurst = self.thurst - 5 * dt
  self.hunger = self.hunger - 2 * dt
  if self.air < 0 or self.thurst < 0 or self.hunger < 0 then
    self.dead = true
    self.dx = 0
    self.dy = 0
  end
end

function Player:keypressed(key)
  if self.dead then
    return
  end

  if key == 'w' then
    self.dy = -1
  elseif key == 's' then
    self.dy = 1
  end
  if key == 'a' then
    self.dx = -1
  elseif key == 'd' then
    self.dx = 1
  end
end

function Player:keyreleased(key)
  if self.dead then
    return
  end

  if key == 'w' and not love.keypressed('s') then
    self.dy = 0
  elseif key == 's' and not love.keypressed('w') then
    self.dy = 0
  end
  if key == 'a' and not love.keypressed('d') then
    self.dx = 0
  elseif key == 'd' and not love.keypressed('a') then
    self.dx = 0
  end
end

function Player:getPosition()
  return self.x + self.width / 2, self.y + self.height / 2
end

function Player:eat()
  self.hunger = self.hunger + 20
  if self.hunger > 100 then
    self.hunger = 100
  end
end

function Player:breath()
  self.air = self.air + 20
  if self.air > 100 then
    self.air = 100
  end
end

function Player:drink()
  self.thurst = self.thurst + 20
  if self.thurst > 100 then
    self.thurst = 100
  end
end
