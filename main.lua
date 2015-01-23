require('utils')
require('background')
require('player')
require('world')
require('gui')

function love.load()
  if arg[#arg] == "-debug" then 
    require("mobdebug").start() 
  end
  math.randomseed( os.time() )

  resetGame()
  game_state = 1
end

function love.draw()
	if game_state == 1 then
		love.graphics.print("menu", 16, 16)
	elseif game_state == 2 then
		love.graphics.print("intro", 16, 16)
	elseif game_state == 3 then
		gWorld:draw()
		gGui:draw()
	end
end

function resetGame()
  gGui = Gui:new()
  gWorld = World:new(800, 600)
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
  if key == "1" then
	game_state = 1
  elseif key == "2" then
	game_state = 2
  elseif key == "3" then
	game_state = 3
  end
end

function love.keyreleased(key)
  if key == 'escape' then
    love.event.quit()
  end
  gWorld:keyreleased(key)
end
