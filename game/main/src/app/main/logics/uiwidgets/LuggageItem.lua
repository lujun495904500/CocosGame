--[[
	物品 项目
]]
local THIS_MODULE = ...

local LuggageItem = class("LuggageItem", cc.Node, 
	require("app.main.modules.uiwidget.UIWidgetBase"), 
	import("._TableItem"))

-- 类扩展构造
function LuggageItem:clsctor(config)
	table.merge(self,config)
end

-- 构造函数
function LuggageItem:ctor(size,anchor,config,params)
	self._size = size
	self._anchor = anchor
	if config then
		table.merge(self,config)
	end
	self:setContentSize(size)
	self:updateParams(params)
end

-- 更新参数
function LuggageItem:updateParams(params)
	params = params or {}

	if params.equiped then
		if not self._equip then
			self._equip = display.newSprite(self.equipimg)
			self._eqpsize = self._equip:getContentSize()
			self._equip:setAnchorPoint(cc.p(0,0))
			self:addChild(self._equip)
		end
		self._equip:setVisible(true)
	else
		if self._equip then
			self._equip:setVisible(false)
		end
	end

	if params.name then
		if not self._label then
			self._label = fontMgr:createLabel(self.namefont.name,params.name,self.namefont.params)
			self._label:setAnchorPoint(cc.p(0,0))
			self:addChild(self._label)
		else
			self._label:setString(params.name)
			self._label:setVisible(true)
		end
		if params.equiped then
			self._label:setPosition(cc.p(self._eqpsize.width,0))
		else
			self._label:setPosition(cc.p(0,0))
		end
	else
		if self._label then
			self._label:setVisible(false)
		end
	end

	if params.amount ~= nil then
		if not self._amount then
			self._amount = fontMgr:createLabel(self.amountfont.name,tostring(params.amount),self.amountfont.params)
			self._amount:setAnchorPoint(cc.p(1,0))
			self._amount:setPosition(cc.p(self._size.width,0))
			self:addChild(self._amount)
		else
			self._amount:setString(tostring(params.amount))
			self._amount:setVisible(true)
		end
	else
		if self._amount then
			self._amount:setVisible(false)
		end
	end
end

return LuggageItem
