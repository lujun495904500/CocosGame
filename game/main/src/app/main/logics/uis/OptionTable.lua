--[[
	选项表
]]
local THIS_MODULE = ...

local OptionTable = class("OptionTable", require("app.main.modules.ui.FrameBase"), 
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
function OptionTable:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function OptionTable:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function OptionTable:reinitWidgets()
	self.wg_options:setVisible(false)
end

--[[
	打开窗口
	config
		autoclose   自动关闭
		onComplete  完成回调
]]
function OptionTable:OnOpen(config)
	self:reinitWidgets()
	
	self.wg_options:setListener({
		trigger = function(item,pindex,index)
			if config.autoclose then self:closeFrame() end
			if config.onComplete then 
				config.onComplete(true,item,pindex,index) 
			end
		end,
		cancel = function()
			if config.autoclose then self:closeFrame() end
			if config.onComplete then 
				config.onComplete(false) 
			end
		end
	})
	self.wg_options:changeSelect(1)
	self:setFocusWidget(self.wg_options)
end

-- 关闭窗口
function OptionTable:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function OptionTable:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function OptionTable:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function OptionTable:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return OptionTable
