require('utils')

function love.draw()
    love.graphics.print("Hello World", 400, 300)
end

function love.load()
  if arg[#arg] == "-debug" then 
    require("mobdebug").start() 
  end
end

function love.update(dt)
  
end

function love.mousepressed(x, y, button)
  
end

function love.mousereleased(x, y, button)
  
end

function love.keypressed(key)
  
end

function love.keyreleased(key)
  if key == 'escape' then
    love.event.quit()
  end
end
