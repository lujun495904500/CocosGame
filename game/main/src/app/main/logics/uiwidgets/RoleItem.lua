--[[
	角色 项目
]]
local THIS_MODULE = ...

local RoleItem = class("RoleItem", cc.Node, 
	require("app.main.modules.uiwidget.UIWidgetBase"), 
	import("._TableItem"))

-- 类扩展构造
function RoleItem:clsctor(config)
	table.merge(self,config)
end

-- 构造函数
function RoleItem:ctor(size,anchor,config,params)
	self._size = size
	self._anchor = anchor
	if config then
		table.merge(self,config)
	end
	self:setContentSize(size)
	self:updateParams(params)
end

-- 更新参数
function RoleItem:updateParams(params)
	params = params or {}
	
	if params.adviser then
		if not self._adviser then
			self._adviser = display.newSprite(self.adviserimg)
			self._advsize = self._adviser:getContentSize()
			self._adviser:setAnchorPoint(cc.p(0,0))
			self:addChild(self._adviser)
		end
		self._adviser:setVisible(true)
	else
		if self._adviser then
			self._adviser:setVisible(false)
		end
	end

	if params.name then
		if not self._label then
			self._label = fontMgr:createLabel(self.font.name,params.name,self.font.params)
			self._label:setAnchorPoint(cc.p(0,0))
			self:addChild(self._label)
		else
			self._label:setString(params.name)
			self._label:setVisible(true)
		end
		if self._adviser then
			self._label:setPosition(cc.p(self._advsize.width,0))
		else
			self._label:setPosition(cc.p(0,0))
		end
	else
		if self._label then
			self._label:setVisible(false)
		end
	end
end

return RoleItem
