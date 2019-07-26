--[[
	状态 缚杀计
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

local B_BindingKill = class("B_BindingKill", import("._BuffBase"))

--[[ 
	构造函数
	state		状态
	target		目标
]]
function B_BindingKill:ctor(config)
	if config then
		table.merge(self,config)
	end
end

--[[
	执行函数
	onComplete	完成回调
	type		操作类型
]]
function B_BindingKill:execute(onComplete,type,...) 
	local result = true
	if type == "SETUP" then
		self.target:setState("LOSTCTRL","S_FX",true)
		self.target:setState("FEIGNDEAD","S_FX",true)
	elseif type == "DELETE" then  
		self.target:setState("LOSTCTRL","S_FX",false)
		self.target:setState("FEIGNDEAD","S_FX",false)
	end
	if onComplete then onComplete(result) end
end

return B_BindingKill
