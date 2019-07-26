--[[
	获得敌对队伍
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local EnemyTeam = class("EnemyTeam", Action)

--[[
	Creates an instance of EnemyTeam.
	properties
		label	标签
		team	队伍
]]
function EnemyTeam:ctor(config)
	config = config or {}
	config.name = config.name or "EnemyTeam"
	config.title = config.title or "EnemyTeam <>"
	Action.ctor(self, config)
	self._label = self.properties.label
	self._team = self.properties.team
end

-- Tick method.
function EnemyTeam:tick(tick)
	if self._label then
		local team = self:getRealValue(self._team, tick)
		tick.blackboard:set(self._label, team:getEnemyTeam())
		return b3.SUCCESS
	end
    return b3.FAILURE
end

return EnemyTeam
