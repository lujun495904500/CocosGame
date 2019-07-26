--[[
	状态 疑心计
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

local B_Suspicion = class("B_Suspicion", import("._BuffBase"))

--[[ 
	构造函数
	state		状态
	target		目标
]]
function B_Suspicion:ctor(config)
	if config then
		table.merge(self,config)
	end
end

--[[
	执行函数
	onComplete	完成回调
	type		操作类型
]]
function B_Suspicion:execute(onComplete,type,...) 
	local result = true
	if type == "SETUP" then
		self.target:setState("LOSTCTRL","S_YX",true)
	elseif type == "DELETE" then  
		self.target:setState("LOSTCTRL","S_YX",false)
	elseif type == "ROUND" then
		self.state.rounds = self.state.rounds - 1
		if self.state.rounds <= 0 then
			return self:onBattleBuffLost(onComplete,
				gameMgr:getStrings("ROLE_LOSTEFFECT",{
					role = self.target:getEntity():getName(),
					name = self.name
				}))
		end
	end
	if onComplete then onComplete(result) end
end

return B_Suspicion
