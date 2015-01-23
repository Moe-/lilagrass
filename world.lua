require('food')

class "World" {
  width = 0;
  height = 0;
  food = {};
}

function World:__init(width, height)
  self.width = width
  self.height = height
  self.background = Background:new()
  self.player = Player:new(200, 200)
  self.foodgfx = love.graphics.newImage("gfx/food.png")
  
  for i = 1, 10 do
    local x = math.random(1, self.width)
    local y = math.random(1, self.height)
    table.insert(self.food, Food:new(self.foodgfx, x, y))
  end
end

function World:draw()
  self.background:draw()
  self.player:draw()
  
  for i, v in pairs(self.food) do
    v:draw()
  end
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
end

function World:keypressed(key)
  self.player:keypressed(key)
end

function World:keyreleased(key)
  self.player:keyreleased(key)
end
