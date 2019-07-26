--[[
	文本标签
--]]
local THIS_MODULE = ...

local TextLabel = class("TextLabel", cc.Node, 
	require("app.main.modules.uiwidget.UIWidgetBase"),
	import("._TableItem"))

-- 类扩展构造
function TextLabel:clsctor(config)
	table.merge(self,config)
end

-- 构造函数
function TextLabel:ctor(size,anchor,config,params)
	self._size = size
	self._anchor = anchor
	if config then
		table.merge(self,config)
	end
	self:setContentSize(size)
	self:updateParams(params)
end

-- 更新参数
function TextLabel:updateParams(params)
	params = params or {}
	self:setString(params.text or params.label)
end

-- 设置标新字符串
function TextLabel:setString(text)
	self._text = text or ""
	if not self._label then
		self._label = fontMgr:createLabel(self.font.name,self._text,self.font.params)
		self._label:setAnchorPoint(self._anchor)
		self._label:setPosition(cc.p(self._anchor.x * self._size.width,self._anchor.y * self._size.height))
		self:addChild(self._label)
	else
		self._label:setString(self._text)
	end
end

-- 获得标签字符串
function TextLabel:getString()
	return self._text or ""
end

return TextLabel
