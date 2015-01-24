require('food')
require('air')
require('drink')
require('football')
require('safezone')
require('shippiece')

class "World" {
  width = 0;
  height = 0;
  itemSpawnTime = 5;
  partsToFind = 5;
  numberZones = 5;
  numberObjects = 6;
  offsetX = 0;
  offsetY = 0;
  scale = 2;
  showFood = false;
  showDrinks = false;
  showAir = false;
  showParts = false;
  playerInitialX = 188; --calculated from window width and 1/2 player image width
  playerInitialY = 134; --calculated from window height and 1/2 player image height
  dayCicle = 1;
}

function World:__init(width, height)
  self.width = width
  self.height = height
  self.food = {}
  self.air = {}
  self.drink = {}
  self.safezone = {}
  self.parts = {}
  self.background = Background:new()
  self.player = Player:new(self.playerInitialX, self.playerInitialY, self.partsToFind, self.background:getSize())
  self.foodgfx = love.graphics.newImage("gfx/food.png")
  self.airgfx = love.graphics.newImage("gfx/air.png")
  self.drinkgfx = love.graphics.newImage("gfx/bottle.png")
  self.safezonegfx = love.graphics.newImage("gfx/safezone.png")
  self.safezonegfx:setWrap("repeat", "repeat")
  self.shippiecegfx = love.graphics.newImage("gfx/shippiece.png")
  
  self.effect_time = 0
  
  for i = 1, self.numberObjects do
    self:genObj()
  end
  
  for i = 1, self.numberZones do
    self:genZones()
  end
  
  for i = 1, self.partsToFind do
    self:genParts()
  end
  
  self.football = Football:new(150, 150, self.background:getSize())
  self.spawnNextItemIn = self.itemSpawnTime
 
	-- create light world
	lightWorld = love.light.newWorld()
	lightWorld.setAmbientColor(15, 15, 31)
	lightWorld.setRefractionStrength(32.0)

	-- create light
	lightHero = lightWorld.newLight(0, 0, 255, 127, 63, 400)
	lightHero.setGlowStrength(0.3)
	lightHero.setAngle(math.pi * 0.5)
	lightHero.setDirection(math.pi)
	
	footballShadow = lightWorld.newCircle(64, 64, 32)
end

function World:genObj()
  local x = math.random(1, self.background:getWidth())
  local y = math.random(1, self.background:getHeight())
  local objType = math.random(1, 3)
  if objType == 1 and showFood then
    table.insert(self.food, Food:new(self.foodgfx, x, y))
  elseif objType == 2 and showAir then
    table.insert(self.air, Food:new(self.airgfx, x, y))
  elseif objType == 3 and showDrinks then
    table.insert(self.drink, Food:new(self.drinkgfx, x, y))
  end
end

function World:genZones()
  local x = math.random(1, self.background:getWidth())
  local y = math.random(1, self.background:getHeight())
  local size = math.random(64, 256)
  table.insert(self.safezone, SafeZone:new(self.safezonegfx, x, y, size))
end

function World:genParts()
  local x = 0
  local y = 0
  while self.player.x - x >= -512 and self.player.x - x <= 512 do
	x = math.random(1, self.background:getWidth())
  end
  while self.player.y - y >= -512 and self.player.y - y <= 512 do
	y = math.random(1, self.background:getHeight())
  end
  table.insert(self.parts, ShipPiece:new(self.shippiecegfx, x, y))
end

function World:draw()
  self.background:draw()

lightHero.setPosition((self.player.x+self.offsetX)*2 + 24, (self.player.y+self.offsetY)*2 + 32)
footballShadow.setPosition((self.football.x+self.offsetX)*2 + 32, (self.football.y+self.offsetY)*2 + 32)

  for i, v in pairs(self.safezone) do
    v:draw()
  end
  
  
  
  for i, v in pairs(self.food) do
    v:draw()
  end
  
  for i, v in pairs(self.air) do
    v:draw()
  end
  
  for i, v in pairs(self.drink) do
    v:draw()
  end
  
  for i, v in pairs(self.parts) do
    v:draw()
  end
  
  love.graphics.pop()
  love.graphics.push()
  lightWorld.update()	
  lightWorld.drawShadow()
  love.graphics.pop()
  love.graphics.push()
   love.graphics.scale(self.scale)
  love.graphics.translate(self.offsetX, self.offsetY)
  
  self.football:draw()
  
  love.graphics.pop()
  love.graphics.push()
  lightWorld.drawShine()
  love.graphics.pop()
  love.graphics.push()
   love.graphics.scale(self.scale)
  love.graphics.translate(self.offsetX, self.offsetY)
  
   self.player:draw()
  
	if self.effect_time <= 2 then
		love.graphics.setColor(255, 255, 255, (2 - self.effect_time) * 127)
		love.graphics.rectangle("fill", -self.offsetX, -self.offsetY, 400, 300)
	end
	
	love.graphics.setColor(255, 255, 255)

	if self.player:isDead() then
		love.graphics.setColor(255, 92, 0, 255)
		love.graphics.printf("You are the biggest shame of humanity!", 0, 120, 400, "center")
	elseif self.player:isRescued() then
		love.graphics.setColor(0, 255, 92, 255)
		love.graphics.printf("You managed to escape from this planet!", 0, 120, 400, "center")
	end

	if self.effect_time >= 2 and self.effect_time <= 10 then
		if self.effect_time <= 6 then
			love.graphics.setColor(255, 255, 255, (self.effect_time - 2) * 63)
		else
			love.graphics.setColor(255, 255, 255,(10 - self.effect_time) * 63)
		end

		love.graphics.printf("Purple Planet", 0 - self.offsetX, 16 - self.offsetY, 400, "center")
		
		love.graphics.setColor(255, 255, 255)
	end
end

function World:update(dt)
  local px, py = self.player:getPosition()
  local playerSafe = false
  self.dayCicle = self.dayCicle + dt * 0.2
  lightWorld.setAmbientColor(
	math.sin(self.dayCicle) * 127 + 127,
	math.sin(self.dayCicle) * 127 + 127,
	math.sin(self.dayCicle) * 63 + 127)
  
  for i, v in pairs(self.safezone) do
    v:update(dt)
    playerSafe = playerSafe or v:inside(px, py)
  end
  
  self.player:update(dt, playerSafe)
  if self.player.hunger < 60 and not self.showFood then
	self.showFood = true
	self.player.textDisplayTime = 4
	self.player.showText = "I am getting hungry!"
  end
  if self.player.thurst < 60 and not self.showDrinks then
	self.showDrinks = true
	self.player.textDisplayTime = 4
	self.player.showText = "I am getting thirsty!"
  end
  if self.player.air < 60 and not self.showAir then
	self.showAir = true
	self.player.textDisplayTime = 4
	self.player.showText = "The air is getting thinner!"
  end
  px, py = self.player:getPosition()
  
  for i, v in pairs(self.food) do
    v:update(dt)
    local fx, fy = v:getPosition()
    local distance = getDistance(px, py, fx, fy)
    if distance < 24 then
      self.player:eat(v)
      self.food[i] = nil
    end
  end
  
  for i, v in pairs(self.air) do
    v:update(dt)
    local fx, fy = v:getPosition()
    local distance = getDistance(px, py, fx, fy)
    if distance < 24 then
      self.player:breath(v)
      self.air[i] = nil
    end
  end
  
  for i, v in pairs(self.drink) do
    v:update(dt)
    local fx, fy = v:getPosition()
    local distance = getDistance(px, py, fx, fy)
    if distance < 24 then
      self.player:drink(v)
      self.drink[i] = nil
    end
  end
  
  for i, v in pairs(self.parts) do
    v:update(dt)
    local fx, fy = v:getPosition()
    local distance = getDistance(px, py, fx, fy)
    if distance < 24 then
      self.player:getPiece(v)
      self.parts[i] = nil
    end
  end
  
  self.football:update(dt)
  local fx, fy = self.football:getPosition()
  local distance = getDistance(px, py, fx, fy)
  if distance < 24 then
    self.football:kick(fx - px, fy - py)
  end
  
  self.spawnNextItemIn = self.spawnNextItemIn - dt
  if self.spawnNextItemIn <= 0 then
    self:genObj()
    self.spawnNextItemIn = self.spawnNextItemIn + self.itemSpawnTime
  end
  
  self.effect_time = self.effect_time + dt
  
  local oX, oY = self.player:getOffset()
  self.offsetX = self.offsetX - oX
  self.offsetY = self.offsetY - oY
  if self.offsetX > self.playerInitialX then
	self.offsetX = self.playerInitialX;
  elseif self.offsetX < self.playerInitialX - self.background:getWidth() + 24 then
	self.offsetX = self.playerInitialX - self.background:getWidth() + 24
  end
  if self.offsetY > self.playerInitialY then
	self.offsetY = self.playerInitialY;
  elseif self.offsetY < self.playerInitialY - self.background:getHeight() + 32 then
	self.offsetY = self.playerInitialY - self.background:getHeight() + 32
  end
  print(self.offsetX, self.offsetY)
end

--[[function World:updateScrolling()
  local px, py = self.player:getPosition()
  --local width, height = self.background:getSize()
  local width = love.window.getWidth() / self.scale
  local height = love.window.getHeight() / self.scale
  
  if px + self.offsetX < 50 then
    self.offsetX = self.offsetX + 2
  elseif px + self.offsetX > width - 50 then
    self.offsetX = self.offsetX - 5
  end
  
  if py + self.offsetY < 50 then
    self.offsetY = self.offsetY + 2
  elseif py + self.offsetY > height - 50 then
    self.offsetY = self.offsetY - 5
  end
end]]--

function World:keypressed(key)
  self.player:keypressed(key)
end

function World:keyreleased(key)
  self.player:keyreleased(key)
end
