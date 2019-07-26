--[[
	状态 策免计
]]

local B_AvoidStrategy = class("B_AvoidStrategy", import("._BuffBase"))

--[[ 
	构造函数
	state		状态
	target		目标
]]
function B_AvoidStrategy:ctor(config)
	if config then
		table.merge(self,config)
	end
end

--[[
	执行函数
	onComplete	完成回调
	type		操作类型
]]
function B_AvoidStrategy:execute(onComplete,type,...) 
	local result = true
	if type == "SETUP" then
		self.target:setState("NOSTY","S_MC",true)
	elseif type == "DELETE" then  
		self.target:setState("NOSTY","S_MC",false)
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

return B_AvoidStrategy
