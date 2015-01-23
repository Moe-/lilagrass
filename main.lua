require('utils')
require('background')
require('player')
require('world')
require('gui')
require('menu')
require('intro')

function love.load()
  if arg[#arg] == "-debug" then 
    require("mobdebug").start() 
  end
  resetGame()
	game_state = 1

	menu = newMenu()
	intro = newIntro()
end

function love.update(dt)
	if game_state == 1 then
		menu:update()
	elseif game_state == 2 then
		intro:update()
	elseif game_state == 3 then
		gWorld:update(dt)
	end
end

function love.draw()
	if game_state == 1 then
		menu:draw()
	elseif game_state == 2 then
		intro:draw()
	elseif game_state == 3 then
		gWorld:draw()
		gGui:draw()
	end
end

function resetGame()
  gGui = Gui:new()
  gWorld = World:new()
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
