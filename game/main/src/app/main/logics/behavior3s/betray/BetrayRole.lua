--[[
	获得叛离的角色
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local BetrayRole = class("BetrayRole", Action)

--[[
	Creates an instance of BetrayRole.
	properties
		label	标签
]]
function BetrayRole:ctor(config)
	config = config or {}
	config.name = config.name or "BetrayRole"
	config.title = config.title or "BetrayRole <>"
	Action.ctor(self, config)
	self._label = self.properties.label
end

-- Tick method.
function BetrayRole:tick(tick)
	if self._label then
		tick.blackboard:set(self._label, tick.target:getRole())
		return b3.SUCCESS
	end
    return b3.FAILURE
end

return BetrayRole
