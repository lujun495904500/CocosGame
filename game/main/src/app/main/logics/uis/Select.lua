--[[
	选择
]]
local THIS_MODULE = ...

local Select = class("Select", require("app.main.modules.ui.FrameBase"), 
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
function Select:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function Select:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function Select:reinitWidgets()
	self.wg_message:setVisible(false)
	self.wg_select:setVisible(false)
end

--[[
	打开窗口
	config
		autoclose	自动关闭
		messages	显示消息
		showconfig	显示配置
		selects		显示选项
		onComplete	完成回调
		appendEnd	追加完成
]]
function Select:OnOpen(config)
	self:reinitWidgets()

	local function showSelect()
		self.wg_select:sizeToRows(#config.selects)
		self.wg_select:updateParams({
			items = config.selects
		})
		self.wg_select:setListener({
			trigger = function(item_,pindex,index)
				if config.autoclose then self:closeFrame() end
				if config.onComplete then
					config.onComplete(true,item_,pindex,index)
				end
			end,
			cancel = function ()
				if config.autoclose then self:closeFrame() end
				if config.onComplete then
					config.onComplete(false)
				end
			end
		})
		self:setFocusWidget(self.wg_select)
	end

	if config.messages then
		self.wg_message:clearText()
		self:setFocusWidget(self.wg_message)
		self.wg_message:showTexts(config.messages,table.merge({
			appendEnd = config.appendEnd,
			onComplete = showSelect
		},config.showconfig or {
			usecursor = false,	  
			ctrl_complete = false,
		}))
	else
		if config.appendEnd then
			config.appendEnd()
		end
		showSelect()
	end
end

-- 关闭窗口
function Select:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function Select:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function Select:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function Select:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return Select
