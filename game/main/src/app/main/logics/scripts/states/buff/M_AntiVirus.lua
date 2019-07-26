--[[
	状态 杀毒计
]]

local M_AntiVirus = class("M_AntiVirus", import("._BuffBase"))

--[[ 
	构造函数
	state		状态
	target		目标
]]
function M_AntiVirus:ctor(config)
	if config then
		table.merge(self,config)
	end
end

--[[
	执行函数
	onComplete	完成回调
	type		操作类型
]]
function M_AntiVirus:execute(onComplete,type,...) 
	local result = true
	if type == "SETUP" then
		self.target:setState("DISINFECT","S_XD",true)
	elseif type == "DELETE" then  
		self.target:setState("DISINFECT","S_XD",false)
	elseif type == "STEP" then
		self.state.steps = self.state.steps - 1
		if self.state.steps <= 0 then
			return self:onMapBuffLost(onComplete,
				gameMgr:getStrings("LOST_EFFECT",{ 
					name = self.name 
				}))
		end
	end
	if onComplete then onComplete(result) end
end

return M_AntiVirus
