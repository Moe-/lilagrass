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
  self.player = Player:new(10, 10, self.partsToFind)
  self.foodgfx = love.graphics.newImage("gfx/food.png")
  self.airgfx = love.graphics.newImage("gfx/air.png")
  self.drinkgfx = love.graphics.newImage("gfx/bottle.png")
  self.safezonegfx = love.graphics.newImage("gfx/safezone.png")
  self.shippiecegfx = love.graphics.newImage("gfx/shippiece.png")
  
  self.effect_time = 3
  
  for i = 1, 15 do
    self:genObj()
  end
  
  for i = 1, 5 do
    self:genZones()
  end
  
  for i = 1, self.partsToFind do
    self:genParts()
  end
  
  self.football = Football:new(150, 150)
  self.spawnNextItemIn = self.itemSpawnTime
end

function World:genObj()
  local x = math.random(1, self.width)
  local y = math.random(1, self.height)
  local objType = math.random(1, 3)
  if objType == 1 then
    table.insert(self.food, Food:new(self.foodgfx, x, y))
  elseif objType == 2 then
    table.insert(self.air, Food:new(self.airgfx, x, y))
  elseif objType == 3 then
    table.insert(self.drink, Food:new(self.drinkgfx, x, y))
  end
end

function World:genZones()
  local x = math.random(1, self.width)
  local y = math.random(1, self.height)
  local size = math.random(64, 256)
  table.insert(self.safezone, SafeZone:new(self.safezonegfx, x, y, size))
end

function World:genParts()
  local x = math.random(1, self.width)
  local y = math.random(1, self.height)

  table.insert(self.parts, ShipPiece:new(self.shippiecegfx, x, y))
end

function World:draw()
  love.graphics.push()
  love.graphics.scale(2)
  self.background:draw()
  
  for i, v in pairs(self.safezone) do
    v:draw()
  end
  
  self.player:draw()
  
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
  
  self.football:draw()
  
	if self.effect_time >= 0 then
		love.graphics.setColor(255, 255, 255, self.effect_time * 85)
		love.graphics.rectangle("fill", 0, 0, 400, 300)
	end
  love.graphics.pop()
  
  if self.player:isDead() then
    love.graphics.setColor(255, 92, 0, 255)
    love.graphics.print("You are the biggest shame of humanity!", 10, 250, 0, 2, 2)
  elseif self.player:isRescued() then
    love.graphics.setColor(0, 255, 92, 255)
    love.graphics.print("You managed to escape from this planet!", 10, 250, 0, 2, 2)
  end
end

function World:update(dt)
  local px, py = self.player:getPosition()
  local playerSafe = false
  
  for i, v in pairs(self.safezone) do
    v:update(dt)
    playerSafe = playerSafe or v:inside(px, py)
  end
  
  self.player:update(dt, playerSafe)
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
  
  self.effect_time = self.effect_time - dt
end

function World:keypressed(key)
  self.player:keypressed(key)
end

function World:keyreleased(key)
  self.player:keyreleased(key)
end
