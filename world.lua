class "World" {
}

function World:__init()
  self.background = Background:new()
  self.player = Player:new(200, 200)
end

function World:draw()
  self.background:draw()
  self.player:draw()
end

function World:update(dt)
  self.player:update(dt)
end

function World:keypressed(key)
  self.player:keypressed(key)
end

function World:keyreleased(key)
  self.player:keyreleased(key)
end
