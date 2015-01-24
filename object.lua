function newObjects()
	local obj = {}
	obj.objects = {}

	obj.img = {}
	obj.quad = {}

	obj.img["item"] = love.graphics.newImage("gfx/item_tileset.png")
	obj.quad["item"] = love.graphics.newQuad(0, 0, 24, 32, 72, 160)
	
	obj.img["trees"] = love.graphics.newImage("gfx/trees.png")
	obj.quad["trees"] = love.graphics.newQuad(0, 0, 48, 64, 96, 128)

	obj.new = function(self, group, x, y, width, height, tx, ty, ox, oy)
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
		o.radius = 16
		
		table.insert(self.objects, o)
	end

	obj.init = function(self)
		for i = 1, 20 do
			if math.random(1, 100) < 10 then
				self:new("item", math.random(0, 2048), math.random(0, 2048), 24, 32, 1, 1, 12, 16)
			end
			self:new("item", math.random(0, 2048), math.random(0, 2048), 24, 32, 2, 2, 12, 16)
			self:new("item", math.random(0, 2048), math.random(0, 2048), 24, 32, 0, 3, 12, 16)
			self:new("item", math.random(0, 2048), math.random(0, 2048), 24, 32, 1, 3, 12, 16)
			self:new("item", math.random(0, 2048), math.random(0, 2048), 24, 32, 2, 3, 12, 16)
			
			self:new("trees", math.random(0, 2048), math.random(0, 2048), 48, 64, 0, 0, 24, 56)
			self:new("trees", math.random(0, 2048), math.random(0, 2048), 48, 64, 1, 0, 24, 56)
			self:new("trees", math.random(0, 2048), math.random(0, 2048), 48, 64, 0, 1, 24, 56)
			self:new("trees", math.random(0, 2048), math.random(0, 2048), 48, 64, 1, 1, 24, 56)
		end
	end
	
	obj.update = function(self, dt)
		local dx = 0
		local dy = 0

		for k, v in ipairs(self.objects) do
			dx = (v.x + v.ox) - (gWorld.player.x + 12)
			dx = dx * dx

			dy = (v.y + v.oy) - (gWorld.player.y + 24)
			dy = dy * dy

			v.distance = math.sqrt( dx + dy )

			if v.distance <= v.radius then
				gWorld.player.x = gWorld.player.lastX
				gWorld.player.y = gWorld.player.lastY
			end
		end

		gWorld.player.lastX = gWorld.player.x
		gWorld.player.lastY = gWorld.player.y
	end

	obj.draw = function(self)
		for k, v in ipairs(self.objects) do
			if v.distance and v.distance <= 300 then
				self.quad[v.group]:setViewport(v.tx * v.width, v.ty * v.height, v.width, v.height)
				love.graphics.setColor(0, 0, 0, 127)
				love.graphics.draw(self.img[v.group], self.quad[v.group], v.x + 2, v.y + 2)
				love.graphics.setColor(255, 255, 255)
				love.graphics.draw(self.img[v.group], self.quad[v.group], v.x, v.y)
			end
		end
	end
	
	return obj
end