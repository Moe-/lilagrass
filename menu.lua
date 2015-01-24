function newMenu()
	local obj = {}

	obj.planet_rotation = 0
	obj.planet_scale = 1
	obj.spaceship_move = 0
	obj.spaceship_scale = 1
	obj.space = love.graphics.newImage("gfx/space.png")
	obj.spaceship = love.graphics.newImage("gfx/spaceship.png")
	obj.planet = love.graphics.newImage("gfx/planet.png")
	obj.stardust = love.graphics.newImage("gfx/stardust.png")
	obj.stardust:setWrap("repeat", "repeat")
	obj.stardust_quad = love.graphics.newQuad(0, 0, 200, 150, 200, 150)

	obj.update = function(self, dt)

	end

	obj.draw = function(self)
		love.graphics.push()
		love.graphics.scale(4)
		love.postshader.setBuffer("render")
		love.postshader.setScale(4)

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.space)
		love.graphics.draw(self.planet, 128, 64, self.planet_rotation, self.planet_scale, self.planet_scale, 60, 60)
		love.graphics.draw(self.spaceship, -32 + self.spaceship_move * 8, 96 - self.spaceship_move, 0, self.spaceship_scale, self.spaceship_scale, 70, 55)

		love.postshader.addEffect("bloom")
		love.postshader.addEffect("scanlines")
		love.postshader.draw()
		love.graphics.pop()
	end
	
	return obj
end

