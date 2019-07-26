--[[
	物品
--]]
local THIS_MODULE = ...
local C_LOGTAG = "Item"

local Item = class("Item", require("app.main.logics.games.Serializable"))

-- 构造函数
function Item:ctor(type,config)
	if type == "SERIALIZE" then
		self:loadSerialize(config)
	else  -- NEW
		self:initWithConfig(config)
	end
end

-- 保存序列
function Item:saveSerialize(serialize)
	serialize = serialize or {}

	serialize.id = self.id
	serialize.dataid = self.dataid
	serialize.count = self.count

	serialize._inititem = self._inititem

	return serialize
end

-- 加载序列
function Item:loadSerialize(serialize)
	self.id = serialize.id
	self.dataid = serialize.dataid
	self.count = serialize.count

	self._inititem = serialize._inititem
	
	self.itemdb = dbMgr.items[self.dataid]
	if self.itemdb and not self._inititem then
		self:initItemData()
	end

	self:setValid(self:checkValid())
end

-- 通过新创建初始化
function Item:initWithConfig(config)
	self.id = gameMgr:newItemID()
	self.dataid = config.id
	self.count = config.count or 1

	self.itemdb = dbMgr.items[self.dataid]
	if self.itemdb then
		self:initItemData()
	else
		logMgr:warn(C_LOGTAG, "item [%d] is't found !!!",self.dataid)
	end
	
	self:setValid(self:checkValid())
end

-- 初始化物品数据
function Item:initItemData()
	if self.count > self.itemdb.stack then
		self.count = self.itemdb.stack
	end

	self._inititem = true
end

-- 物品是否有效
function Item:checkValid()
	return (self.itemdb and self.count > 0)
end
function Item:setValid(valid)
	self.valid = valid
end
function Item:isValid()
	return self.valid
end

-- 获得物品ID
function Item:getID()
	return self.id
end

-- 获得物品数据ID
function Item:getDataID()
	return self.dataid
end

-- 获得物品数量
function Item:getCount()
	return self.count
end

-- 获得物品名称
function Item:getName()
	return self.itemdb.name
end

-- 获得物品类型
function Item:getItemType()
	return self.itemdb.type
end

-- 获得物品价格
function Item:getPrice()
	return self.itemdb.price
end

-- 获得物品最大堆叠
function Item:getStackMax()
	return self.itemdb.stack
end

-- 检查物品是否可以卖
function Item:isSellable()
	return self.itemdb.sell
end

-- 获得物品脚本
function Item:getItemScript(type)
	return self.itemdb["script_" .. type]
end

-- 获得物品参数
function Item:getItemParam(type)
	return self.itemdb["param_" .. type]
end

-- 获得物品音效
function Item:getItemSE(type)
	return self.itemdb["se_" .. type]
end

-- 获得物品特效
function Item:getItemEffect(type)
	return self.itemdb["effect_" .. type]
end

-- 添加该物品数量(私有)
function Item:_addCount(count)
	self.count = self.count + count
	self:setValid(self:checkValid())
end

-- 堆叠物品
function Item:stackItem(item)
	if self.dataid == item.dataid then
		local addmax = math.min(self.itemdb.stack - self.count, item.count)
		self:_addCount(addmax)
		item:_addCount(-addmax)
		return true
	end
	return false
end

-- 拆分物品
function Item:splitItem(count)
	local spmax = math.min(self.count,count)
	local serialize = self:saveSerialize()
	serialize.count = spmax
	self:_addCount(-spmax)
	return self.class:create("SERIALIZE",serialize)
end

-- 复制当前物品
function Item:copy()
	return self.class:create("SERIALIZE",self:saveSerialize())
end

------------------------------------------------------------- 
-- 类型提升
function Item:upgradeType()
	if self:isValid() then
		local itemtype = self:getItemType()
		if itemtype == "E" then
			local equipment = import(".Equipment",THIS_MODULE):create("SERIALIZE",self:saveSerialize())
			self.count = 0
			self:setValid(false)
			return equipment:upgradeType()
		elseif itemtype == "A" then
			local accessory = import(".Accessory",THIS_MODULE):create("SERIALIZE",self:saveSerialize())
			self.count = 0
			self:setValid(false)
			return accessory:upgradeType()
		elseif itemtype == "C" then
			local consumable = import(".Consumable",THIS_MODULE):create("SERIALIZE",self:saveSerialize())
			self.count = 0
			self:setValid(false)
			return consumable:upgradeType()
		end
	end
	return self
end
-------------------------------------------------------------

return Item
