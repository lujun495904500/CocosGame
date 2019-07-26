--[[
	状态 烟遁计
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

local B_SmokeEscape = class("B_SmokeEscape", import("._BuffBase"))

--[[ 
	构造函数
	state		状态
	target		目标
]]
function B_SmokeEscape:ctor(config)
	if config then
		table.merge(self,config)
	end
end

--[[
	执行函数
	onComplete	完成回调
	type		操作类型
]]
function B_SmokeEscape:execute(onComplete,type,...) 
	local result = true
	if type == "SETUP" then
		self.target:setState("CRYPSIS","S_YD",true)
	elseif type == "DELETE" then  
		self.target:setState("CRYPSIS","S_YD",false)
	elseif type == "ROUND" then
		self.state.rounds = self.state.rounds - 1
		if self.state.rounds <= 0 then
			return self:onBattleBuffLost(onComplete,
				gameMgr:getStrings("LOST_EFFECT",{
					name = self.name
				}))
		end
	end
	if onComplete then onComplete(result) end
end

return B_SmokeEscape
