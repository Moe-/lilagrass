class "Gui" {
	--health = 100;
	hunger = 0;
	thirst = 0;
	air = 100;
}

function Gui:__init()
	
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
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 10, 50, 10)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 10, (100-self.hunger)/2, 10)
	love.graphics.setColor(255, 255, 255)
end

function Gui:drawThirst()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 30, 50, 10)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 30, (100-self.thirst)/2, 10)
	love.graphics.setColor(255, 255, 255)
end

function Gui:drawAir()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 50, 50, 10)
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth()-75, 50, self.air/2, 10)
	love.graphics.setColor(255, 255, 255)
end

function Gui:update(hunger, thirst, air)
	self.hunger = hunger;
	self.thirst = thirst;
	self.air = air;
end