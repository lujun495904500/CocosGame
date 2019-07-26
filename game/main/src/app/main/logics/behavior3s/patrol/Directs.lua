--[[
	设置巡逻的所有方向
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local Directs = class("Directs", Action)

--[[
	Creates an instance of Directs.
	properties
		label	标签
]]
function Directs:ctor(config)
	config = config or {}
	config.name = config.name or "Directs"
	config.title = config.title or "Directs <>"
	Action.ctor(self, config)
	self._label = self.properties.label
end

-- Tick method.
function Directs:tick(tick)
	if self._label then
		tick.blackboard:set(self._label, tick.target:getDirects())
		return b3.SUCCESS
	end
    return b3.FAILURE
end

return Directs
