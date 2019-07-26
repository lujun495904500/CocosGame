--[[
	组件基类
--]]

local UIWidgetBase = class("UIWidgetBase", 
	require("app.main.modules.ui.UIBindable"), 
	require("app.main.modules.control.ControlBase"), 
	require("app.main.modules.meta.MetaBase"))

-- 获得组件名
function UIWidgetBase:getName() 
	return self.name
end

return UIWidgetBase
