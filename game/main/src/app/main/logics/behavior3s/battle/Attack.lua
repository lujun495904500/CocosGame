--[[
	战斗攻击
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local Attack = class("Attack", Action)

--[[
	Creates an instance of Attack.
	properties
		role		角色
		targets		目标数组
		onComplete	完成回调
]]
function Attack:ctor(config)
	config = config or {}
	config.name = config.name or "Attack"
	config.title = config.title or "Attack <>"
	Action.ctor(self, config)
	self._role = self.properties.role
	self._targets = self.properties.targets
	self._onComplete = self.properties.onComplete
end

-- Tick method.
function Attack:tick(tick)
	if self._role and self._targets then
		local role = self:getRealValue(self._role, tick)
		local targets = self:getRealValue(self._targets, tick)
		local onComplete = self:getRealValue(self._onComplete, tick)

		local script = scriptMgr:createObject(role:getAttackScript(), {
			role = role,
			targets = targets
		})
		if script then
			script:execute(onComplete)
		else
			if onComplete then onComplete() end
		end
		
		return b3.SUCCESS
	end
    return b3.FAILURE
end

return Attack
