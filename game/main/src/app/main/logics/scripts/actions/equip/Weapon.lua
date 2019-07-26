--[[
	武器
--]]

local Weapon = class("Weapon", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Weapon:ctor(config)
	if config then
		table.merge(self,config)
	end
end

--[[
	执行函数
	atype	动作类型
]]
function Weapon:execute(atype, ...) 
	if self.role:checkWeapon(self.equipment) then
		if atype == "EQUIP_ITEM" then
			self.role:addAttack(self.equipment:getAttack(), ...)
			self.role:addAttackTimes(self.equipment:getAttackTimes()-1, ...)
		elseif atype == "UNEQUIP_ITEM" then
			self.role:addAttack(-self.equipment:getAttack(), ...)
			self.role:addAttackTimes(-(self.equipment:getAttackTimes()-1), ...)
		end
	end
end

return Weapon
