class "Gui" {
	--health = 100;
	hunger = 100;
	thirst = 100;
	air = 100;
}

function Gui:__init()
	self.foodbarImage = love.graphics.newImage("gfx/foodbar.png")
	self.foodbarQuad = love.graphics.newQuad(0, 0, 320, 64, self.foodbarImage:getWidth(), self.foodbarImage:getHeight())
	--[[self.drinkbarImage = love.graphics.newImage("gfx/drink.png")
	self.drinkbarQuad = love.graphics.newQuad(0, 0, 320, 64, self.drinkbarImage:getWidth(), self.drinkbarImage:getHeight())
	self.airbarImage = love.graphics.newImage("gfx/air.png")
	self.airbarQuad = love.graphics.newQuad(0, 0, 320, 64, self.airbarImage:getWidth(), self.airbarImage:getHeight())]]--
end

function Gui:draw()
	self:drawHunger()
	self:drawThirst()
	self:drawAir()
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
	love.graphics.draw(self.foodbarImage, self.foodbarQuad, love.graphics.getWidth()-350, 10)
end

function Gui:drawThirst()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 80, 50, 10)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 80, (100-self.thirst)/2, 10)
	love.graphics.setColor(255, 255, 255)
end

function Gui:drawAir()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 100, 50, 10)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 100, self.air/2, 10)
	love.graphics.setColor(255, 255, 255)
end

function Gui:update(hunger, thirst, air)
	self.hunger = hunger;
	self.thirst = thirst;
	self.air = air;
end