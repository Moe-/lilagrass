function StartGame()
	game_state = 2
  setMusic(game_state)
	intro:reset()
end

function ShowCredits()
	game_state = 4
  setMusic(game_state)
end

function QuitGame()
	love.event.quit()
end

function newMenu()
	local obj = {}

	obj.space = love.graphics.newImage("gfx/space.png")
	obj.spaceship = love.graphics.newImage("gfx/spaceship.png")
	obj.spaceship_quad = love.graphics.newQuad(0, 0, 128, 128, 384, 384)
	obj.planet = love.graphics.newImage("gfx/planet.png")
	obj.stardust = love.graphics.newImage("gfx/stardust.png")
	obj.stardust:setWrap("repeat", "repeat")
	obj.stardust_quad = love.graphics.newQuad(0, 0, 200, 150, 200, 150)

	obj.reset = function(self, dt)
		self.planet_rotation = 0
		self.planet_scale = 1
		self.spaceship_move = 0
		self.spaceship_scale = 1
		self.effect_time = 0
	end

	obj.update = function(self, dt)
		self.effect_time = self.effect_time + dt
		
		self.updateButton(160, 128 + 0, 96, 24, StartGame)
		self.updateButton(160, 128 + 32, 96, 24, ShowCredits)
		self.updateButton(160, 128 + 64, 96, 24, QuitGame)
	end

	obj.draw = function(self)
		love.graphics.setColor(255, 255, 255)
		love.graphics.push()
		love.graphics.scale(2)
		love.postshader.setBuffer("render")
		love.postshader.setScale(2)

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.space)
		love.graphics.draw(self.planet, 200, 150, self.planet_rotation, self.planet_scale, self.planet_scale, 200, 150)
		self.spaceship_quad:setViewport(math.random(0,1) * 128, 128, 128, 128)
		love.graphics.draw(self.spaceship, self.spaceship_quad, 32 + self.spaceship_move * 8, 128 - self.spaceship_move * 2, 0, self.spaceship_scale, self.spaceship_scale, 70, 55)
		if self.effect_time < 2 then
			love.graphics.setColor(255, 255, 255, self.effect_time * 127)
		end
		love.graphics.scale(2)
		love.graphics.printf("Lila Gras", 0, 16, 200, "center")
		love.graphics.scale(0.5)
		
		self.drawBlur(160, 128 + 0, 96, 24)
		self.drawBlur(160, 128 + 32, 96, 24)
		self.drawBlur(160, 128 + 64, 96, 24)

		love.graphics.setColor(255, 255, 255)
		love.postshader.addEffect("bloom")
		love.postshader.addEffect("scanlines")
		love.postshader.draw()
		
		love.graphics.pop()
		
		love.graphics.push()
		love.graphics.scale(2)
		self.drawButton("Start", 160, 128 + 0, 96, 24)
		self.drawButton("Credits", 160, 128 + 32, 96, 24)
		self.drawButton("Quit", 160, 128 + 64, 96, 24)
		love.graphics.pop()
	end
	
	obj.drawBlur = function(x, y, width, height)
		love.graphics.setScissor(x * 2, y * 2, width * 2, height * 2)
		love.postshader.addEffect("blur", 8, 8)
		love.graphics.setScissor()
	end
	
	obj.drawButton = function(text, x, y, width, height)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("line", x, y, width, height)
		if love.mouse.getX() >= x * 2 and love.mouse.getX() <= (x + width) * 2 and love.mouse.getY() >= y * 2 and love.mouse.getY() <= (y + height) * 2 then
			love.graphics.setColor(255, 255, 127, 191)
		else
			love.graphics.setColor(255, 255, 255, 191)
		end
		love.graphics.rectangle("line", x + 1, y + 1, width - 2, height - 2)
		love.graphics.setColor(0, 0, 0, 191)
		love.graphics.rectangle("fill", x + 1, y + 1, width - 2, height - 2)
		if love.mouse.getX() >= x * 2 and love.mouse.getX() <= (x + width) * 2 and love.mouse.getY() >= y * 2 and love.mouse.getY() <= (y + height) * 2 then
			love.graphics.setColor(255, 255, 127, 191)
		else
			love.graphics.setColor(255, 255, 255, 191)
		end
		love.graphics.printf(text, x, y + 4, width, "center")
	end
	
	obj.updateButton = function(x, y, width, height, func)
		if love.mouse.getX() >= x * 2 and love.mouse.getX() <= (x + width) * 2 and love.mouse.getY() >= y * 2 and love.mouse.getY() <= (y + height) * 2 then
			if love.mouse.isDown("l") then
				func()
			end
		end	
	end
	
	obj:reset()
	
	return obj
end