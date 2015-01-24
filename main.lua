require('utils')
require('background')
require('player')
require('world')
require('gui')
require('menu')
require('intro')
require('lib/postshader')

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	font = love.graphics.newImageFont("gfx/font.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
	love.graphics.setFont(font)

	if arg[#arg] == "-debug" then 
	require("mobdebug").start() 
	end

	math.randomseed( os.time() )

	resetGame()
	game_state = 1

	menu = newMenu()
	intro = newIntro()
end

function love.update(dt)
	if game_state == 1 then
		menu:update(dt)
	elseif game_state == 2 then
		intro:update(dt)
	elseif game_state == 3 then
		gWorld:update(dt)
	end
end

function love.draw()
	if game_state == 1 then
		menu:draw()
	elseif game_state == 2 then
		intro:draw()

		if intro.effect_time >= 5 then
			game_state = 3
		end
	elseif game_state == 3 then
		gWorld:draw()
		gGui:draw()
	end
end

function resetGame()
  gGui = Gui:new()
  gWorld = World:new(800, 600)
end

function love.mousepressed(x, y, button)
  
end

function love.mousereleased(x, y, button)
  
end

function love.keypressed(key)
  gWorld:keypressed(key)
  if key == "1" then
    game_state = 1
	menu:reset()
  elseif key == "2" then
	game_state = 2
	intro:reset()
  elseif key == "3" then
    game_state = 3
  elseif key == "9" then
    resetGame()
  end
end

function love.keyreleased(key)
  if key == 'escape' then
    love.event.quit()
  end
  gWorld:keyreleased(key)
end
