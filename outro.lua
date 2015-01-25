function newOutro()
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
		self.spaceship_move = 0.1
		self.spaceship_scale = 0.05
		self.effect_time = 0
	end

	obj.update = function(self, dt)
		--self.planet_rotation = self.planet_rotation + dt * 0.1
		--self.planet_scale = self.planet_scale + dt * 0.1
		self.spaceship_move = self.spaceship_move * (1 + dt * 2)
		self.spaceship_scale = self.spaceship_scale * (1 + dt)
		self.effect_time = self.effect_time + dt
		
		if self.effect_time >= 15 then
			game_state = 1
			resetGame()
			setMusic(game_state)
		end
	end

	obj.draw = function(self)
		love.graphics.push()
		love.graphics.scale(2)
		if self.effect_time >= 2 then
			if self.effect_time <= 3 then
				love.graphics.translate(math.random(0,self.effect_time-1)*0.5, math.random(0,self.effect_time-1)*0.5)
			elseif self.effect_time <= 4 then
				love.graphics.translate(math.random(0,(4-self.effect_time))*0.5, math.random(0,(4-self.effect_time))*0.5)
			end
		end
		love.postshader.setBuffer("render")
		love.postshader.setScale(2)

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.space)
		love.graphics.draw(self.planet, 200, 150, self.planet_rotation, self.planet_scale, self.planet_scale, 200, 150)
		self.spaceship_quad:setViewport(math.floor(math.abs(math.sin(self.effect_time * 20) + 0.5)) * 128, 256, 128, 128)
		love.graphics.draw(self.spaceship, self.spaceship_quad, 256 - self.spaceship_move * 8, 192 - self.spaceship_move * 2, 0, self.spaceship_scale, self.spaceship_scale, 70, 55)

		if self.effect_time >= 4 then
			love.graphics.setColor(255, 255, 255, math.min(4, self.effect_time - 4) * 63)
			love.graphics.rectangle("fill", 0, 0, 400, 300)
		end
		
		if self.effect_time >= 7 then
			love.graphics.scale(4)
			love.graphics.setColor(63, 31, 63, math.min(4, self.effect_time - 7) * 63)
			love.graphics.printf("FIN", 0, 30, 100, "center")
			love.graphics.scale(0.25)
		end

		love.postshader.addEffect("bloom")

		love.postshader.addEffect("scanlines")
		love.postshader.draw()
	
		love.graphics.pop()
		
		love.graphics.push()
		love.graphics.scale(4)

		love.graphics.pop()
	end
	
	obj:reset()
	
	return obj
end

