--[[
	防具
--]]
local THIS_MODULE = ...
local C_LOGTAG = "Armor"

local Armor = class("Armor", import(".Equipment"))

-- 构造函数
function Armor:ctor(type,config)
	if type == "SERIALIZE" then
		self:loadSerialize(config)
	else  -- NEW
		if iskindof(config,"Item") then
			config = config:saveSerialize()
			Armor.super.loadSerialize(self,config)
		else
			Armor.super.initWithConfig(self,config)
		end
		if Armor.super.checkValid(self) then
			self:initWithConfig(config)
		end
	end
end

-- 保存序列
function Armor:saveSerialize(serialize)
	serialize = serialize or {}

	Armor.super.saveSerialize(self,serialize)

	return serialize
end

-- 加载序列
function Armor:loadSerialize(serialize)
	Armor.super.loadSerialize(self,serialize)
	if Armor.super.checkValid(self) then
		self.armordb = dbMgr.armors[self:getDataID()]
	end
	self:setValid(self:checkValid())
end

-- 通过新创建初始化
function Armor:initWithConfig(config)
	self.armordb = dbMgr.armors[self:getDataID()]
	if not self.armordb then
		logMgr:warn(C_LOGTAG, "equipment [%d] is't found !!!",self:getDataID())
	end
	self:setValid(self:checkValid())
end

-- 装备是否有效
function Armor:checkValid()
	return (self.armordb and Armor.super.checkValid(self))
end

-- 获得防具类型
function Armor:getArmorType()
	return self.armordb.atype
end

-- 获得防具防御力
function Armor:getDefense()
	return self.armordb.defense
end

-- 获得防御防御脚本
function Armor:getDefenseScript()
	return self:getItemScript("defense")
end

------------------------------------------------------------- 
-- 类型提升
function Armor:upgradeType()
	return self
end
-------------------------------------------------------------

return Armor
