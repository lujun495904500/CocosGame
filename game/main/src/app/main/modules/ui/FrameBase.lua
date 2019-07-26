--[[
	顶层窗口对象
--]]
local THIS_MODULE = ...

local FrameBase = class("FrameBase", cc.Node, 
	require("app.main.modules.ui.UIBindable"), 
	require("app.main.modules.control.ControlBase"), 
	require("app.main.modules.meta.MetaBase"))

--[[
	安装窗口
	config
		params	  扩展参数
		name		名称
		csb		 csb文件
		widgets	 组件绑定
		bindings	变量绑定
]] 
function FrameBase:setup(config)
	if config.params then
		table.merge(self, config.params)
	end
	self._name = config.name 
	self._fixedz = config.fixedz 
	if config.csb then
		local csbnode = cc.CSLoader:createNode(config.csb)
		self._csbAct = cc.CSLoader:createTimeline(config.csb)
		csbnode:runAction(self._csbAct)
		self:addChild(csbnode)
		self:bindUI(csbnode,config.widgets,config.bindings,true)
	end
end

-- 删除窗口
function FrameBase:delete() end

-- 获得csb动作
function FrameBase:getCSBAction()
	return self._csbAct
end

-- 获得名称
function FrameBase:getName()
	return self._name
end

-- 设置固定Z值
function FrameBase:setFixedZ(fixedz)
	self._fixedz = fixedz
end

-- 获得固定Z值
function FrameBase:getFixedZ()
	return self._fixedz
end

-- 关闭框架
function FrameBase:closeFrame()
	uiMgr:closeUI(self._name)
end

-- 打开窗口回调
function FrameBase:OnOpen() end

-- 关闭窗口回调
function FrameBase:OnClose() end

return FrameBase
