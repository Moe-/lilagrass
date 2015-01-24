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
	self.foodbarImage = love.graphics.newImage("gfx/foodbar.png")
	self.foodbarQuad = love.graphics.newQuad(0, 0, 320, 64, self.foodbarImage:getWidth(), self.foodbarImage:getHeight())
	self.drinkbarImage = love.graphics.newImage("gfx/bottlebar.png")
	self.drinkbarQuad = love.graphics.newQuad(0, 0, 320, 64, self.drinkbarImage:getWidth(), self.drinkbarImage:getHeight())
	self.airbarImage = love.graphics.newImage("gfx/airbar.png")
	self.airbarQuad = love.graphics.newQuad(0, 0, 320, 64, self.airbarImage:getWidth(), self.airbarImage:getHeight())
end

function Gui:draw()
	if showHunger then
		self:drawHunger()
	end
	if showThirst then 
		self:drawThirst()
	end
	if showAir then
		self:drawAir()
	end
end

--[[function Gui:drawHealth()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 10, 50, 10)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 10, self.health/2, 10)
	love.graphics.setColor(255, 255, 255)
end]]--

function Gui:drawHunger()
	--[[love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 10, 50, 10)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 10, (100-self.hunger)/2, 10)
	love.graphics.setColor(255, 255, 255)]]--
	self.foodbarQuad = love.graphics.newQuad(0, 0, 320-(100-self.hunger)*3.2, 64, self.foodbarImage:getWidth(), self.foodbarImage:getHeight())
	love.graphics.draw(self.foodbarImage, self.foodbarQuad, 25, 10)
end

function Gui:drawThirst()
	--[[love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 80, 50, 10)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 80, (100-self.thirst)/2, 10)
	love.graphics.setColor(255, 255, 255)]]--
	self.drinkbarQuad = love.graphics.newQuad(0, 0, 320-(100-self.thirst)*3.2, 64, self.drinkbarImage:getWidth(), self.drinkbarImage:getHeight())
	love.graphics.draw(self.drinkbarImage, self.drinkbarQuad, 300, 10)
end

function Gui:drawAir()
	--[[love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 150, 50, 10)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 150, self.air/2, 10)
	love.graphics.setColor(255, 255, 255)]]--
	self.airbarQuad = love.graphics.newQuad(0, 0, 320-(100-self.air)*3.2, 64, self.airbarImage:getWidth(), self.airbarImage:getHeight())
	love.graphics.draw(self.airbarImage, self.airbarQuad, 525, 10)
end

function Gui:update(hunger, thirst, air)
	self.hunger = hunger;
	self.thirst = thirst;
	self.air = air;
	if hunger < 60 then
		showHunger = true
	end
	if thirst < 60 then
		showThirst = true
	end
	if air < 60 then
		showAir = true
	end
end