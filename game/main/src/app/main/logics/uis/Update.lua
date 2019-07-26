--[[
	更新UI
]]
local THIS_MODULE = ...

-- 默认颜色
local C_DEFAULT_COLOR = cc.c4b(255,255,255,255)

local Update = class("Update", require("app.main.modules.ui.FrameBase"), 
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
function Update:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function Update:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function Update:reinitWidgets()
	self.lb_update:setString("")
	self.gb_update:setPercent(0)
end

--[[
	打开窗口
	config
		text		显示的文本
		color		文本颜色
		percent		进度
]]
function Update:OnOpen(config)
	self:reinitWidgets()
	if config then
		self.lb_update:setTextColor(config.color or C_DEFAULT_COLOR)
		self.lb_update:setString(config.text or "")
		self.gb_update:setPercent(config.percent or 0)
	end
end

-- 设置更新文本
function Update:setText(text,color)
	self.lb_update:setTextColor(color or C_DEFAULT_COLOR)
	self.lb_update:setString(text)
end

-- 设置更新进度
function Update:setProgress(percent)
	self.gb_update:setPercent(percent)
end

-- 关闭窗口
function Update:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function Update:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function Update:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function Update:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return Update
