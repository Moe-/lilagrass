class "Achievment" {
  name = "";
  folder = "gfx/achievments/"
}
function Achievment:__init(name, progress, unlocked)
  self.name = name
  self.image = love.graphics.newImage(self.folder .. self.name .. ".png")
  self.progress = progress
  self.unlocked = unlocked
end

function Achievment:draw(index)
	love.graphics.draw(self.image, 150*0.5, 75*index)
end

function Achievment:progress()
	if name == "collector" then
		self.progress = self.progress + 1
		if progress >= 10 then
			self.unlocked = true
		end
	end
	if name == "poison" then
		self.progress = 1
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