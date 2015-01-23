function newIntro()
	local obj = {}

	obj.space = love.graphics.newImage("gfx/space.png")
	obj.spaceship = love.graphics.newImage("gfx/spaceship.png")
	obj.planet = love.graphics.newImage("gfx/planet.png")

	obj.update = function()

	end

	obj.draw = function()
		love.graphics.draw(obj.space)
		love.graphics.draw(obj.planet)
		love.graphics.draw(obj.spaceship)
	end
	
	return obj
end

