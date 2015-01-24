require('utils')
require('background')
require('player')
require('world')
require('gui')
require('menu')
require('intro')
require('credits')
require('lib/postshader')
require('lib/light')

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	font = love.graphics.newImageFont("gfx/font.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
	font2 = love.graphics.newImageFont("gfx/font2.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
	love.graphics.setFont(font)
	gMusicMenu = love.audio.newSource("sfx/menu.ogg", "stream")
  gMusicMenu:setLooping(true)
  gMusicGame = love.audio.newSource("sfx/planet.ogg", "stream")
  gMusicGame:setLooping(true)
	gMusicMenu:play()

	if arg[#arg] == "-debug" then 
	require("mobdebug").start() 
	end

	math.randomseed( os.time() )

	resetGame()
	game_state = 1
  gLastMusicState = -1
  setMusic(game_state)

	menu = newMenu()
	intro = newIntro()
	credits = newCredits()
end

function love.update(dt)
	if game_state == 1 then
		menu:update(dt)
	elseif game_state == 2 then
		intro:update(dt)
	elseif game_state == 3 then
		gWorld:update(dt)
	elseif game_state == 4 then
		credits:update(dt)
	end
end

function love.draw()
	if game_state == 1 then
		menu:draw()
	elseif game_state == 2 then
		intro:draw()
	elseif game_state == 3 then
		love.graphics.setColor(255, 255, 255)

		love.postshader.setBuffer("render")
		love.graphics.push()
		love.postshader.setScale(gWorld.scale)
		love.postshader.setTranslation(gWorld.offsetX, gWorld.offsetY)
		--love.graphics.translate(self.offsetX, self.offsetY)
		love.graphics.scale(gWorld.scale)
		love.graphics.translate(gWorld.offsetX, gWorld.offsetY)
 
		gWorld:draw()
		gGui:draw(gWorld.offsetX, gWorld.offsetY)
		
		--love.postshader.addEffect("bloom")
		love.postshader.addEffect("scanlines")
		love.postshader.draw()
		love.graphics.pop()
	elseif game_state == 4 then
		credits:draw()
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
  setMusic(game_state)
end

function love.keyreleased(key)
  if key == 'escape' then
	if game_state == 1 then
		love.event.quit()
	else
		game_state = 1
    setMusic(game_state)
	end
  end
  gWorld:keyreleased(key)
end

function setMusic()
    if gLastMusicState ~= game_state then
      if game_state == 3 then
        gMusicMenu:stop()
        gMusicGame:play()
      elseif gLastMusicState == 3 then
        gMusicGame:stop()
        gMusicMenu:play()
      end
    end
    gLastMusicState = game_state
end
