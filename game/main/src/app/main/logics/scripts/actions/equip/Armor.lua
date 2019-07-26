--[[
	防具
--]]

local Armor = class("Armor", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Armor:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行函数
function Armor:execute(atype, ...) 
	if atype == "EQUIP_ITEM" then
		self.role:addDefense(self.equipment:getDefense(), ...)
	elseif atype == "UNEQUIP_ITEM" then
		self.role:addDefense(-self.equipment:getDefense(), ...)
	end
end

return Armor
