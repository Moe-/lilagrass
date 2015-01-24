-- 32 lines of goodness
-- see: http://www.love2d.org/wiki/32_lines_of_goodness

local mt_class = {}

function mt_class:extends(parent)
   self.super = parent
   setmetatable(mt_class, {__index = parent})
   parent.__members__ = parent.__members__ or {}
   return self
end

local function define(class, members)
   class.__members__ = class.__members__ or {}
   for k, v in pairs(members) do
      class.__members__[k] = v
   end
   function class:new(...)
      local newvalue = {}
      for k, v in pairs(class.__members__) do
         newvalue[k] = v
      end
      setmetatable(newvalue, {__index = class})
      if newvalue.__init then
         newvalue:__init(...)
      end
      return newvalue
   end
end

function class(name)
    local newclass = {}
   _G[name] = newclass
   return setmetatable(newclass, {__index = mt_class, __call = define})
end

-- distance
function getDistance(x1, y1, x2, y2)
  return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

-- length
function getLength(x, y)
  return math.sqrt(x*x + y*y)
end
