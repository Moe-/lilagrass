class "Background" {

}

function Background:__init()
  self.image = love.graphics.newImage("gfx/background.png")
  self.quad = love.graphics.newQuad(0, 0, 2048, 2048, self.image:getWidth()*2, self.image:getHeight()*2)
  self.width = self.image:getWidth()*2
  self.height = self.image:getHeight()*2
end

function Background:draw()
  love.graphics.draw(self.image, self.quad, 0, 0)
end

function Background:getSize()
  return self.width, self.height
end

function Background:getWidth()
  return self.width
end

function Background:getHeight()
  return self.height
end