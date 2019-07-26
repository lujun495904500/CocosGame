--[[
	状态 策返计
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

local B_StrategyBack = class("B_StrategyBack", import("._BuffBase"))

--[[ 
	构造函数
	state		状态
	target		目标
]]
function B_StrategyBack:ctor(config)
	if config then
		table.merge(self,config)
	end
end

--[[
	执行函数
	onComplete	完成回调
	type		操作类型
]]
function B_StrategyBack:execute(onComplete,type,...) 
	local result = true
	if type == "SETUP" then
		self.target:setState("STYBACK","S_CF",true)
	elseif type == "DELETE" then  
		self.target:setState("STYBACK","S_CF",false)
	end
	if onComplete then onComplete(result) end
end

return B_StrategyBack
