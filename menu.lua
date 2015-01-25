function StartGame()
	game_state = 2
  setMusic(game_state)
	intro:reset()
end

function ShowCredits()
	game_state = 4
  setMusic(game_state)
end

function ShowAchievments()
	game_state = 5
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

	obj.imgParticle = love.graphics.newImage("gfx/particle.png");

    obj.sysParticle = love.graphics.newParticleSystem(obj.imgParticle, 1000);
    obj.sysParticle:setParticleLifetime(1, 2)
    obj.sysParticle:setEmissionRate(500)
    obj.sysParticle:setSizeVariation(1)
	obj.sysParticle:setSizes(1, 2)
    obj.sysParticle:setLinearAcceleration(-20, -20, 0, 0)
    obj.sysParticle:setColors(255, 255, 127, 255, 255, 0, 0, 0)
	
	for i = 1, 20 do
		obj.sysParticle:update(0.1)
	end
	
	obj.reset = function(self, dt)
		self.planet_rotation = 0
		self.planet_scale = 1
		self.spaceship_move = 0
		self.spaceship_scale = 1
		self.effect_time = 0
	end

	obj.update = function(self, dt)
		self.effect_time = self.effect_time + dt
		
		self.updateButton(120, 112 + 0, 170, 24, StartGame)
		self.updateButton(120, 112 + 32, 170, 24, ShowCredits)
		self.updateButton(120, 112 + 64, 170, 24, ShowAchievments)
		self.updateButton(120, 112 + 96, 170, 24, QuitGame)
		
		self.sysParticle:update(dt);
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
		self.spaceship_quad:setViewport(0, 128, 128, 128)
		love.graphics.draw(self.spaceship, self.spaceship_quad, 32 + self.spaceship_move * 8, 128 - self.spaceship_move * 2 + math.sin(self.effect_time * 4) * 2, 0, self.spaceship_scale, self.spaceship_scale, 70, 55)
		if self.effect_time < 2 then
			love.graphics.setColor(255, 255, 255, self.effect_time * 127)
		end
		
		love.graphics.draw(obj.sysParticle, 40, 136 + math.sin(self.effect_time * 4) * 2);
		
		love.graphics.scale(2)
		love.graphics.setColor(255, math.max(127, 255 - self.effect_time * 100), math.min(255, self.effect_time * 100 + 127))
		love.graphics.printf("Purple Grass", 0, 16, 200, "center")
		love.graphics.scale(0.5)
		
		love.graphics.setColor(255, 255, 255)
		self.drawBlur(120, 112 + 0, 170, 24)
		self.drawBlur(120, 112 + 32, 170, 24)
		self.drawBlur(120, 112 + 64, 170, 24)
		self.drawBlur(120, 112 + 96, 170, 24)

		love.graphics.setColor(255, 255, 255)
		love.postshader.addEffect("bloom")
		love.postshader.addEffect("scanlines")
		love.postshader.draw()
		
		love.graphics.pop()
		
		love.graphics.push()
		love.graphics.scale(2)
		self.drawButton("Start", 120, 112 + 0, 170, 24)
		self.drawButton("Credits", 120, 112 + 32, 170, 24)
		self.drawButton("Achievments", 120, 112 + 64, 170, 24)
		self.drawButton("Quit", 120, 112 + 96, 170, 24)
		
		love.graphics.setColor(255, 255, 255, 127)
		love.graphics.printf("v0.7b", 0, 280, 390, "right")
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
			love.graphics.setColor(255, 127, 255, 191)
		else
			love.graphics.setColor(255, 255, 255, 191)
		end
		love.graphics.rectangle("line", x + 1, y + 1, width - 2, height - 2)
		love.graphics.setColor(0, 0, 0, 191)
		love.graphics.rectangle("fill", x + 1, y + 1, width - 2, height - 2)
		if love.mouse.getX() >= x * 2 and love.mouse.getX() <= (x + width) * 2 and love.mouse.getY() >= y * 2 and love.mouse.getY() <= (y + height) * 2 then
			love.graphics.setColor(255, 127, 255, 191)
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