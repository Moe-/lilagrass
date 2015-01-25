class "Achievment" {
  name = "";
  folder = "gfx/achievments/"
}
function Achievment:__init(name)
  self.name = 
  self.image = love.graphics.newImage(self.folder .. self.name .. ".png")
end

function Achievment:draw(index)
	love.graphics.draw(self.image, self.quad, 150*0.5, 75*index)
end

function Achievment:getText()
	return self.text
end

function Achievment:save()
	--TODO Save
end

function table.contains(table, toCheck)
  for i, v in pairs(table) do
    if v == toCheck then
      return true
    end
  end
  return false
end