class "Football" {
  x = 0;
  y = 0;
  dx = 0;
  dy = 0;
  force = 0;
  scale = 0.5;
}

function Football:__init(x, y)
  self.x = x
  self.y = y
  self.image = love.graphics.newImage("gfx/football.png")
  self.quad = love.graphics.newQuad(0, 0, 1024, 1024, self.scale * self.image:getWidth(), self.scale * self.image:getHeight())
  self.width = self.image:getWidth()
  self.height = self.image:getHeight()
end

function Football:draw()
  love.graphics.draw(self.image, self.quad, self.x, self.y)
end

function Football:update(dt)
  self.x = self.x + self.force * self.dx * dt
  self.y = self.y + self.force * self.dy * dt
  
  if self.force < 1 then
    self.force = 0
  else
    self.force = self.force * 0.975
  end
end

function Football:getPosition()
  return self.x + self.scale * self.width / 2, self.y + self.scale * self.height / 2
end

function Football:kick(dirx, diry)
  len = getLength(dirx, diry)
  self.dx = dirx / len
  self.dy = diry / len
  self.force = 100
end