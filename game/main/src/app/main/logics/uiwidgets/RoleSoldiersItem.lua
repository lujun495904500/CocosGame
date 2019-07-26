--[[
	角色兵力 项目
]]
local THIS_MODULE = ...

local RoleSoldiersItem = class("RoleSoldiersItem", cc.Node, 
	require("app.main.modules.uiwidget.UIWidgetBase"), 
	import("._TableItem"))

-- 类扩展构造
function RoleSoldiersItem:clsctor(config)
	table.merge(self,config)
end

-- 构造函数
function RoleSoldiersItem:ctor(size,anchor,config,params)
	self._size = size
	self._anchor = anchor
	if config then
		table.merge(self,config)
	end
	self:setContentSize(size)
	self:updateParams(params)
end

-- 更新参数
function RoleSoldiersItem:updateParams(params)
	params = params or {}

	if not self._adviser then
		self._adviser = display.newSprite(self.adviserimg)
		self._advsize = self._adviser:getContentSize()
		self._adviser:setAnchorPoint(cc.p(0,0))
		self:addChild(self._adviser)
	end
	self._adviser:setVisible(params.adviser)
	
	if params.name then
		if not self._label then
			self._label = fontMgr:createLabel(self.namefont.name,params.name,self.namefont.params)
			self._label:setAnchorPoint(cc.p(0,0))
			self._label:setPosition(cc.p(self._advsize.width,0))
			self:addChild(self._label)
		else
			self._label:setString(params.name)
			self._label:setVisible(true)
		end
	else
		if self._label then
			self._label:setVisible(false)
		end
	end

	if params.soldiers then
		if not self._soldiersmax then
			self._soldiersmax = fontMgr:createLabel(self.sodrsfont.name,params.soldiers.max,self.sodrsfont.params)
			self._soldiersmax:setAnchorPoint(cc.p(1,0))
			self._soldiersmax:setPosition(cc.p(self._size.width,0))
			self:addChild(self._soldiersmax)
		else
			self._soldiersmax:setString(params.soldiers.max)
			self._soldiersmax:setVisible(true)
		end
		if not self._slash then
			self._slash = fontMgr:createLabel(self.sodrsfont.name,"/",self.sodrsfont.params)
			self._slash:setAnchorPoint(cc.p(1,0))
			self._slash:setPosition(cc.p(self._size.width - self.sodrswidth,0))
			self:addChild(self._slash)
		else
			self._slash:setVisible(true)
		end
		if not self._soldiers then
			self._soldiers = fontMgr:createLabel(self.sodrsfont.name,params.soldiers.value,self.sodrsfont.params)
			self._soldiers:setAnchorPoint(cc.p(1,0))
			self._soldiers:setPosition(cc.p(self._size.width - self.sodrswidth - self._slash:getLabelSize().width,0))
			self:addChild(self._soldiers)
		else
			self._soldiers:setString(params.soldiers.value)
			self._soldiers:setVisible(true)
		end
	else
		if self._soldiers then
			self._soldiers:setVisible(false)
		end
		if self._slash then
			self._slash:setVisible(false)
		end
		if self._soldiersmax then
			self._soldiersmax:setVisible(false)
		end
	end
end

return RoleSoldiersItem
