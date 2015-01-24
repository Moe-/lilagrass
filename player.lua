class "Player" {
  x = 0;
  y = 0;
  dx = 0;
  dy = 0;
  offsetx = 0;
  offsety = 0;
  air = 100;
  hunger = 100;
  thurst = 100;
  dead = false;
  --direction: 0=up; 1=right; 2=down; 3=left
  walkingState = 0; -- 0/2=standing; 1/3=walking
  currentDirection = 0;
  dWalking = 0;
  showText = "";
  textDisplayTime = 0;
  partsLeft = 0;
  speed = 100;
}

function Player:__init(x, y, partsToFind, mapWidth, mapHeight)
  self.x = x
  self.y = y
  self.mapWidth = mapWidth
  self.mapHeight = mapHeight
  self.image = love.graphics.newImage("gfx/hero.png")
  self.quad = love.graphics.newQuad(0, 0, 24, 32, self.image:getWidth(), self.image:getHeight())
  self.width = 24--self.image:getWidth()
  self.height = 32--self.image:getHeight()
  self.partsLeft = partsToFind
end

function Player:draw()
  if self.dead then
    love.graphics.setColor(192, 0, 0, 255);
    love.graphics.circle("fill", self.x + self.width / 2, self.y + self.height / 2 + 20, 50, 100); -- Draw white circle with 100 segments.
  end
  love.graphics.draw(self.image, self.quad, self.x, self.y)
  
  if self.textDisplayTime > 0 then
    love.graphics.setColor(0, 192, 255, 255)
    love.graphics.print(self.showText, self.x-125, self.y - 16)
  end
  --love.graphics.setColor(0, 0, 255, 255)
  --love.graphics.print(tostring(self.air), self.x, self.y - 50)
  --love.graphics.setColor(255, 0, 0, 255)
  --love.graphics.print(tostring(self.hunger), self.x, self.y - 32)
  --love.graphics.setColor(0, 255, 255, 255)
  --love.graphics.print(tostring(self.thurst), self.x, self.y - 16)
  love.graphics.setColor(255, 255, 255, 255)
end

function Player:update(dt, safe)
  local offsetx = self.speed * self.dx * dt
  local offsety = self.speed * self.dy * dt
  self.x = self.x + offsetx
  self.y = self.y + offsety
  
  if self.x < 0 then
    self.x = 0
  end
  
  if self.x + self.width > self.mapWidth then
    self.x = self.mapWidth - self.width
  end
  self.offsetx = offsetx
  
  if self.y < 0 then
    self.y = 0
  end
  
  if self.y + self.height > self.mapHeight then
    self.y = self.mapHeight - self.height
  end
  self.offsety = offsety

  if self.dead then
    return
  end
  
  if safe == false then
    self.air = self.air - 1.5 * dt
    self.thurst = self.thurst - 1 * dt
    self.hunger = self.hunger - 0.75 * dt
  end
  
  if self.air < 0 or self.thurst < 0 or self.hunger < 0 then
    self:die()
    self.dx = 0
    self.dy = 0
  end
  gGui:update(self.hunger, self.thurst, self.air)
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
  if self.currentDirection == direction and self.dWalking > 0.15 then
	self.dWalking = self.dWalking - 0.15
	if self.walkingState < 3 then
		self.walkingState = self.walkingState + 1
	else
		self.walkingState = 0
	end
  end
  self:setDirection(direction)
  self.currentDirection = direction
	
  self.textDisplayTime = self.textDisplayTime - dt
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
			self.quad:setViewport(24, 32, 24, 32)
		elseif self.walkingState == 3 then
			self.quad:setViewport(48, 32, 24, 32)
		end
		lightHero.setDirection(math.pi * 0)
	elseif direction == 1 then --right
		if self.walkingState == 0 or self.walkingState == 2 then
			self.quad:setViewport(0, 96, 24, 32)
		elseif self.walkingState == 1 then
			self.quad:setViewport(24, 96, 24, 32)
		elseif self.walkingState == 3 then
			self.quad:setViewport(48, 96, 24, 32)
		end
		lightHero.setDirection(math.pi * 1.5)
	elseif direction == 2 then --down
		if self.walkingState == 0 or self.walkingState == 2 then
			self.quad:setViewport(0, 0, 24, 32)
		elseif self.walkingState == 1 then
			self.quad:setViewport(24, 0, 24, 32)
		elseif self.walkingState == 3 then
			self.quad:setViewport(48, 0, 24, 32)
		end
		lightHero.setDirection(math.pi * 1.0)
	elseif direction == 3 then --left
		if self.walkingState == 0 or self.walkingState == 2 then
			self.quad:setViewport(0, 64, 24, 32)
		elseif self.walkingState == 1 then
			self.quad:setViewport(24, 64, 24, 32)
		elseif self.walkingState == 3 then
			self.quad:setViewport(48, 64, 24, 32)
		end
		lightHero.setDirection(math.pi * 0.5)
	end
end
	
function Player:getPosition()
  return self.x + self.width / 2, self.y + self.height / 2
end

function Player:eat(v)
  self.hunger = self.hunger + 20
  if self.hunger > 100 then
    self.hunger = 100
  end
end

function Player:breath(v)
  self.air = self.air + 20
  if self.air > 100 then
    self.air = 100
  end
end

function Player:drink(v)
  self.thurst = self.thurst + 20
  if self.thurst > 100 then
    self.thurst = 100
  end
end

function Player:getPiece(v)
  self.partsLeft = self.partsLeft - 1
  self.textDisplayTime = 7.5
  if self.partsLeft == 0 then
    self.showText = "Let's go home!"
  else
    self.showText = "I will be home again soon!"
  end
end

function Player:die()
  if not self:isRescued() then
    self.dead = true
	self.quad:setViewport(0, 128, 24, 32)
  end
end

function Player:isDead()
  return self.dead
end

function Player:isRescued()
  if self.partsLeft == 0 then
    return true
  end
  return false
end

function Player:getOffset()
  return self.offsetx, self.offsety
end
