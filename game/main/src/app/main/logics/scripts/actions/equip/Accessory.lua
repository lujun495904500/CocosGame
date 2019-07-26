--[[
	饰品
--]]

local Accessory = class("Accessory", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Accessory:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行函数
function Accessory:execute(atype, ...) 
	local force = self.accessory:getForce()
	local intellect = self.accessory:getIntellect()
	local speed = self.accessory:getSpeed()
	local attack = self.accessory:getAttack()
	local defense = self.accessory:getDefense()
	local movespeed = self.accessory:getMoveSpeed()
	if atype == "EQUIP_ITEM" then
		if force then self.role:addForce(force, ...) end
		if intellect then self.role:addIntellect(intellect, ...) end
		if speed then self.role:addSpeed(speed, ...) end
		if attack then self.role:addAttack(attack, ...) end
		if defense then self.role:addDefense(defense, ...) end
		if movespeed then self.role:addTeamAttribute("movespeed", movespeed, ...) end
	elseif atype == "UNEQUIP_ITEM" then
		if force then self.role:addForce(-force, ...) end
		if intellect then self.role:addIntellect(-intellect, ...) end
		if speed then self.role:addSpeed(-speed, ...) end
		if attack then self.role:addAttack(-attack, ...) end
		if defense then self.role:addDefense(-defense, ...) end
		if movespeed then self.role:addTeamAttribute("movespeed", -movespeed, ...) end
	end
end

return Accessory
