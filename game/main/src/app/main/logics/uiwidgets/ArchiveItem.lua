--[[
	存档 项目
]]
local THIS_MODULE = ...

local ArchiveItem = class("ArchiveItem", cc.Node, 
	require("app.main.modules.uiwidget.UIWidgetBase"), 
	import("._TableItem"))

-- 类扩展构造
function ArchiveItem:clsctor(config)
	table.merge(self,config)
end

-- 构造函数
function ArchiveItem:ctor(size,anchor,config,params)
	self._size = size
	self._anchor = anchor
	if config then
		table.merge(self,config)
	end
	self:setContentSize(size)
	self:updateParams(params)
end

-- 设置名字
function ArchiveItem:setName(text)
	if not self._name then
		self._name = fontMgr:createLabel(self.namefont.name,text,self.namefont.params)
		self._name:setAnchorPoint(cc.p(0,0.5))
		self._name:setPosition(cc.p(0,self._size.height/2))
		self:addChild(self._name)
	else
		self._name:setString(text)
	end
end

-- 设置日期
function ArchiveItem:setDate(date)
	if not self._date then
		self._date = fontMgr:createLabel(self.datefont.name,date,self.datefont.params)
		self._date:setAnchorPoint(cc.p(1,0))
		self._date:setPosition(cc.p(self._size.width,0))
		self:addChild(self._date)
	else
		self._date:setString(date)
	end
end

-- 设置版本号
function ArchiveItem:setVersion(version)
	if not self._version then
		self._version = fontMgr:createLabel(self.verfont.name,version,self.verfont.params)
		self._version:setAnchorPoint(cc.p(1,1))
		self._version:setPosition(cc.p(self._size.width,self._size.height))
		self:addChild(self._version)
	else
		self._version:setString(version)
	end
end

-- 更新参数
function ArchiveItem:updateParams(params)
	params = params or {}
	
	if params.new then
		self:setName(self.newtext)
	elseif params.next then
		self:setName(self.nexttext)
	else
		if params.name then
			self:setName(params.name)
		end
		if params.time then
			self:setDate(os.date("%Y/%m/%d",params.time))
		end
		if params.version then
			self:setVersion(params.version)
		end
	end
end

return ArchiveItem
