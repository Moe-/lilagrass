require('food')
require('air')
require('drink')
require('football')

class "World" {
  width = 0;
  height = 0;
  food = {};
  air = {};
  drink = {};
  itemSpawnTime = 5;
}

function World:__init(width, height)
  self.width = width
  self.height = height
  self.background = Background:new()
  self.player = Player:new(10, 10)
  self.foodgfx = love.graphics.newImage("gfx/food.png")
  self.airgfx = love.graphics.newImage("gfx/air.png")
  self.drinkgfx = love.graphics.newImage("gfx/bottle.png")
  
  for i = 1, 15 do
    self:genObj()
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

function World:draw()
  love.graphics.push()
  love.graphics.scale(4, 4)
  self.background:draw()
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
  
  self.football:draw()
  love.graphics.pop()
end

function World:update(dt)
  self.player:update(dt)
  local px, py = self.player:getPosition()
  
  for i, v in pairs(self.food) do
    v:update(dt)
    local fx, fy = v:getPosition()
    local distance = getDistance(px, py, fx, fy)
    if distance < 64 then
      self.player:eat(v)
      self.food[i] = nil
    end
  end
  
  for i, v in pairs(self.air) do
    v:update(dt)
    local fx, fy = v:getPosition()
    local distance = getDistance(px, py, fx, fy)
    if distance < 64 then
      self.player:breath(v)
      self.air[i] = nil
    end
  end
  
  for i, v in pairs(self.drink) do
    v:update(dt)
    local fx, fy = v:getPosition()
    local distance = getDistance(px, py, fx, fy)
    if distance < 64 then
      self.player:drink(v)
      self.drink[i] = nil
    end
  end
  
  self.football:update(dt)
  local fx, fy = self.football:getPosition()
  local distance = getDistance(px, py, fx, fy)
  if distance < 32 then
    self.football:kick(fx - px, fy - py)
  end
  
  self.spawnNextItemIn = self.spawnNextItemIn - dt
  if self.spawnNextItemIn <= 0 then
    self:genObj()
    self.spawnNextItemIn = self.spawnNextItemIn + self.itemSpawnTime
  end
end

function World:keypressed(key)
  self.player:keypressed(key)
end

function World:keyreleased(key)
  self.player:keyreleased(key)
end
