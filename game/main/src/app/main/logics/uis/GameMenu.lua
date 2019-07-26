--[[
	地图功能
]]
local THIS_MODULE = ...

local GameMenu = class("GameMenu", require("app.main.modules.ui.FrameBase"), 
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
function GameMenu:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function GameMenu:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function GameMenu:reinitWidgets()
	self.wg_menus:setVisible(false)
end

-- 打开窗口
function GameMenu:OnOpen(map)
	self:reinitWidgets()
	
	self.wg_menus:setListener({
		trigger = function(item_,pindex,index)
			local itype = item_.type
			if itype == "P" then
				self:closeFrame()
				uiMgr:openUI("packlist")
			elseif itype == "E" then
				self:closeFrame()
				gameMgr:ensureExitGame()
			end
		end,
		cancel = function()
			self:closeFrame()
		end
	})
	self.wg_menus:changeSelect(1)
	self:setFocusWidget(self.wg_menus)
end

-- 关闭窗口
function GameMenu:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function GameMenu:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function GameMenu:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function GameMenu:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return GameMenu
