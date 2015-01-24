function newIntro()
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
		self.planet_rotation = self.planet_rotation + dt * 0.1
		self.planet_scale = self.planet_scale + dt * 0.1
		self.spaceship_move = self.spaceship_move + dt * 6
		self.spaceship_scale = self.spaceship_scale - dt * 0.15
		self.effect_time = self.effect_time + dt
		
		if intro.effect_time >= 7 then
			game_state = 3
			resetGame()
		end
		
		self.sysParticle:update(dt)
	end

	obj.draw = function(self)
		love.graphics.push()
		love.graphics.scale(2)
		if self.effect_time <= 6 then
			love.graphics.translate(math.random(0,self.effect_time), math.random(0,self.effect_time))
		else
			love.graphics.translate(math.random(0,(7-self.effect_time)*7), math.random(0,(7-self.effect_time)*7))
		end
		love.postshader.setBuffer("render")
		love.postshader.setScale(2)

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.space)
		love.graphics.draw(self.planet, 200, 150, self.planet_rotation, self.planet_scale, self.planet_scale, 200, 150)
		self.spaceship_quad:setViewport(math.floor(math.abs(math.sin(self.effect_time * 20) + 0.5)) * 128, 128, 128, 128)
		love.graphics.draw(self.spaceship, self.spaceship_quad, 32 + self.spaceship_move * 8, 128 + self.spaceship_move * 2, 0, self.spaceship_scale, self.spaceship_scale, 70, 55)

		if self.effect_time >= 4 then
			love.graphics.setColor(255, 255, 255, (self.effect_time - 4) * 63)
			love.graphics.rectangle("fill", 0, 0, 400, 300)
		end
		
		love.graphics.draw(self.sysParticle, 40 + self.spaceship_move * 8, 136 + self.spaceship_move * 2, 0, 1 - self.effect_time / 7);
		
		love.postshader.addEffect("bloom")
		love.postshader.addEffect("blur",math.floor(self.effect_time),math.floor(self.effect_time))

		love.postshader.addEffect("scanlines")
		love.postshader.draw()
	
		love.graphics.pop()
		
		love.graphics.push()
		love.graphics.scale(4)

		if self.effect_time <= 6 then
			love.graphics.setColor(255, 255, 255, math.min(63, self.effect_time * 7 + 31))
			self.stardust_quad:setViewport(self.spaceship_move * 40, -self.spaceship_move * 20, 400, 300)
			love.graphics.draw(self.stardust, self.stardust_quad)
			love.graphics.scale(4)
			love.graphics.setColor(255, 255, 255, math.min(31, self.effect_time * 15 + 15))
			self.stardust_quad:setViewport(self.spaceship_move * 40, -self.spaceship_move * 20, 400, 300)
			love.graphics.draw(self.stardust, self.stardust_quad)
		end
		
		love.graphics.pop()
	end
	
	obj:reset()
	
	return obj
end

