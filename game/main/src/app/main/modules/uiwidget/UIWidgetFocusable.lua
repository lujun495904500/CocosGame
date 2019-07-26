--[[
	UI组件可焦点
]]

local UIWidgetFocusable = class("UIWidgetFocusable")

-- 使指定组件获得焦点
function UIWidgetFocusable:setFocusWidget(widget)
	if self._focuswidget ~= widget then
		if self._focuswidget then
			self._focuswidget:onLostFocus()
		end
		if widget then
			widget:onGetFocus()
			self._zorder = (self._zorder and self._zorder or 0) + 1
			widget:setLocalZOrder(self._zorder)
		end
		self._focuswidget = widget
	end
	if widget then
		widget:setVisible(true)
	end
end

-- 获得获得焦点的组件
function UIWidgetFocusable:getFocusWidget()
	return self._focuswidget
end

-- 压入焦点组件
function UIWidgetFocusable:pushFocusWidget(widget)
	self._focuswidgets = self._focuswidgets or {}
	if self._focuswidget then
		table.insert(self._focuswidgets, self._focuswidget)
	end
	self:setFocusWidget(widget)
end

-- 弹出焦点组件
function UIWidgetFocusable:popFocusWidget()
	self:setFocusWidget(nil)
	if self._focuswidgets and #self._focuswidgets > 0 then
		self:setFocusWidget(table.remove(self._focuswidgets))
	end
end

-- 清空焦点组件栈
function UIWidgetFocusable:clearFocusWidgets()
	self._focuswidgets = {}
	self:setFocusWidget(nil)
end

-- 获得焦点回调
function UIWidgetFocusable:OnWidgetGetFocus()
	if self._focuswidget then
		self._focuswidget:onGetFocus()
	end
end

-- 失去焦点回调
function UIWidgetFocusable:OnWidgetLostFocus() 
	if self._focuswidget then
		self._focuswidget:onLostFocus()
	end
end

-- 输入处理
function UIWidgetFocusable:onWidgetControlKey(keycode) 
	if self._focuswidget then
		self._focuswidget:onControlKey(keycode)
	end
end

return UIWidgetFocusable
