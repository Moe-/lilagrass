function newObjects()
	local obj = {}
	obj.objects = {}

	obj.item_tileset = love.graphics.newImage("gfx/item_tileset.png")
	obj.item_tileset_quad = love.graphics.newQuad(0, 0, 24, 32, 96, 160)

	obj.new = function(self, name, x, y)
		local o = {}

		o.name = name
		o.x = x
		o.y = y
		
		table.insert(self.objects, o)
	end

	obj.init = function(self)
		--self:new("new", 256, 256)
	end
	
	obj.update = function(self, dt)
		for k, v in ipairs(self.objects) do
			print(v.name)
		end
	end

	obj.draw = function(self)
		for k, v in ipairs(self.objects) do
			self.item_tileset_quad:setViewport(0, 0, 24, 32)
			love.graphics.draw(self.item_tileset, self.item_tileset_quad)
		end
	end
	
	return obj
end