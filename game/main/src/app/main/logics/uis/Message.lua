--[[
	消息
]]
local THIS_MODULE = ...

local Message = class("Message", require("app.main.modules.ui.FrameBase"), 
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
function Message:ctor(config)
	self:setup(config)
	self:retain()
	self:initFrame()
end

-- 析构函数
function Message:dtor()
	self:delete()
	self:release()
end

-- 初始化窗口
function Message:initFrame()
	self:setFocusWidget(self.wg_message)
end

-- 打开窗口
function Message:OnOpen(config)
	if config then
		self:showMessage(config)
	end
end

--[[
	显示指定消息
	config
		autoclose	自动关闭
		texts		消息数组
		showconfig	显示配置
		onComplete	完成回调
		appendEnd	追加完成
]]
function Message:showMessage(config)
	self.wg_message:clearText()
	self.wg_message:showTexts(config.texts,table.merge({
		appendEnd = config.appendEnd,
		onComplete = (function ()
			if config.autoclose then self:closeFrame() end
			if config.onComplete then config.onComplete() end
		end)
	},config.showconfig or {
		usecursor = true,	   -- 默认显示配置
		hidecsrlast = true,
	}))
end

-- 清除消息
function Message:clearMessage()
	self.wg_message:clearText()
end

--[[
	追加消息
	config
		texts		追加文本
		showconfig	显示配置
		onComplete	完成回调
]]
function Message:appendMessage(config)
	self.wg_message:appendTexts(config.texts,table.merge({
		onComplete = config.onComplete
	},config.showconfig))
end

-- 获得焦点回调
function Message:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function Message:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function Message:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return Message
