--[[
	游戏包 项目
]]
local THIS_MODULE = ...

local PackItem = class("PackItem", cc.Node, 
	require("app.main.modules.uiwidget.UIWidgetBase"), 
	import("._TableItem"))

-- 类扩展构造
function PackItem:clsctor(config)
	table.merge(self,config)
end

-- 构造函数
function PackItem:ctor(size,anchor,config,params)
	self._size = size
	self._anchor = anchor
	if config then
		table.merge(self,config)
	end
	self:setContentSize(size)
	self:updateParams(params)
end

-- 设置类型
function PackItem:setType(ptype)
	if not self._type then
		self._type = fontMgr:createLabel(self.typefont.name,ptype,self.typefont.params)
		self._type:setAnchorPoint(cc.p(0,0.5))
		self._type:setPosition(cc.p(0,self._size.height/2))
		self:addChild(self._type)
	else
		self._type:setString(ptype)
	end
end

-- 设置名字
function PackItem:setName(text)
	if not self._name then
		self._name = fontMgr:createLabel(self.namefont.name,text,self.namefont.params)
		self._name:setAnchorPoint(cc.p(0.5,0.5))
		self._name:setPosition(cc.p(self._size.width/2,self._size.height/2))
		self:addChild(self._name)
	else
		self._name:setString(text)
	end
end

-- 设置版本号
function PackItem:setVersion(version)
	if type(version) ~= "string" then
		version = utils.get_version_name(version)
	end
	if not self._version then
		self._version = fontMgr:createLabel(self.verfont.name,version,self.verfont.params)
		self._version:setAnchorPoint(cc.p(1,0.5))
		self._version:setPosition(cc.p(self._size.width,self._size.height/2))
		self:addChild(self._version)
	else
		self._version:setString(version)
	end
end

-- 更新参数
function PackItem:updateParams(params)
	params = params or {}
	if params.type then
		self:setType(params.type)
	end
	if params.name then
		self:setName(params.name)
	end
	if params.version then
		self:setVersion(params.version)
	end
end

return PackItem
