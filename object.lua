function newObjects()
	local obj = {}
	obj.objects = {}

	obj.img = {}
	obj.quad = {}

	obj.img["item"] = love.graphics.newImage("gfx/item_tileset.png")
	obj.quad["item"] = love.graphics.newQuad(0, 0, 24, 32, 72, 160)
	
	obj.img["trees"] = love.graphics.newImage("gfx/trees.png")
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
		
		table.insert(self.objects, o)
	end

	obj.init = function(self)
		self.objects = {}

		self:new("spaceship", 900, 900, 128, 128, 2, 0, 64, 64, 48)
		self:new("crew", 1100, 950, 32, 24, 0, 0, 16, 12, 16)
		self:new("crew", 970, 1080, 32, 24, 1, 0, 16, 12, 16)
		self:new("crew", 850, 1050, 32, 24, 1, 1, 16, 12, 16)
		
		for i = 1, 1000 do
			local x = math.random(32, 2016)
			local y = math.random(32, 2016)
			local r = math.random(0, 100)
			
			if math.distance(x, gWorld.player.x, y, gWorld.player.y) > 200 then
				if r < 1 then
					self:new("item", x, y, 24, 32, 1, 1, 12, 16)
				elseif r < 10 then
					self:new("item", x, y, 24, 32, 2, 2, 12, 16)
				elseif r < 20 then
					self:new("item", x, y, 24, 32, 0, 3, 12, 16)
				elseif r < 30 then
					self:new("item", x, y, 24, 32, 1, 3, 12, 16)
				elseif r < 40 then
					self:new("item", x, y, 24, 32, 2, 3, 12, 16)
				elseif r < 50 then
					self:new("trees", x, y, 48, 64, 0, 0, 24, 56)
				elseif r < 60 then
					self:new("trees", x, y, 48, 64, 1, 0, 24, 56)
				elseif r < 70 then
					self:new("trees", x, y, 48, 64, 0, 1, 24, 56)
				elseif r < 80 then
					self:new("trees", x, y, 48, 64, 1, 1, 24, 56)
				end
			end
		end
	end
	
	obj.update = function(self, dt)
		for k, v in ipairs(self.objects) do
			v.distance = math.distance(gWorld.player.x + 12, v.x + v.ox, gWorld.player.y + 24, v.y + v.oy)

			if v.distance <= v.radius then
				gWorld.player.x = gWorld.player.lastX
				gWorld.player.y = gWorld.player.lastY
			end
		end

		gWorld.player.lastX = gWorld.player.x
		gWorld.player.lastY = gWorld.player.y
	end

	obj.draw = function(self, layer)
		for k, v in ipairs(self.objects) do
			if v.distance and v.distance <= 300 then
				if (layer == "bottom" and (gWorld.player.y + 16) > (v.y + v.oy)) or (layer == "top" and (gWorld.player.y + 16) < (v.y + v.oy)) then
					self.quad[v.group]:setViewport(v.tx * v.width, v.ty * v.height, v.width, v.height)
					love.graphics.setColor(0, 0, 0, 127)
					love.graphics.draw(self.img[v.group], self.quad[v.group], v.x + 2, v.y - 2)
					love.graphics.setColor(255, 255, 255)
					love.graphics.draw(self.img[v.group], self.quad[v.group], v.x, v.y)
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