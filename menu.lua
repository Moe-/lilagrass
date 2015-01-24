function StartGame()
	game_state = 2
end

function ShowCredits()
	game_state = 4
end

function QuitGame()
	love.event.quit()
end

function newMenu()
	local obj = {}

	obj.space = love.graphics.newImage("gfx/space.png")
	obj.spaceship = love.graphics.newImage("gfx/spaceship.png")
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
		
		self.updateButton(52, 48 + 0, 96, 24, StartGame)
		self.updateButton(52, 48 + 32, 96, 24, ShowCredits)
		self.updateButton(52, 48 + 64, 96, 24, QuitGame)
	end

	obj.draw = function(self)
		love.graphics.setColor(255, 255, 255)
		love.graphics.push()
		love.graphics.scale(4)
		love.postshader.setBuffer("render")
		love.postshader.setScale(4)

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.space)
		love.graphics.draw(self.planet, 128, 64, self.planet_rotation, self.planet_scale, self.planet_scale, 60, 60)
		love.graphics.draw(self.spaceship, -32 + self.spaceship_move * 8, 128 - self.spaceship_move * 2, 0, self.spaceship_scale, self.spaceship_scale, 70, 55)
		if self.effect_time < 2 then
			love.graphics.setColor(255, 255, 255, self.effect_time * 127)
		end
		love.graphics.printf("Lila Gras", 0, 16, 200, "center")
		
		self.drawBlur(52, 48 + 0, 96, 24)
		self.drawBlur(52, 48 + 32, 96, 24)
		self.drawBlur(52, 48 + 64, 96, 24)

		love.graphics.setColor(255, 255, 255)
		love.postshader.addEffect("bloom")
		love.postshader.addEffect("scanlines")
		love.postshader.draw()
		
		love.graphics.pop()
		
		love.graphics.push()
		love.graphics.scale(4)
		self.drawButton("Start", 52, 48 + 0, 96, 24)
		self.drawButton("Credits", 52, 48 + 32, 96, 24)
		self.drawButton("Quit", 52, 48 + 64, 96, 24)
		love.graphics.pop()
	end
	
	obj.drawBlur = function(x, y, width, height)
		love.graphics.setScissor(x * 4, y * 4, width * 4, height * 4)
		love.postshader.addEffect("blur", 8, 8)
		love.graphics.setScissor()
	end
	
	obj.drawButton = function(text, x, y, width, height)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("line", x, y, width, height)
		if love.mouse.getX() >= x * 4 and love.mouse.getX() <= (x + width) * 4 and love.mouse.getY() >= y * 4 and love.mouse.getY() <= (y + height) * 4 then
			love.graphics.setColor(255, 255, 127, 191)
		else
			love.graphics.setColor(255, 255, 255, 191)
		end
		love.graphics.rectangle("line", x + 1, y + 1, width - 2, height - 2)
		love.graphics.setColor(0, 0, 0, 191)
		love.graphics.rectangle("fill", x + 1, y + 1, width - 2, height - 2)
		if love.mouse.getX() >= x * 4 and love.mouse.getX() <= (x + width) * 4 and love.mouse.getY() >= y * 4 and love.mouse.getY() <= (y + height) * 4 then
			love.graphics.setColor(255, 255, 127, 191)
		else
			love.graphics.setColor(255, 255, 255, 191)
		end
		love.graphics.printf(text, x, y + 4, width, "center")
	end
	
	obj.updateButton = function(x, y, width, height, func)
		if love.mouse.getX() >= x * 4 and love.mouse.getX() <= (x + width) * 4 and love.mouse.getY() >= y * 4 and love.mouse.getY() <= (y + height) * 4 then
			if love.mouse.isDown("l") then
				func()
			end
		end	
	end
	
	obj:reset()
	
	return obj
end