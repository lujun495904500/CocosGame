--[[
	武器
--]]
local THIS_MODULE = ...
local C_LOGTAG = "Weapon"

local Weapon = class("Weapon", import(".Equipment"))

-- 构造函数
function Weapon:ctor(type,config)
	if type == "SERIALIZE" then
		self:loadSerialize(config)
	else  -- NEW
		if iskindof(config,"Item") then
			config = config:saveSerialize()
			Weapon.super.loadSerialize(self,config)
		else
			Weapon.super.initWithConfig(self,config)
		end
		if Weapon.super.checkValid(self) then
			self:initWithConfig(config)
		end
	end
end

-- 保存序列
function Weapon:saveSerialize(serialize)
	serialize = serialize or {}

	Weapon.super.saveSerialize(self,serialize)

	return serialize
end

-- 加载序列
function Weapon:loadSerialize(serialize)
	Weapon.super.loadSerialize(self,serialize)
	if Weapon.super.checkValid(self) then
		self.weapondb = dbMgr.weapons[self:getDataID()]
	end
	self:setValid(self:checkValid())
end

-- 通过新创建初始化
function Weapon:initWithConfig(config)
	self.weapondb = dbMgr.weapons[self:getDataID()]
	if not self.weapondb then
		logMgr:warn(C_LOGTAG, "equipment [%d] is't found !!!",self:getDataID())
	end
	self:setValid(self:checkValid())
end

-- 装备是否有效
function Weapon:checkValid()
	return (self.weapondb and Weapon.super.checkValid(self))
end

-- 获得武器类型
function Weapon:getWeaponType()
	return self.weapondb.wtype
end

-- 获得武器攻击力
function Weapon:getAttack()
	return self.weapondb.attack
end

-- 获得武器攻击次数
function Weapon:getAttackTimes()
	return self.weapondb.atktimes
end

-- 获得武器攻击脚本
function Weapon:getAttackScript()
	return self:getItemScript("attack")
end

-- 获得武器音效
function Weapon:getWeaponSE(type)
	return self:getItemSE(type)
end

-- 获得武器特效
function Weapon:getWeaponEffect(type)
	return self:getItemEffect(type)
end

------------------------------------------------------------- 
-- 类型提升
function Weapon:upgradeType()
	return self
end
-------------------------------------------------------------

return Weapon
