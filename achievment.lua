class "Achievment" {
  text = "";
}
function Achievment:__init(text)
  self.text = text
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