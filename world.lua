require('food')
require('air')
require('drink')
require('football')
require('safezone')
require('shippiece')
require('water')
require('bush')

class "World" {
  width = 0;
  height = 0;
  itemSpawnTime = 3;
  partsToFind = 5;
  numberZones = 5;
  numberWater = 5;
  numberObjects = 6;
  numberBushes = 30;
  offsetX = 0;
  offsetY = 0;
  scale = 2;
  showFood = false;
  showDrinks = false;
  showAir = false;
  centerPosX = 188; --calculated from window width and 1/2 player image width
  centerPosY = 134; --calculated from window height and 1/2 player image height
  dayCicle = 1;
}

function World:__init(width, height)
  self.width = width
  self.height = height
  self.food = {}
  self.air = {}
  self.drink = {}
  self.safezone = {}
  self.waterzone = {}
  self.parts = {}
  self.bushes = {}
  self.background = Background:new()
  self.playerInitialX = self.background:getWidth()/2
  self.playerInitialY = self.background:getHeight()/2
  self.offsetX = -self.playerInitialX + 188;
  self.offsetY = -self.playerInitialY + 134;
  self.player = Player:new(self.playerInitialX, self.playerInitialY, self.partsToFind, self.background:getSize())
  self.foodgfx = love.graphics.newImage("gfx/food.png")
  self.airgfx = love.graphics.newImage("gfx/air.png")
  self.drinkgfx = love.graphics.newImage("gfx/bottle.png")
  self.safezonegfx = love.graphics.newImage("gfx/purple_grass_tiles.png")
  --self.safezonegfx:setWrap("repeat", "repeat")
  self.waterzonegfx = love.graphics.newImage("gfx/water_tiles_on_grass.png")
  self.shippiecegfx = love.graphics.newImage("gfx/shippiece.png")
  self.shippiecegfx2 = love.graphics.newImage("gfx/spanner.png")
  self.bushgfx = love.graphics.newImage("gfx/item_tileset.png")
  
  self.effect_time = 0
  
  for i = 1, self.numberObjects do
    self:genObj()
  end
  
  for i = 1, self.numberZones do
    self:genZones()
  end
  
  for i = 1, self.numberWater do
    self:genWaterZones()
  end
  
  for i = 1, self.partsToFind do
    self:genParts()
  end
  gGui:setMaxRepairItems(self.partsToFind)
  
  for i = 1, self.numberBushes do
    self:genBushes()
  end
  
  self.football = Football:new(880, 1055, self.background:getSize())
  self.spawnNextItemIn = self.itemSpawnTime
 
	-- create light world
	lightWorld = love.light.newWorld()
	lightWorld.setAmbientColor(15, 15, 31)
	lightWorld.setRefractionStrength(32.0)

	-- create light
	lightHero = lightWorld.newLight(0, 0, 255, 127, 63, 400)
	--lightHero.setGlowStrength(0.3)
	lightHero.setAngle(math.pi * 0.5)
	lightHero.setDirection(math.pi)
	lightHero2 = lightWorld.newLight(0, 0, 255, 127, 63, 200)
	
	-- add water
	self.refraction_normal = love.graphics.newImage("gfx/refraction_normal.png")
	self.refraction_normal:setWrap("repeat", "repeat")
	
	self.water = lightWorld.newBody("refraction", self.refraction_normal, 0, 0, 2048, 2048)
	--objectTest.setShine(false)
	--objectTest.setShadowType("rectangle")
	--objectTest.setShadowDimension(64, 64)
	--self.water.setReflection(true)
	
	--shipShadow = lightWorld.newCircle(900, 900, 128)
end

function World:genObj()
  local objType = math.random(1, 3)
  if objType == 1 then
	if self.showFood then
		self:genFood()
	else
		objType = objType + 1
	end
  end
  if objType == 2 then
	if self.showDrinks then
		self:genDrink()
	else
		objType = objType + 1
	end
  end
  if objType == 3 then
	if self.showAir then
		self:genAir()
	else
		objType = objType + 1
	end
  end
end

function World:genFood()	
  local x = math.random(1, self.background:getWidth() - 24)
  local y = math.random(1, self.background:getHeight() - 32)
  table.insert(self.food, Food:new(self.foodgfx, x, y))
end

function World:genDrink()
	local x = math.random(1, self.background:getWidth() - 24)
	local y = math.random(1, self.background:getHeight() - 32)
	table.insert(self.drink, Food:new(self.drinkgfx, x, y))
end

function World:genAir()
	local x = math.random(1, self.background:getWidth() - 24)
	local y = math.random(1, self.background:getHeight() - 32)
	table.insert(self.air, Food:new(self.airgfx, x, y))
end

function World:genZones()
  local size = math.random(1, 8) * 32
  
  local distance
  local x, y
  
  repeat
    x = math.random(1, (self.background:getWidth() - 256)/32) * 32
    y = math.random(1, (self.background:getHeight() - 256)/32) * 32
    
    distance = 999999
    for i,v in pairs(self.safezone) do
      local tsize = v:getSize()
      local tx, ty = v:getPosition()
      local dist = getDistance(x, y, tx, ty) - (size + tsize)
      distance = math.min(distance, dist)
    end
    for i,v in pairs(self.waterzone) do
      local tsize = v:getSize()
      local tx, ty = v:getPosition()
      local dist = getDistance(x, y, tx, ty) - (size + tsize)
      distance = math.min(distance, dist)
    end
  until distance > 0
  
  table.insert(self.safezone, SafeZone:new(self.safezonegfx, x, y, size))
end

function World:genBushes()
  local x = math.random(1, self.background:getWidth() - 32)
  local y = math.random(1, self.background:getHeight() - 32)
  table.insert(self.bushes, Bush:new(self.bushgfx, x, y))
end

function World:genWaterZones()
  local size = math.random(1, 8) * 32
  
  local distance
  local x, y
  
  repeat
    x = math.random(1, (self.background:getWidth() - 256)/32) * 32
    y = math.random(1, (self.background:getHeight() - 256)/32) * 32
    
    distance = 999999
    for i,v in pairs(self.safezone) do
      local tsize = v:getSize()
      local tx, ty = v:getPosition()
      local dist = getDistance(x, y, tx, ty) - (size + tsize)
      distance = math.min(distance, dist)
    end
    for i,v in pairs(self.waterzone) do
      local tsize = v:getSize()
      local tx, ty = v:getPosition()
      local dist = getDistance(x, y, tx, ty) - (size + tsize)
      distance = math.min(distance, dist)
    end
  until distance > 0
  
  table.insert(self.waterzone, Water:new(self.waterzonegfx, x, y, size))
end

function World:genParts()
  local x = 0
  local y = 0
  repeat 
    x = math.random(1, self.background:getWidth() - 32)
  until self.playerInitialX - x < -512 or self.playerInitialX - x > 512 
  repeat 
    y = math.random(1, self.background:getHeight() - 32)
  until self.playerInitialY - y < -512 or self.playerInitialY - y > 512 
  
  if math.random(1, 2) == 1 then
    table.insert(self.parts, ShipPiece:new(self.shippiecegfx, x, y))
  else
    table.insert(self.parts, ShipPiece:new(self.shippiecegfx2, x, y))
  end
end

function World:draw()
	self.background:draw()

	self.water.setPosition(self.player.x+self.offsetX+math.sin(self.dayCicle*4)*256-512, self.player.y+self.offsetY+math.sin(self.dayCicle*2)*256-512)
	--self.water.setNormalOffset((self.dayCicle * 200+self.offsetX), (self.dayCicle * 100+self.offsetY))

	lightHero.setPosition((self.player.x+self.offsetX)*2 + 24, (self.player.y+self.offsetY)*2 + 32)
	lightHero2.setPosition((self.player.x+self.offsetX)*2 + 24, (self.player.y+self.offsetY)*2 + 32)
	--footballShadow.setPosition((self.football.x+self.offsetX)*2 + 32, (self.football.y+self.offsetY)*2 + 32)

	love.graphics.pop()
	love.graphics.push()
	lightWorld.update()	
	-- draw refraction
	lightWorld.drawRefraction()

	love.graphics.pop()
	love.graphics.push()
	love.graphics.scale(self.scale)
	love.graphics.translate(self.offsetX, self.offsetY)
	
	for i, v in pairs(self.safezone) do
		v:draw()
	end
  
  for i, v in pairs(self.waterzone) do
		v:draw()
	end
  
  for i, v in pairs(self.bushes) do
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
  
  		gObjects:draw("bottom")
		
		self.football:draw()

		gWorld.player:draw()
		
		gObjects:draw("top")
  
	love.graphics.pop()
	love.graphics.push()
	-- draw shadow
	lightWorld.drawShadow()

	love.graphics.pop()
	love.graphics.push()
	love.graphics.scale(self.scale)
	love.graphics.translate(self.offsetX, self.offsetY)
  
  gWorld.player:drawText()
  
  love.graphics.pop()
  love.graphics.push()
  lightWorld.drawShine()
  love.graphics.pop()
  love.graphics.push()
  love.graphics.scale(self.scale)
  love.graphics.translate(self.offsetX, self.offsetY)

	if self.effect_time <= 1 then
		love.graphics.setColor((1 - self.effect_time) * 255, (1 - self.effect_time) * 255, (1 - self.effect_time) * 255)
		love.graphics.rectangle("fill", -self.offsetX, -self.offsetY, 400, 300)
	elseif self.effect_time <= 4 then
		love.graphics.setColor(0, 0, 0, (3 - (self.effect_time - 1)) * 85)
		love.graphics.rectangle("fill", -self.offsetX, -self.offsetY, 400, 300)
	end
	
	love.graphics.setColor(255, 255, 255)

	local playerX, playerY = self.player:getPosition()
	if self.player:isDead() then
		love.graphics.setColor(255, 92, 0, 255)
		love.graphics.printf("You are the biggest shame of humanity!", playerX-200, playerY - self.centerPosY +30, 400, "center")
	elseif self.player:isRescued() then
		love.graphics.setColor(0, 255, 92, 255)
		love.graphics.printf("You managed to escape from this planet!", playerX-200, playerY - self.centerPosY +30, 400, "center")
	end

	if self.effect_time >= 2 and self.effect_time <= 4 then
		if self.effect_time <= 6 then
			love.graphics.setColor(255, 255, 255, (self.effect_time - 2) * 63)
		else
			love.graphics.setColor(255, 255, 255,(4 - self.effect_time) * 63)
		end

		love.graphics.scale(2)
		love.graphics.printf("Purple Planet", 0 - self.offsetX * 0.5, 8 - self.offsetY * 0.5, 200, "center")
		love.graphics.scale(0.5)
		
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
  
  for i, v in pairs(self.waterzone) do
    v:update(dt)
    if v:inside(px, py) then
      self.player:bathing(v, dt)
    end
  end
  
  self.player:update(dt, playerSafe, self.bushes)
  if self.player.hunger < 60 and not self.showFood then
	self.showFood = true
	self.player.textDisplayTime = 4
	self.player.showText = "I am getting hungry!"
	for i = 1, 3 do
		self:genFood()
	end
  end
  if self.player.thurst < 60 and not self.showDrinks then
	self.showDrinks = true
	self.player.textDisplayTime = 4
	self.player.showText = "I am getting thirsty!"
	for i = 1, 3 do
		self:genDrink()
	end
  end
  if self.player.air < 60 and not self.showAir then
	self.showAir = true
	self.player.textDisplayTime = 4
	self.player.showText = "The air is getting thinner!"
	for i = 1, 3 do
		self:genAir()
	end
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
  
  for i, v in pairs(self.bushes) do
    v:update(dt)
    local fx, fy = v:getPosition()
    local distance = getDistance(px, py, fx, fy)
    if distance < 24 then
      self.player:useBush(v, dt)
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

	--[[
	local oX, oY = self.player:getOffset()
	self.offsetX = self.offsetX - oX
	self.offsetY = self.offsetY - oY
	if self.offsetX > self.centerPosX then
	self.offsetX = -self.centerPosX;
	elseif self.offsetX < self.centerPosX - self.background:getWidth() + 24 then
	self.offsetX = self.centerPosX - self.background:getWidth() + 24
	end
	if self.offsetY > self.centerPosY then
	self.offsetY = self.centerPosY;
	elseif self.offsetY < self.centerPosY - self.background:getHeight() + 32 then
	self.offsetY = self.centerPosY - self.background:getHeight() + 32
	end]]--
  
	gWorld.offsetX = -gWorld.player.x + 200
	gWorld.offsetY = -gWorld.player.y + 150
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
