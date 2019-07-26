--[[
	获得队伍的角色（实体和战场）
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local TeamRoles = class("TeamRoles", Action)

--[[
	Creates an instance of TeamRoles.
	properties
		label		标签
		team		实体或者战场队伍	
		alive		只筛选存活的
]]
function TeamRoles:ctor(config)
	config = config or {}
	config.name = config.name or "TeamRoles"
	config.title = config.title or "TeamRoles <>"
	Action.ctor(self, config)
	self._label = self.properties.label
	self._team = self.properties.team
	self._alive = self.properties.alive
end

-- Tick method.
function TeamRoles:tick(tick)
	if self._label then
		local team = self:getRealValue(self._team, tick)
		tick.blackboard:set(self._label, (self._alive ~= nil) and team:getAliveRoles() or team:getRoles())
		return b3.SUCCESS
	end
    return b3.FAILURE
end

return TeamRoles
