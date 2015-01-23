require('utils')
require('background')
require('player')
require('world')

function love.draw()
  gWorld:draw()
end

function love.load()
  if arg[#arg] == "-debug" then 
    require("mobdebug").start() 
  end
  resetGame()
end

function resetGame()
  gWorld = World:new()
end


function love.update(dt)
  gWorld:update(dt)
end

function love.mousepressed(x, y, button)
  
end

function love.mousereleased(x, y, button)
  
end

function love.keypressed(key)
  gWorld:keypressed(key)
end

function love.keyreleased(key)
  if key == 'escape' then
    love.event.quit()
  end
  gWorld:keyreleased(key)
end
