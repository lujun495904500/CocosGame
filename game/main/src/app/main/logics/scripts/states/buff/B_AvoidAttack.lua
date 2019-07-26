--[[
	状态 击免计
]]

local B_AvoidAttack = class("B_AvoidAttack", import("._BuffBase"))

--[[ 
	构造函数
	state		状态
	target		目标
]]
function B_AvoidAttack:ctor(config)
	if config then
		table.merge(self,config)
	end
end

--[[
	执行函数
	onComplete	完成回调
	type		操作类型
]]
function B_AvoidAttack:execute(onComplete,type,...) 
	local result = true
	if type == "SETUP" then
		self.target:setState("NOATK","S_MJ",true)
	elseif type == "DELETE" then  
		self.target:setState("NOATK","S_MJ",false)
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

return B_AvoidAttack
