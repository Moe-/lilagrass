class "Gui" {
	--health = 100;
	hunger = 100;
	thirst = 100;
	air = 100;
	showHunger = false;
	showThirst = false;
	showAir = false;
}

function Gui:__init()
	self.statusbarImage = love.graphics.newImage("gfx/statusbar.png")

	self.foodbarIcon = love.graphics.newImage("gfx/food.png")
	self.foodbarImage = love.graphics.newImage("gfx/foodbar.png")
	self.foodbarQuad = love.graphics.newQuad(0, 0, 320, 64, self.foodbarImage:getWidth(), self.foodbarImage:getHeight())
	
	self.drinkbarIcon = love.graphics.newImage("gfx/bottle.png")
	self.drinkbarImage = love.graphics.newImage("gfx/bottlebar.png")
	self.drinkbarQuad = love.graphics.newQuad(0, 0, 320, 64, self.drinkbarImage:getWidth(), self.drinkbarImage:getHeight())
	
	self.airbarIcon = love.graphics.newImage("gfx/air.png")
	self.airbarImage = love.graphics.newImage("gfx/airbar.png")
	self.airbarQuad = love.graphics.newQuad(0, 0, 320, 64, self.airbarImage:getWidth(), self.airbarImage:getHeight())
	self.showHunger = false;
	self.showThirst = false;
	self.showAir = false;
end

function Gui:draw(x, y)
		if self.showHunger then
			self:drawHunger(x, y)
		end
		if self.showThirst then 
			self:drawThirst(x, y)
		end
		if self.showAir then
			self:drawAir(x, y)
		end
end

--[[function Gui:drawHealth()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 10, 50, 10)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 10, self.health/2, 10)
	love.graphics.setColor(255, 255, 255)
end]]--

function Gui:drawHunger(x, y)
	--[[love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 10, 50, 10)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 10, (100-self.hunger)/2, 10)
	love.graphics.setColor(255, 255, 255)]]--
	love.graphics.setColor(255, 255, 255)
	self.foodbarQuad = love.graphics.newQuad(0, 0, (self.hunger * 0.01) * 88, 16, self.foodbarImage:getWidth(), self.foodbarImage:getHeight())
	love.graphics.draw(self.foodbarIcon, 10 - x, 260 - y)
	love.graphics.draw(self.foodbarImage, self.foodbarQuad, 10 - x + 24, 260 - y + 8)
	love.graphics.draw(self.statusbarImage, 10 - x + 24, 260 - y + 8)
	if self.hunger > 50 then
		love.graphics.setColor(63, 255, 127, 191)
	elseif self.hunger > 25 then
		love.graphics.setColor(255, 255, 127, 191)
	elseif self.hunger > 25 then
		love.graphics.setColor(255, 63, 0, 191)
	end
	love.graphics.setFont(font2)
	love.graphics.printf(math.floor(self.hunger) .. "%", 10 - x + 24, 260 - y - 8, 88, "center")
	love.graphics.setFont(font)
end

function Gui:drawThirst(x, y)
	--[[love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 80, 50, 10)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 80, (100-self.thirst)/2, 10)
	love.graphics.setColor(255, 255, 255)]]--
	love.graphics.setColor(255, 255, 255)
	self.drinkbarQuad = love.graphics.newQuad(0, 0, (self.thirst * 0.01) * 88, 16, self.drinkbarImage:getWidth(), self.drinkbarImage:getHeight())
	love.graphics.draw(self.drinkbarIcon, 145 - x, 260 - y)
	love.graphics.draw(self.drinkbarImage, self.drinkbarQuad, 145 - x + 24, 260 - y + 8)
	love.graphics.draw(self.statusbarImage, 145 - x + 24, 260 - y + 8)
	if self.thirst > 50 then
		love.graphics.setColor(63, 255, 127, 191)
	elseif self.thirst > 25 then
		love.graphics.setColor(255, 255, 127, 191)
	else
		love.graphics.setColor(255, 63, 0, 191)
	end
	love.graphics.setFont(font2)
	love.graphics.printf(math.floor(self.thirst) .. "%", 145 - x + 24, 260 - y - 8, 88, "center")
	love.graphics.setFont(font)
end

function Gui:drawAir(x, y)
	--[[love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 150, 50, 10)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 150, self.air/2, 10)
	love.graphics.setColor(255, 255, 255)]]--
	love.graphics.setColor(255, 255, 255)
	self.airbarQuad = love.graphics.newQuad(0, 0, (self.air * 0.01) * 88, 16, self.airbarImage:getWidth(), self.airbarImage:getHeight())
	love.graphics.draw(self.airbarIcon, 280 - x, 260 - y)
	love.graphics.draw(self.airbarImage, self.airbarQuad, 280 - x + 24, 260 - y + 8)
	love.graphics.draw(self.statusbarImage, 280 - x + 24, 260 - y + 8)
	if self.air > 50 then
		love.graphics.setColor(63, 255, 127, 191)
	elseif self.air > 25 then
		love.graphics.setColor(255, 255, 127, 191)
	else
		love.graphics.setColor(255, 63, 0, 191)
	end
	love.graphics.setFont(font2)
	love.graphics.printf(math.floor(self.air) .. "%", 280 - x + 24, 260 - y - 8, 88, "center")
	love.graphics.setFont(font)
end

function Gui:update(hunger, thirst, air)
	self.hunger = hunger;
	self.thirst = thirst;
	self.air = air;
	if hunger < 60 then
		self.showHunger = true
	end
	if thirst < 60 then
		self.showThirst = true
	end
	if air < 60 then
		self.showAir = true
	end
end