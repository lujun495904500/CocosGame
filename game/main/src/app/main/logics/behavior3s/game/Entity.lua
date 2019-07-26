--[[
	获得实体（角色，队伍）
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local Entity = class("Entity", Action)

--[[
	Creates an instance of Entity.
	properties
		label		标签
		rort		角色或者队伍
]]
function Entity:ctor(config)
	config = config or {}
	config.name = config.name or "Entity"
	config.title = config.title or "Entity <>"
	Action.ctor(self, config)
	self._label = self.properties.label
	self._rort = self.properties.rort
end

-- Tick method.
function Entity:tick(tick)
	if self._label then
		tick.blackboard:set(self._label, self:getRealValue(self._rort, tick):getEntity())
		return b3.SUCCESS
	end
    return b3.FAILURE
end

return Entity
