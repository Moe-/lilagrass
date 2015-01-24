class "Player" {
  x = 0;
  y = 0;
  dx = 0;
  dy = 0;
  air = 100;
  hunger = 100;
  thurst = 100;
  dead = false;
  --direction: 0=up; 1=right; 2=down; 3=left
  walkingState = 0; -- 0=standing; 1=walking;
  currentDirection = 0;
  dWalking = 0;
  
}

function Player:__init(x, y)
  self.x = x
  self.y = y
  self.image = love.graphics.newImage("gfx/hero.png")
  self.quad = love.graphics.newQuad(24, 32, 24, 32, self.image:getWidth(), self.image:getHeight())
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
  self.x = self.x + 15 * self.dx * dt
  self.y = self.y + 15 * self.dy * dt
  if self.dead then
    return
  end
  self.air = self.air - 5 * dt
  self.thurst = self.thurst - 5 * dt
  self.hunger = self.hunger - 2 * dt
  if self.air < 0 or self.thurst < 0 or self.hunger < 0 then
    self.dead = true
  end
  self.dWalking = self.dWalking + dt
  local direction
  if self.dx ==	-1 then
	direction = 3
  elseif self.dx == 1 then
	direction = 1
  end
  if self.dy == -1 then
	direction = 0
  elseif self.dy == 1 then
	direction = 2
  end
  if self.currentDirection == direction and self.dWalking > 0.5 then
	print(self.dWalking)
	self.dWalking = self.dWalking - 0.5
	if self.walkingState < 3 then
		self.walkingState = self.walkingState + 1
	else
		self.walkingState = 0
	end
  end
  self:setDirection(direction)
  self.currentDirection = direction
	
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

function Player:setDirection(direction)
	
	if direction == 0 then --up
		if self.walkingState == 0 or self.walkingState == 2 then
			self.quad:setViewport(0, 32, 24, 32)
		elseif self.walkingState == 1 then
			self.quad:setViewport(0, 32, 24, 32)
		elseif self.walkingState == 3 then
			self.quad:setViewport(0, 32, 24, 32)
		end
	elseif direction == 1 then --right
		if self.walkingState == 0 or self.walkingState == 2 then
			self.quad:setViewport(24, 32, 24, 32)
		elseif self.walkingState == 1 then
			self.quad:setViewport(0, 64, 24, 32)
		elseif self.walkingState == 3 then
			self.quad:setViewport(24, 64, 24, 32)
		end
	elseif direction == 2 then --down
		if self.walkingState == 0 or self.walkingState == 2 then
			self.quad:setViewport(0, 0, 24, 32)
		elseif self.walkingState == 1 then
			self.quad:setViewport(0, 0, 24, 32)
		elseif self.walkingState == 3 then
			self.quad:setViewport(0, 0, 24, 32)
		end
	elseif direction == 3 then --left
		if self.walkingState == 0 or self.walkingState == 2 then
			self.quad:setViewport(24, 0, 24, 32)
		elseif self.walkingState == 1 then
			self.quad:setViewport(48, 0, 24, 32)
		elseif self.walkingState == 3 then
			self.quad:setViewport(48, 32, 24, 32)
		end
	end
end
