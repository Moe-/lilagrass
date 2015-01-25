class "Achievment" {
  name = "";
  folder = "gfx/achievments/"
}
function Achievment:__init(name, progress, unlocked)
  self.name = name
  self.image = love.graphics.newImage(self.folder .. self.name .. ".png")
  self.progressNum = progress
  self.unlocked = unlocked
end

function Achievment:draw(index)
	love.graphics.draw(self.image, 150*0.5, 75*index)
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

function table.contains(table, toCheck)
  for i, v in pairs(table) do
    if v == toCheck then
      return true
    end
  end
  return false
end