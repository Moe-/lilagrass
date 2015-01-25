class "Player" {
  x = 0;
  y = 0;
  lastX = 0;
  lastY = 0;
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
  thurstFactor = 1;
  airFactor = 1.5;
  hungerFactor = 0.75;
  talkNext = 0;
}

function Player:__init(x, y, partsToFind, mapWidth, mapHeight)
  self.x = x
  self.y = y
  self.lastX = x
  self.lastY = y
  self.mapWidth = mapWidth
  self.mapHeight = mapHeight
  self.image = love.graphics.newImage("gfx/hero.png")
  self.quad = love.graphics.newQuad(0, 0, 24, 32, self.image:getWidth(), self.image:getHeight())
  self.width = 24--self.image:getWidth()
  self.height = 32--self.image:getHeight()
  self.partsLeft = partsToFind
  self.poisoned = false
end

function Player:draw()
  love.graphics.draw(self.image, self.quad, self.x, self.y)
  
  if self.textDisplayTime > 0 then
    love.graphics.setColor(0, 192, 255, 255)
    love.graphics.printf(self.showText, self.x - 200, self.y - 16, 400, "center")
  end
  --love.graphics.setColor(0, 0, 255, 255)
  --love.graphics.print(tostring(self.air), self.x, self.y - 50)
  --love.graphics.setColor(255, 0, 0, 255)
  --love.graphics.print(tostring(self.hunger), self.x, self.y - 32)
  --love.graphics.setColor(0, 255, 255, 255)
  --love.graphics.print(tostring(self.thurst), self.x, self.y - 16)
  love.graphics.setColor(255, 255, 255, 255)
end

function Player:drawText()
  if self.textDisplayTime > 0 then
    love.graphics.setColor(0, 192, 255, 255)
    love.graphics.printf(self.showText, self.x - 200, self.y - 16, 400, "center")
  end
  love.graphics.setColor(255, 255, 255, 255)
end

function Player:update(dt, safe, bushes)
  local offsetx = self.speed * self.dx * dt
  local offsety = self.speed * self.dy * dt
  
  local playerBlocked = false
  
  for i, v in pairs(bushes) do
    local bx, by = v:getPosition()
    local dist = getDistance(self.x + offsetx + self.width / 2, self.y + offsety + self.height / 2, bx, by)
    if dist < 16 then
      playerBlocked = true
    end
  end
  
  if not playerBlocked then
    self.x = self.x + offsetx
    self.y = self.y + offsety
  end
  
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
  
  if self.poisoned then
    self.air = 0.95 * self.air
  end
  
  if safe == false then
    self.air = self.air - self.airFactor * dt
    self.thurst = self.thurst - self.thurstFactor * dt
    self.hunger = self.hunger - self.hungerFactor * dt
  end
  
  if self.air <= 0 or self.thurst <= 0 or self.hunger <= 0 then
    self:die()
    self.dx = 0
    self.dy = 0
	self.air = 0
  end
  if self.air <= 0 then
    self:die()
    self.dx = 0
    self.dy = 0
	self.air = 0
  end
  if self.thurst <= 0 then
    self:die()
    self.dx = 0
    self.dy = 0
	self.thurst = 0
  end
  if self.hunger <= 0 then
    self:die()
    self.dx = 0
    self.dy = 0
	self.hunger = 0
  end
  gGui:update(self.hunger, self.thurst, self.air, self.partsLeft)
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
	self.dWalking = self.dWalking - 0.12
	if self.walkingState < 3 then
		self.walkingState = self.walkingState + 1
	else
		self.walkingState = 0
	end
  end
  self:setDirection(direction)
  self.currentDirection = direction
	
  self.textDisplayTime = self.textDisplayTime - dt
  
  self:talk(dt)
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

  if key == 'w' then
    if not love.keyboard.isDown('s') then
      self.dy = 0
    else
      self.dy = 1
    end
  elseif key == 's' then
    if not love.keyboard.isDown('w') then
      self.dy = 0
    else
      self.dy = -1
    end
  end
  
  if key == 'a' then
    if not love.keyboard.isDown('d') then
      self.dx = 0
    else
      self.dx = 1
    end
  elseif key == 'd' then
    if not love.keyboard.isDown('a') then
      self.dx = 0
    else
      self.dx = -1
    end
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

function Player:bathing(v, dt)
  --self.thurst = self.thurst - 1.5 * self.thurstFactor * dt
  --if self.thurst > 100 then
  --  self.thurst = 100
  --end
  
  self.textDisplayTime = 7.5
  local wType = v:getType()
  if wType == 'salt' then
    self.thurst = self.thurst - 1.5 * self.thurstFactor * dt
    self.showText = "Delicious! Salty water!"
  elseif wType == 'poison' then
    self.thurst = self.thurst - 15 * self.thurstFactor * dt
    self.showText = "What the hell is this?!?"
  else
    self.thurst = self.thurst + 1.5 * self.thurstFactor * dt
    self.showText = "Like on good old earth!"
  end
end

function Player:useBush(v, dt)
  if v:takeBerries() then
    self.textDisplayTime = 7.5
    
    local bType = v:getBerryType()
    if bType == 'tasty' then
      self.hunger = self.hunger + 15 * self.hungerFactor * dt
      self.showText = "Wow, that is delicious!"
    elseif bType == 'spicy' then
      self.thurst = self.thurst - 15 * self.thurstFactor * dt
      self.showText = "I never ate something so spicy!"
    elseif bType == 'poison' then
      self.poisoned = true
	  if gAchievments["poison"] == nil then
		gAchievments["poison"] = Achievment:new("You got poisoned!")
	  end
      self.showText = "I cannot breath anymore!"
    else
      self.showText = "Tastes like a rice cake!"
    end
  end
end

function Player:getPiece(v)
  self.partsLeft = self.partsLeft - 1
  self.textDisplayTime = 7.5
  if self.partsLeft == 0 then
    self.showText = "Let's go home!"
  else
    self.showText = "Back to the spaceship!"
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

function loadPlayerSounds()
  gPlayerBreathe = {}
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/breathe_1a.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/breathe_1b.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/breathe_2a.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/breathe_2b.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/breathe_2c.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/breathe_3a.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/breathe_3b.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/breathe_3c.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/breathe_3d.mp3", "stream"))
  
  gPlayerHungry = {}
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/hungry_1a.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/hungry_1b.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/hungry_1c.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/hungry_2a.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/hungry_2b.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/hungry_2c.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/hungry_3a.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/hungry_3b.mp3", "stream"))
  table.insert(gPlayerBreathe, love.audio.newSource("sfx/hungry_3c.mp3", "stream"))
  
  gPlayerThirsty = {}
  table.insert(gPlayerThirsty, love.audio.newSource("sfx/thirsty_1a.mp3", "stream"))
  table.insert(gPlayerThirsty, love.audio.newSource("sfx/thirsty_1b.mp3", "stream"))
  table.insert(gPlayerThirsty, love.audio.newSource("sfx/thirsty_1c.mp3", "stream"))
  table.insert(gPlayerThirsty, love.audio.newSource("sfx/thirsty_2a.mp3", "stream"))
  table.insert(gPlayerThirsty, love.audio.newSource("sfx/thirsty_2b.mp3", "stream"))
  table.insert(gPlayerThirsty, love.audio.newSource("sfx/thirsty_2c.mp3", "stream"))
  table.insert(gPlayerThirsty, love.audio.newSource("sfx/thirsty_3a.mp3", "stream"))
  table.insert(gPlayerThirsty, love.audio.newSource("sfx/thirsty_3b.mp3", "stream"))
  table.insert(gPlayerThirsty, love.audio.newSource("sfx/thirsty_3c.mp3", "stream"))
  table.insert(gPlayerThirsty, love.audio.newSource("sfx/thirsty_3d.mp3", "stream"))
  table.insert(gPlayerThirsty, love.audio.newSource("sfx/thirsty_4a.mp3", "stream"))
  table.insert(gPlayerThirsty, love.audio.newSource("sfx/thirsty_4b.mp3", "stream"))
  table.insert(gPlayerThirsty, love.audio.newSource("sfx/thirsty_4c.mp3", "stream"))
  
  gPlayerTired = {}
  table.insert(gPlayerTired, love.audio.newSource("sfx/tired_1a.mp3", "stream"))
  table.insert(gPlayerTired, love.audio.newSource("sfx/tired_1b.mp3", "stream"))
  table.insert(gPlayerTired, love.audio.newSource("sfx/tired_1c.mp3", "stream"))
  table.insert(gPlayerTired, love.audio.newSource("sfx/tired_1d.mp3", "stream"))
  table.insert(gPlayerTired, love.audio.newSource("sfx/tired_1e.mp3", "stream"))
  table.insert(gPlayerTired, love.audio.newSource("sfx/tired_2a.mp3", "stream"))
  table.insert(gPlayerTired, love.audio.newSource("sfx/tired_2b.mp3", "stream"))
  table.insert(gPlayerTired, love.audio.newSource("sfx/tired_2c.mp3", "stream"))
  table.insert(gPlayerTired, love.audio.newSource("sfx/tired_3a.mp3", "stream"))
  table.insert(gPlayerTired, love.audio.newSource("sfx/tired_3b.mp3", "stream"))
  table.insert(gPlayerTired, love.audio.newSource("sfx/tired_4a.mp3", "stream"))
  table.insert(gPlayerTired, love.audio.newSource("sfx/tired_4b.mp3", "stream"))
end

function Player:talk(dt)
  self.talkNext = self.talkNext - dt 
  if self.talkNext <= 0 then
    if self.air < 50 and self.thurst < 50 and self.hunger < 50 then
      local index = math.random(1, #gPlayerTired)
      gPlayerTired[index]:rewind()
      gPlayerTired[index]:play()
      self.talkNext = 10
    elseif self.air < 60 then
      local index = math.random(1, #gPlayerBreathe)
      gPlayerBreathe[index]:rewind()
      gPlayerBreathe[index]:play()
      self.talkNext = 10 
    elseif self.thurst < 60 then
      local index = math.random(1, #gPlayerThirsty)
      gPlayerThirsty[index]:rewind()
      gPlayerThirsty[index]:play()
      self.talkNext = 10 
    elseif self.hunger < 60 then
      local index = math.random(1, #gPlayerHungry)
      gPlayerHungry[index]:rewind()
      gPlayerHungry[index]:play()
      self.talkNext = 10 
    end
  end
end
