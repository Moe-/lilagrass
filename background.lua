class "Background" {

}

function Background:__init()
  self.image = love.graphics.newImage("gfx/background.png")
  self.quad = love.graphics.newQuad(0, 0, 1024, 1024, self.image:getWidth(), self.image:getHeight())
end

function Background:draw()
  love.graphics.draw(self.image, self.quad, 0, 0)
end
