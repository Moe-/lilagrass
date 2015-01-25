function ShowMenu()
	game_state = 1
  setMusic(game_state)
end

function newAchievments()
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
		self.page = 1
		self.lastPage = 1
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
		love.graphics.draw(self.planet, 200, 150, self.planet_rotation, self.planet_scale, self.planet_scale, 200, 150)
		if self.effect_time < 2 then
			love.graphics.setColor(255, 255, 255, self.effect_time * 127)
		end
		love.graphics.scale(2)
		love.graphics.printf("Achievments", 0, 16, 200, "center")
		love.graphics.scale(0.5)
		local achievmentCount = 0
		for i, v in pairs(gAchievments) do
			self.drawAchievmentText(v:getText(), 0, 64 + achievmentCount*32)
			achievmentCount = achievmentCount + 1
		end
		
		love.graphics.setColor(0, 0, 0, 191)
		love.graphics.rectangle("fill", 150*0.5, 75, (love.window.getWidth()-300)/2, 50)
		love.graphics.rectangle("fill", 150*0.5, 150, (love.window.getWidth()-300)/2, 50)
		love.graphics.rectangle("fill", 150*0.5, 225, (love.window.getWidth()-300)/2, 50)
		
		love.graphics.setColor(255, 255, 255)
		love.postshader.addEffect("bloom")
		love.postshader.addEffect("scanlines")
		love.postshader.draw()

		love.graphics.pop()
		
		love.graphics.push()
		love.graphics.scale(2)
		self.drawButton("Back", 340, 270, 48, 24)
		if self.page ~= self.lastPage then
			self.drawButton("next\nPage", (love.window.getWidth()-125)/2, 150, 48, 32)
		end
		if self.page ~= 1 then
			self.drawButton("prev\nPage", (125)/2-48, 150, 48, 32)
		end
		love.graphics.pop()
	end
	
	obj.drawAchievmentText = function(text, x, y)
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