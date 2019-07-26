--[[
	消耗品
--]]
local THIS_MODULE = ...
local C_LOGTAG = "Consumable"

local Consumable = class("Consumable", import(".Item"))

-- 构造函数
function Consumable:ctor(type,config)
	if type == "SERIALIZE" then
		self:loadSerialize(config)
	else  -- NEW
		if iskindof(config,"Item") then
			config = config:saveSerialize()
			Consumable.super.loadSerialize(self,config)
		else
			Consumable.super.initWithConfig(self,config)
		end
		if Consumable.super.checkValid(self) then
			self:initWithConfig(config)
		end
	end
end

-- 保存序列
function Consumable:saveSerialize(serialize)
	serialize = serialize or {}

	Consumable.super.saveSerialize(self,serialize)
	serialize._nowtimes = self._nowtimes
	serialize._useup = self._useup

	return serialize
end

-- 加载序列
function Consumable:loadSerialize(serialize)
	Consumable.super.loadSerialize(self,serialize)
	if Consumable.super.checkValid(self) then
		self._nowtimes = serialize._nowtimes or 0
		self._useup = serialize._useup
		self._consumdb = dbMgr.consumables[self:getDataID()]
	end
	self:setValid(self:checkValid())
end

-- 通过新创建初始化
function Consumable:initWithConfig(config)
	self._nowtimes = config.nowtimes or 0
	self._useup = false

	self._consumdb = dbMgr.consumables[self:getDataID()]
	if not self._consumdb then
		logMgr:warn(C_LOGTAG, "consumable [%d] is't found !!!",self:getDataID())
	end
	self:setValid(self:checkValid())
end

-- 饰品是否有效
function Consumable:checkValid()
	return (self._consumdb and Consumable.super.checkValid(self))
end

-- 获得最少消耗次数
function Consumable:getMinTimes()
	return self._consumdb.mintimes
end

-- 获得随机消耗次数
function Consumable:getRandTimes()
	return self._consumdb.randtimes
end

-- 获得当前物品使用次数
function Consumable:getUseTimes()
	local randtimes = self._consumdb.randtimes or 0
	return (randtimes ~= 0 and math.random(0,randtimes) or 0) + self._consumdb.mintimes
end

-- 获得物品回复力
function Consumable:getRecovery()
	return self._consumdb.recovery
end

-- 获得复活兵力
function Consumable:getReviveSoldiers()
	return self._consumdb.revivesoldiers
end

-- 获得使用音效
function Consumable:getUseSE()
	return self:getItemSE("use")
end

-- 堆叠物品
function Consumable:stackItem(item)
	if Consumable.super.stackItem(self,item) then
		local totaltimes = self._nowtimes + item._nowtimes
		local usetimes = self:getUseTimes()
		if totaltimes >= usetimes then
			self:_addCount(-math.floor(totaltimes/usetimes))
			self._nowtimes = totaltimes % usetimes
		else
			self._nowtimes = totaltimes
		end
	end
end

-- 拆分物品
function Consumable:splitItem(count)
	local spitem = Consumable.super.splitItem(self,count)
	if count > 0 then
		self._nowtimes = 0
		self._useup = false
	end
	return spitem
end

-- 尝试使用该物品
function Consumable:tryUseItem()
	if not self:isUseUp() then
		self._nowtimes = self._nowtimes + 1
		if self._nowtimes >= self:getUseTimes() then
			self._useup = true
		end
		return true
	end
end

-- 该物品是否用尽
function Consumable:isUseUp()
	return (not self:isValid() or self._useup)
end

------------------------------------------------------------- 
-- 类型提升
function Consumable:upgradeType()
	return self
end
-------------------------------------------------------------

return Consumable
