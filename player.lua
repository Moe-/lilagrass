class "Player" {
  x = 0;
  y = 0;
  dx = 0;
  dy = 0;
}

function Player:__init(x, y)
  self.x = x
  self.y = y
  self.image = love.graphics.newImage("gfx/player.png")
  self.quad = love.graphics.newQuad(0, 0, 64, 128, self.image:getWidth(), self.image:getHeight())
end

function Player:draw()
  love.graphics.draw(self.image, self.quad, self.x, self.y)
end

function Player:update(dt)
  self.x = self.x + 15 * self.dx * dt
  self.y = self.y + 15 * self.dy * dt
end

function Player:keypressed(key)
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
