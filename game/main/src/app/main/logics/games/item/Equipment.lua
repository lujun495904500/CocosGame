--[[
	装备
--]]
local THIS_MODULE = ...
local C_LOGTAG = "Equipment"

local Equipment = class("Equipment", import(".Item"))

-- 构造函数
function Equipment:ctor(type,config)
	if type == "SERIALIZE" then
		self:loadSerialize(config)
	else  -- NEW
		if iskindof(config,"Item") then
			config = config:saveSerialize()
			Equipment.super.loadSerialize(self,config)
		else
			Equipment.super.initWithConfig(self,config)
		end
		if Equipment.super.checkValid(self) then
			self:initWithConfig(config)
		end
	end
end

-- 保存序列
function Equipment:saveSerialize(serialize)
	serialize = serialize or {}

	Equipment.super.saveSerialize(self,serialize)

	return serialize
end

-- 加载序列
function Equipment:loadSerialize(serialize)
	Equipment.super.loadSerialize(self,serialize)
	if Equipment.super.checkValid(self) then
		self.equipdb = dbMgr.equipments[self:getDataID()]
	end
	self:setValid(self:checkValid())
end

-- 通过新创建初始化
function Equipment:initWithConfig(config)
	self.equipdb = dbMgr.equipments[self:getDataID()]
	if not self.equipdb then
		logMgr:warn(C_LOGTAG, "equipment [%d] is't found !!!",self:getDataID())
	end
	self:setValid(self:checkValid())
end

-- 装备是否有效
function Equipment:checkValid()
	return (self.equipdb and Equipment.super.checkValid(self))
end

-- 获得装备类型
function Equipment:getEquipType()
	return self.equipdb.type
end

-- 获得装备脚本
function Equipment:getEquipScript()
	return self:getItemScript("equip")
end

------------------------------------------------------------- 
-- 类型提升
function Equipment:upgradeType()
	if self:isValid() then
		local equiptype = self:getEquipType()
		if equiptype == "W" then
			local weapon = import(".Weapon",THIS_MODULE):create("SERIALIZE",self:saveSerialize())
			self.count = 0
			self:setValid(false)
			return weapon:upgradeType()
		elseif equiptype == "A" then
			local armor = import(".Armor",THIS_MODULE):create("SERIALIZE",self:saveSerialize())
			self.count = 0
			self:setValid(false)
			return armor:upgradeType()
		end
	end
	return self
end
-------------------------------------------------------------

return Equipment
