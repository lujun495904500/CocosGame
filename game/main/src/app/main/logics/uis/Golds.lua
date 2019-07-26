--[[
	金币
]]
local THIS_MODULE = ...

local Golds = class("Golds", require("app.main.modules.ui.FrameBase"), 
	require("app.main.modules.uiwidget.UIWidgetFocusable"))

--[[
	构造函数
	config
		params		额外参数
		name		名称
		csb			csb文件
		widgets		组件表
		bindings	绑定表
]]
function Golds:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function Golds:dtor()
	self:delete()
	self:release()
end

--[[
	打开窗口
	team		队伍
]]
function Golds:OnOpen(team)
	self._team = team or majorTeam
	self:updateGolds()
end

-- 关闭窗口
function Golds:OnClose()
	self._team = nil
end

-- 更新金币数
function Golds:updateGolds()
	self.lb_golds:setString(tostring(self._team:getGolds()))
end

-- 获得焦点回调
function Golds:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function Golds:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function Golds:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return Golds
