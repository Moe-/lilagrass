function newObjects()
	local obj = {}
	obj.objects = {}
	obj.timer = 0
	obj.uselessObjectsGathered = 0

	obj.img = {}
	obj.quad = {}

	obj.img["item"] = love.graphics.newImage("gfx/item_tileset.png")
	obj.quad["item"] = love.graphics.newQuad(0, 0, 24, 32, 72, 160)
	
	obj.img["trees"] = love.graphics.newImage("gfx/Trees.png")
	obj.quad["trees"] = love.graphics.newQuad(0, 0, 48, 64, 96, 128)
	
	obj.img["spaceship"] = love.graphics.newImage("gfx/spaceship.png")
	obj.quad["spaceship"] = love.graphics.newQuad(0, 0, 128, 128, 384, 384)
	
	obj.img["crew"] = love.graphics.newImage("gfx/crew.png")
	obj.quad["crew"] = love.graphics.newQuad(0, 0, 32, 24, 64, 48)

	obj.new = function(self, group, x, y, width, height, tx, ty, ox, oy, radius)
		local o = {}

		o.group = group
		o.x = x
		o.y = y
		o.width = width
		o.height = height
		o.tx = tx or 0
		o.ty = ty or 0
		o.ox = ox or 0
		o.oy = oy or 0
		o.radius = radius or 16
		o.collision = true
		o.text = nil
		o.textTime = 0
		o.consume = false
		o.hidden = false
		o.hunger = 0
		o.air = 0
		o.win = false
		o.wind = false
		o.windStrength = 0.1
		o.collectorAchievment = false
		
		table.insert(self.objects, o)
		
		return o
	end

	obj.init = function(self)
		self.objects = {}

		local o = self:new("spaceship", 900, 900, 128, 128, 2, 0, 64, 64, 48)
		o.text = "Can i fix this?"
		o.time = 2
		o.win = true

		o = self:new("crew", 1100, 950, 32, 24, 0, 0, 16, 12, 16)
		o.text = "..."
		o.time = 2
		o = self:new("crew", 970, 1080, 32, 24, 1, 0, 16, 12, 16)
		o.text = "WHHYYY?!"
		o.time = 2
		o = self:new("crew", 850, 1050, 32, 24, 1, 1, 16, 12, 16)
		o.text = "*gulp*"
		o.time = 2
		
		for i = 1, 500 do
			local x = math.random(32, 2016)
			local y = math.random(32, 2016)
			local r = math.random(0, 120)
			
			if math.distance(x, gWorld.player.x, y, gWorld.player.y) > 200 then
				if r < 2 then
					local o = self:new("item", x, y, 24, 32, 0, 0, 12, 16)
					o.collision = false
					o.text = "This is not good anymore!"
					o.time = 2
					o.consume = true
					o.hunger = -5
				elseif r < 4 then
					local o = self:new("item", x, y, 24, 32, 1, 0, 12, 16)
					o.collision = false
					o.text = "This is broken!"
					o.time = 2
					o.consume = true
					o.collectorAchievment = true
				elseif r < 6 then
					local o = self:new("item", x, y, 24, 32, 2, 0, 12, 16)
					o.collision = false
					o.text = "Puh, that smells!"
					o.time = 2
					o.consume = true
					o.air = -5
				elseif r < 8 then
					local o = self:new("item", x, y, 24, 32, 0, 1, 12, 16)
					o.collision = false
					o.text = "This is useless!"
					o.time = 2
					o.consume = true
					o.collectorAchievment = true
				elseif r < 10 then
					local o = self:new("item", x, y, 24, 32, 1, 1, 12, 16)
					o.collision = false
					o.text = "This is damaged!"
					o.time = 2
					o.consume = true
					o.collectorAchievment = true
				elseif r < 20 then
					self:new("item", x, y, 24, 32, 2, 2, 12, 16)
				elseif r < 30 then
					self:new("item", x, y, 24, 32, 0, 3, 12, 16)
				elseif r < 40 then
					self:new("item", x, y, 24, 32, 1, 3, 12, 16)
				elseif r < 50 then
					self:new("item", x, y, 24, 32, 2, 3, 12, 16)
				elseif r < 60 then
					local o = self:new("trees", x, y, 48, 64, 0, 0, 24, 56)
					o.wind = true
					o.windStrength = 0.1
				elseif r < 70 then
					local o = self:new("trees", x, y, 48, 64, 1, 0, 24, 56)
					o.wind = true
					o.windStrength = 0.1
				elseif r < 80 then
					local o = self:new("trees", x, y, 48, 64, 0, 1, 24, 56)
					o.wind = true
					o.windStrength = 0.1
				elseif r < 90 then
					local o = self:new("trees", x, y, 48, 64, 1, 1, 24, 56)
					o.wind = true
					o.windStrength = 0.1
				elseif r < 100 then
					self:new("item", x, y, 24, 32, 0, 4, 12, 16)
				elseif r < 110 then
					self:new("item", x, y, 24, 32, 1, 4, 12, 16)
				elseif r < 120 then
					self:new("item", x, y, 24, 32, 2, 4, 12, 16)
				end
			end
		end
	end
	
	obj.update = function(self, dt)
		self.timer = self.timer + dt

		for k, v in ipairs(self.objects) do
			if not v.hidden then
				v.distance = math.distance(gWorld.player.x + 12, v.x + v.ox, gWorld.player.y + 24, v.y + v.oy)

				if v.distance <= v.radius then
					if v.collectorAchievment then
						if not gAchievments["collector"]:isUnlocked() then
							gAchievments["collector"]:progress()
						end
					end
					if v.collision then
						gWorld.player.x = gWorld.player.lastX
						gWorld.player.y = gWorld.player.lastY
					end
					
					if v.consume then
						v.hidden = true
					end
					
					if v.text then
						gWorld.player.showText = v.text
						gWorld.player.textDisplayTime = v.time
					end
					
					if v.hunger ~= 0 then
						gWorld.player.hunger = gWorld.player.hunger + v.hunger
					end
					
					if v.air ~= 0 then
						gWorld.player.air = gWorld.player.air + v.air
					end
					
					if v.win and gWorld.player.partsLeft <= 0 then
						game_state = 6
						setMusic(game_state)
						outro:reset()
						resetGame()
						if not gAchievments["winner"]:isUnlocked() then
							gAchievments["winner"]:progress()
						end
					end
				end
			end
		end

		gWorld.player.lastX = gWorld.player.x
		gWorld.player.lastY = gWorld.player.y
	end

	obj.draw = function(self, layer)
		for k, v in ipairs(self.objects) do
			if not v.hidden and v.distance and v.distance <= 300 then
				if (layer == "bottom" and ((gWorld.player.y + 16) > (v.y + v.oy) or not v.collision)) or (layer == "top" and (gWorld.player.y + 16) < (v.y + v.oy) and v.collision) then
					self.quad[v.group]:setViewport(v.tx * v.width, v.ty * v.height, v.width, v.height)
					love.graphics.setColor(0, 0, 0, 85)
					if v.collision then
						if v.wind then
							love.graphics.draw(self.img[v.group], self.quad[v.group], v.x + v.width, v.y + v.height, 0, 1, 1, v.width, v.height, -0.5 + math.sin(self.timer) * v.windStrength, 0)
						else
							love.graphics.draw(self.img[v.group], self.quad[v.group], v.x + v.width, v.y + v.height, 0, 1, 1, v.width, v.height, -0.5, 0)
						end
					else
						love.graphics.draw(self.img[v.group], self.quad[v.group], v.x + 2, v.y - 2)
					end
					love.graphics.setColor(255, 255, 255)
					if v.wind then
						love.graphics.draw(self.img[v.group], self.quad[v.group], v.x + v.width, v.y + v.height, 0, 1, 1, v.width, v.height, math.sin(self.timer) * v.windStrength, 0)
					else
						love.graphics.draw(self.img[v.group], self.quad[v.group], v.x, v.y)
					end
				end
			end
		end
	end
	
	return obj
end

math.distance = function(x1, x2, y1, y2)
	local dx = x1 - x2
	dx = dx * dx

	local dy = y1 - y2
	dy = dy * dy

	return math.sqrt(dx + dy)
end