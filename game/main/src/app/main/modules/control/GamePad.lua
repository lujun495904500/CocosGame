--[[
	游戏手柄
--]]
local THIS_MODULE = ...

local GamePad = class("GamePad", cc.Layer, require("app.main.modules.common.ClassLayout"))

-- 构造函数
function GamePad:ctor()
	self:setupLayout()
	self:setupPad()
end

-- 安装面板
function GamePad:setupPad()
	if self.buttons then
		for btn,param in pairs(self.buttons) do 
			local code = ctrlMgr[param.key]
			self[param.source]:addTouchEventListener(function(event,type)
				if type == ccui.TouchEventType.began then
					ctrlMgr:setTouchPress(code, true)
				elseif type == ccui.TouchEventType.ended or type == ccui.TouchEventType.canceled then
					ctrlMgr:setTouchPress(code, false)
				end
			end)
		end
	end
end

return GamePad
