class "Achievment" {
  name = "";
  folder = "gfx/achievments/"
}
function Achievment:__init(name, progress, unlocked)
  self.name = name
  self.image = love.graphics.newImage(self.folder .. self.name .. ".png")
  self.progressNum = progress
  self.unlocked = unlocked
  self.shown = false
  self.page = 0
end

function Achievment:draw(index)
	love.graphics.draw(self.image, 150*0.5, 75*index)
end

function Achievment:reset()
	self.shown = false
end

function Achievment:progress()
	if self.name == "collector" then
		self.progressNum = self.progressNum + 1
		if self.progressNum >= 10 then
			self.unlocked = true
		end
	end
	if self.name == "poison" then
		self.progressNum = 1
		self.unlocked = true
	end
	if self.name == "wilson" then	
		self.progressNum = self.progressNum + 1
		if self.progressNum >= 5 then
			self.unlocked = true
		end
	end
end

function Achievment:getName()
	return self.name
end

function Achievment:save()
	--TODO Save
end

function Achievment:isUnlocked()
	return self.unlocked
end

function Achievment:getProgress()
	return self.progress
end

function Achievment:isShown()
	return self.shown
end
function Achievment:show()
	self.shown = true
end
function Achievment:setPage(num)
	self.page = num
end
function Achievment:getPage()
	return self.page
end

function table.contains(table, toCheck)
  for i, v in pairs(table) do
    if v == toCheck then
      return true
    end
  end
  return false
end