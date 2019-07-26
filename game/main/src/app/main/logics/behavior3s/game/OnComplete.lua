--[[
	获得完成回调
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local OnComplete = class("OnComplete", Action)

--[[
	Creates an instance of OnComplete.
	properties
		label	 标签
]]
function OnComplete:ctor(config)
	config = config or {}
	config.name = config.name or "OnComplete"
	config.title = config.title or "OnComplete <>"
	Action.ctor(self, config)
	self._label = self.properties.label
end

-- Tick method.
function OnComplete:tick(tick)
	if self._label then
		tick.blackboard:set(self._label, tick.target:getOnComplete())
		return b3.SUCCESS
	end
    return b3.FAILURE
end

return OnComplete
