function ShowMenu()
	game_state = 1
end

function newCredits()
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
		
		self.updateButton(340, 270, 48, 24, ShowMenu)
	end

	obj.draw = function(self)
		love.graphics.setColor(255, 255, 255)
		love.graphics.push()
		love.graphics.scale(2)
		love.postshader.setBuffer("render")
		love.postshader.setScale(2)

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.space)
		love.graphics.draw(self.planet, 256, 128, self.planet_rotation, self.planet_scale, self.planet_scale, 60, 60)
		love.graphics.draw(self.spaceship, -64 + self.spaceship_move * 8, 256 - self.spaceship_move * 2, 0, self.spaceship_scale, self.spaceship_scale, 70, 55)
		if self.effect_time < 2 then
			love.graphics.setColor(255, 255, 255, self.effect_time * 127)
		end
		love.graphics.scale(2)
		love.graphics.printf("Credits", 0, 16, 200, "center")
		love.graphics.scale(0.5)
		
		self.drawRainbowText("Marcus Ihde (Programmer)", 0, 64 + 0, 0)
		self.drawRainbowText("Markus Vill (Programmer)", 0, 64 + 16, 1)
		self.drawRainbowText("Nico Reitmeier (Sound)", 0, 64 + 32, 4)
		self.drawRainbowText("Nicola Robin (Art)", 0, 64 + 48, 2)
		self.drawRainbowText("Philip Braun (Programmer)", 0, 64 + 64, 3)
		
		love.graphics.setColor(255, 255, 255)
		love.postshader.addEffect("bloom")
		love.postshader.addEffect("scanlines")
		love.postshader.draw()
		
		love.graphics.pop()
		
		love.graphics.push()
		love.graphics.scale(2)
		self.drawButton("Back", 340, 270, 48, 24)
		love.graphics.pop()
	end

	obj.drawRainbowText = function(text, x, y, cnt)
		local f = 7

		local r = 127 + math.sin(love.timer.getTime() * 5 - cnt * f + 90) * 127
		local g = 127 + math.sin(love.timer.getTime() * 5 - cnt * f + 180) * 127
		local b = 127 + math.sin(love.timer.getTime() * 5 - cnt * f + 270) * 127
		love.graphics.setColor(r, g, b, 255)

		love.graphics.printf(text, x, y + 4, 400, "center")
	end

	obj.drawButton = function(text, x, y, width, height)
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