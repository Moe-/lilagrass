class "Water" {
  x = 0;
  y = 0;
  size = 0;
}

function Water:__init(image, x, y, size)
  self.x = x
  self.y = y
  self.size = size
  self.image = image
  self.spriteBatch = love.graphics.newSpriteBatch(image)
  self:generateBatch()
  --self.quad = love.graphics.newQuad(0, 0, size, size, self.image:getWidth(), self.image:getHeight())
end

function Water:draw()
  love.graphics.draw(self.spriteBatch, self.x, self.y)
end

function Water:update(dt)
  
end

function Water:getSize()
  return self.size
end

function Water:getPosition()
  return self.x + self.size / 2, self.y + self.size / 2
end

function Water:generateBatch()
  local spriteSize = 32
  local size = self.size / spriteSize
  if size == 1 then
    self.spriteBatch:add(love.graphics.newQuad(0 * spriteSize, 3 * spriteSize, spriteSize, spriteSize, self.image:getWidth(), self.image:getHeight()), 0, 0)
  else
    for x = 1, size do
      for y = 1, size do
        local xpos = x * spriteSize
        local ypos = y * spriteSize
        if x == 1 and y == 1 then
          -- upper left
          self.spriteBatch:add(love.graphics.newQuad(0 * spriteSize, 0 * spriteSize, spriteSize, spriteSize, self.image:getWidth(), self.image:getHeight()), xpos, ypos)
        elseif x == 1 and y == size then
          -- lower left
          self.spriteBatch:add(love.graphics.newQuad(0 * spriteSize, 2 * spriteSize, spriteSize, spriteSize, self.image:getWidth(), self.image:getHeight()), xpos, ypos)
        elseif x == 1 then
          -- left side
          self.spriteBatch:add(love.graphics.newQuad(0 * spriteSize, 1 * spriteSize, spriteSize, spriteSize, self.image:getWidth(), self.image:getHeight()), xpos, ypos)
        elseif x == size and y == 1 then
          -- upper right
          self.spriteBatch:add(love.graphics.newQuad(2 * spriteSize, 0 * spriteSize, spriteSize, spriteSize, self.image:getWidth(), self.image:getHeight()), xpos, ypos)
        elseif x == size and y == size then
          -- lower right
          self.spriteBatch:add(love.graphics.newQuad(2 * spriteSize, 2 * spriteSize, spriteSize, spriteSize, self.image:getWidth(), self.image:getHeight()), xpos, ypos)
        elseif x == size then
          -- right side
          self.spriteBatch:add(love.graphics.newQuad(2 * spriteSize, 1 * spriteSize, spriteSize, spriteSize, self.image:getWidth(), self.image:getHeight()), xpos, ypos)
        elseif y == 1 then
          -- upper side
          self.spriteBatch:add(love.graphics.newQuad(1 * spriteSize, 0 * spriteSize, spriteSize, spriteSize, self.image:getWidth(), self.image:getHeight()), xpos, ypos)
        elseif y == size then
          -- lower side
          self.spriteBatch:add(love.graphics.newQuad(1 * spriteSize, 2 * spriteSize, spriteSize, spriteSize, self.image:getWidth(), self.image:getHeight()), xpos, ypos)
        else
          -- zone
          self.spriteBatch:add(love.graphics.newQuad(1 * spriteSize, 1 * spriteSize, spriteSize, spriteSize, self.image:getWidth(), self.image:getHeight()), xpos, ypos)
        end
      end
    end
  end
end

function Water:inside(x, y)
  if x > self.x and x < self.x + self.size and y > self.y and y < self.y + self.size then
      return true
  end
  return false
end
