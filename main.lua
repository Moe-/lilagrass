require('utils')
require('background')
require('player')
require('world')
require('gui')
require('menu')
require('intro')
require('achievments')
require('outro')
require('credits')
require('object')
require('particle')
require('lib/postshader')
require('lib/light')
require('lib/TSerial')

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	gIcon = love.image.newImageData("gfx/icon.png")
	love.window.setIcon(gIcon)

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

	gMusicIntro = love.audio.newSource("sfx/intro.mp3", "stream")
	gMusicOutro = love.audio.newSource("sfx/outro.mp3", "stream")

	gMusicGame:setVolume(0.8)

	gMusicMenu:play()
	loadPlayerSounds()
  
	gScreenCount = 0

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
	achievments = newAchievments()
	outro = newOutro()

	gObjects = newObjects()
	gObjects:init()
	
	gAchievments = {}
	achievmentSave = dofile(arg[1] .. "/save.lua")	
	for i, v in pairs(achievmentSave) do
		gAchievments[v.name] = Achievment:new(v.name, v.progress, v.unlocked)
	end
end

function love.update(dt)
	if game_state == 1 then
		menu:update(dt)
	elseif game_state == 2 then
		intro:update(dt)
	elseif game_state == 3 then
		gWorld:update(dt)
		gObjects:update(dt)
	elseif game_state == 4 then
		credits:update(dt)
	elseif game_state == 5 then
		achievments:update(dt)
	elseif game_state == 6 then
		outro:update(dt)
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
	elseif game_state == 5 then
		achievments:draw()
	elseif game_state == 6 then
		outro:draw()
	end
end

function resetGame()
  gGui = Gui:new()
  gWorld = World:new(800, 600)
	if gObjects then
		gObjects:init()
	end
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
	resetGame()
  elseif key == "2" then
	game_state = 2
	intro:reset()
	resetGame()
  elseif key == "3" then
    game_state = 3
	resetGame()
  elseif key == "4" then
    game_state = 4
	resetGame()
  elseif key == "5" then
    game_state = 5
	resetGame()
  elseif key == "6" then
    game_state = 6
	outro:reset()
	resetGame()
  elseif key == "9" then
    resetGame()
  elseif key == "f4" then
    local s = love.graphics.newScreenshot() --ImageData
    s:encode("pic" .. gScreenCount .. ".png", 'png')
    gScreenCount = gScreenCount + 1
  end
  setMusic(game_state)
end

function love.keyreleased(key)
  if key == 'escape' then
	if game_state == 1 then
		love.event.quit()
	elseif game_state == 2 then
		game_state = 3
	else
		game_state = 1
		resetGame()
		setMusic(game_state)
	end
  end
  gWorld:keyreleased(key)
end

function love.joystickpressed(joystick,button)
  if button == 1 then
    love.keypressed('w')
  elseif button == 4 then
    love.keypressed('a')
  elseif button == 3 then
    love.keypressed('s')
  elseif button == 2 then
    love.keypressed('d')
  end
end

function love.joystickreleased(joystick,button)
  if button == 1 then
    love.keyreleased('w')
  elseif button == 4 then
    love.keyreleased('a')
  elseif button == 3 then
    love.keyreleased('s')
  elseif button == 2 then
    love.keyreleased('d')
  end
end

function love.joystickaxis(joystick, axis, value)
  -- -1 => up, left
  -- +1 => down, right
  if axis == 2 then --up/down
    if value == -1 then
      love.keypressed('w')
    elseif value == 1 then
      love.keypressed('s')
    else
      love.keyreleased('w')
      love.keyreleased('s')
    end
  elseif axis == 1 then -- up/down
    if value == -1 then
      love.keypressed('a')
    elseif value == 1 then
      love.keypressed('d')
    else
      love.keyreleased('a')
      love.keyreleased('d')
    end
  end
end

function setMusic()
    if gLastMusicState ~= game_state then
		if gLastMusicState == 1 then
			gMusicMenu:stop()
		elseif gLastMusicState == 2 then
			gMusicIntro:stop()
		elseif gLastMusicState == 3 then
			gMusicGame:stop()
		elseif gLastMusicState == 6 then
			gMusicOutro:stop()
		end

		if game_state == 1 then
			gMusicMenu:play()
		elseif game_state == 2 then
			gMusicIntro:play()
		elseif game_state == 3 then
			gMusicGame:play()
		elseif game_state == 6 then
			gMusicOutro:play()
		end

		gLastMusicState = game_state
    end
end
