--[[
	饰品
--]]
local THIS_MODULE = ...
local C_LOGTAG = "Accessory"

local Accessory = class("Accessory", import(".Item"))

-- 构造函数
function Accessory:ctor(type,config)
	if type == "SERIALIZE" then
		self:loadSerialize(config)
	else  -- NEW
		if iskindof(config,"Item") then
			config = config:saveSerialize()
			Accessory.super.loadSerialize(self,config)
		else
			Accessory.super.initWithConfig(self,config)
		end
		if Accessory.super.checkValid(self) then
			self:initWithConfig(config)
		end
	end
end

-- 保存序列
function Accessory:saveSerialize(serialize)
	serialize = serialize or {}

	Accessory.super.saveSerialize(self,serialize)
	serialize.equiped = self.equiped

	return serialize
end

-- 加载序列
function Accessory:loadSerialize(serialize)
	Accessory.super.loadSerialize(self,serialize)
	if Accessory.super.checkValid(self) then
		self.equiped = serialize.equiped
		self.accesdb = dbMgr.accessorys[self:getDataID()]
	end
	self:setValid(self:checkValid())
end

-- 通过新创建初始化
function Accessory:initWithConfig(config)
	self.equiped = config.equiped or false
	
	self.accesdb = dbMgr.accessorys[self:getDataID()]
	if not self.accesdb then
		logMgr:warn(C_LOGTAG, "accessory [%d] is't found !!!", self:getDataID())
	end
	self:setValid(self:checkValid())
end

-- 饰品是否有效
function Accessory:checkValid()
	return (self.accesdb and Accessory.super.checkValid(self))
end

-- 饰品装备
function Accessory:isEquiped()
	return self.equiped
end
function Accessory:setEquip(equip)
	self.equiped = equip
end

-- 获得装备脚本
function Accessory:getEquipScript()
	return self:getItemScript("equip")
end

-- 获得饰品武力提升
function Accessory:getForce()
	return self.accesdb.force
end

-- 获得饰品智力提升
function Accessory:getIntellect()
	return self.accesdb.intellect
end

-- 获得饰品速度提升
function Accessory:getSpeed()
	return self.accesdb.speed
end

-- 获得饰品攻击提升
function Accessory:getAttack()
	return self.accesdb.attack
end

-- 获得饰品防御提升
function Accessory:getDefense()
	return self.accesdb.defense
end

-- 获得饰品移动速度提升
function Accessory:getMoveSpeed()
	return self.accesdb.movespeed
end

------------------------------------------------------------- 
-- 类型提升
function Accessory:upgradeType()
	return self
end
-------------------------------------------------------------

return Accessory
