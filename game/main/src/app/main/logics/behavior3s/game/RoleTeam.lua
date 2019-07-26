--[[
	获得角色队伍（实体和战场）
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local RoleTeam = class("RoleTeam", Action)

--[[
	Creates an instance of RoleTeam.
	properties
		label	标签
		role	角色
]]
function RoleTeam:ctor(config)
	config = config or {}
	config.name = config.name or "RoleTeam"
	config.title = config.title or "RoleTeam <>"
	Action.ctor(self, config)
	self._label = self.properties.label
	self._role = self.properties.role
end

-- Tick method.
function RoleTeam:tick(tick)
	if self._label then
		tick.blackboard:set(self._label, self:getRealValue(self._role, tick):getTeam())
		return b3.SUCCESS
	end
    return b3.FAILURE
end

return RoleTeam
