function newIntro()
	local obj = {}

	obj.space = love.graphics.newImage("gfx/space.png")
	obj.spaceship = love.graphics.newImage("gfx/spaceship.png")
	obj.planet = love.graphics.newImage("gfx/planet.png")
	obj.stardust = love.graphics.newImage("gfx/stardust.png")
	obj.stardust:setWrap("repeat", "repeat")
	obj.stardust_quad = love.graphics.newQuad(0, 0, 200, 150, 200, 150)
	
	obj.reset = function(self, dt)
		obj.planet_rotation = 0
		obj.planet_scale = 1
		obj.spaceship_move = 0
		obj.spaceship_scale = 1
		obj.effect_time = 0
	end

	obj.update = function(self, dt)
		self.planet_rotation = self.planet_rotation + dt * 0.1
		self.planet_scale = self.planet_scale + dt * 0.2
		self.spaceship_move = self.spaceship_move + dt * 4
		self.spaceship_scale = self.spaceship_scale - dt * 0.2
		self.effect_time = self.effect_time + dt
	end

	obj.draw = function(self)
		love.graphics.push()
		love.graphics.scale(4)
		love.graphics.translate(math.random(0,self.effect_time), math.random(0,self.effect_time))
		love.postshader.setBuffer("render")
		love.postshader.setScale(4)

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.space)
		love.graphics.draw(self.planet, 128, 64, self.planet_rotation, self.planet_scale, self.planet_scale, 60, 60)
		love.graphics.draw(self.spaceship, -32 + self.spaceship_move * 8, 96 - self.spaceship_move, 0, self.spaceship_scale, self.spaceship_scale, 70, 55)
		love.graphics.setColor(255, 255, 255, obj.effect_time * 31)
		self.stardust_quad:setViewport(self.spaceship_move * 80, -self.spaceship_move * 40, 200, 150)
		love.graphics.draw(self.stardust, self.stardust_quad)
		self.stardust_quad:setViewport(self.spaceship_move * 40, -self.spaceship_move * 20, 200, 150)
		love.graphics.draw(self.stardust, self.stardust_quad)
		if obj.effect_time >= 3 then
			love.graphics.setColor(255, 255, 255, (obj.effect_time - 3) * 63)
			love.graphics.rectangle("fill", 0, 0, 200, 150)
		end

		love.postshader.addEffect("bloom")
		love.postshader.addEffect("blur",math.floor(self.effect_time),math.floor(self.effect_time))
		love.postshader.addEffect("scanlines")
		love.postshader.draw()
	
		love.graphics.pop()
	end
	
	return obj
end

