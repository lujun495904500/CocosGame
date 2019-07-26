--[[
	状态 护身烟
]]

local M_BodyProtect = class("M_BodyProtect", import("._BuffBase"))

--[[ 
	构造函数
	state		状态
	target		目标
]]
function M_BodyProtect:ctor(config)
	if config then
		table.merge(self,config)
	end
end

--[[
	执行函数
	onComplete	完成回调
	type		操作类型
]]
function M_BodyProtect:execute(onComplete,type,...) 
	local result = true
	if type == "SETUP" then
		self.target:setState("CRYPSIS","I_HSY",true)
	elseif type == "DELETE" then  
		self.target:setState("CRYPSIS","I_HSY",false)
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

return M_BodyProtect
