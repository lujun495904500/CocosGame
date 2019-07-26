--[[
	控制基类
--]]

local ControlBase = class("ControlBase")

-- 获得焦点回调
function ControlBase:onGetFocus() end

-- 失去焦点回调
function ControlBase:onLostFocus() end

-- 当输入键值
function ControlBase:onControlKey(keycode)
	print("key : " .. tostring(keycode))
end

return ControlBase
