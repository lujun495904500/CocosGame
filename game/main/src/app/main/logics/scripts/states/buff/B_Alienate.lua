--[[
	状态 离间计
]]

local B_Alienate = class("B_Alienate", import("._BuffBase"))

--[[ 
	构造函数
	state		状态
	target		目标
]]
function B_Alienate:ctor(config)
	if config then
		table.merge(self,config)
	end
end

--[[
	执行函数
	onComplete	完成回调
	type		操作类型
]]
function B_Alienate:execute(onComplete,type,...) 
	local result = true
	if type == "SETUP" then
		self.target:setState("LOSTCTRL","S_LJ",true)
		self.target:setState("BETRAY","S_LJ",true)
	elseif type == "DELETE" then  
		self.target:setState("LOSTCTRL","S_LJ",false)
		self.target:setState("BETRAY","S_LJ",false)
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

return B_Alienate
