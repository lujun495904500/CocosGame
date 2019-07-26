--[[
	进度条
--]]
local THIS_MODULE = ...

local ProgressBar = class("ProgressBar",cc.Node, 
	require("app.main.modules.uiwidget.UIWidgetBase"),
	import("._TableItem"))

-- 类扩展构造
function ProgressBar:clsctor(config)
	table.merge(self,config)
end

-- 构造函数
function ProgressBar:ctor(size,anchor,config,params)
	self._size = size
	self._anchor = anchor
	if config then
		table.merge(self,config)
	end
	self:setContentSize(size)

	self.stencil = cc.DrawNode:create()
	local prognode = cc.ClippingNode:create(self.stencil)
	self.progsp = display.newSprite(self.image)
	self.progsp:setContentSize(size)
	self.progsp:setAnchorPoint(anchor)
	self.progsp:setPosition(cc.p(anchor.x * size.width,anchor.y * size.height))
	prognode:addChild(self.progsp)
	self:addChild(prognode)

	-- 更新参数
	self:updateParams(params)
end

-- 更新参数
function ProgressBar:updateParams(params)
	params = params or {}

	self.value = params.value or 0
	self:updateBar()
end

-- 设置最大的值
function ProgressBar:setMaxValue(maxvalue)
	self.maxvalue = maxvalue
	if self.value > self.maxvalue then
		self.value = self.maxvalue
	end
	self:updateBar()
end

-- 设置进度条段数
function ProgressBar:setSegment(segment)
	self.segment = segment
	self:updateBar()
end

-- 更新进度条
function ProgressBar:updateBar()
	local valperseg = math.floor(self.maxvalue / self.segment)
	local proplen = (math.floor(self.value / valperseg) / self.segment) * self._size.width
	local pbegin = 0
	local pend = proplen
	if not self.rightinc then
		pbegin = self._size.width - proplen
		pend = self._size.width
	end
	self.stencil:clear()
	self.stencil:drawSolidRect(cc.p(pbegin,0),cc.p(pend,self._size.height),cc.c4f(1,0,0,1))
end

-- 设置当前值
function ProgressBar:setValue(val)
	self.value = val
	if self.value > self.maxvalue then
		self.value = self.maxvalue
	end
	self:updateBar()
end

-- 更新进度条图片
function ProgressBar:updateImage(image)
	self.progsp:setTexture(image)
end

return ProgressBar
