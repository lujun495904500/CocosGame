--[[
	随机数参数器
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local RandValue = class("RandValue", Action)

--[[
	Creates an instance of RandValue.
	properties
		label	标签
		min		最小值
		max		最大值
]]
function RandValue:ctor(config)
	config = config or {}
	config.name = config.name or "RandValue"
	config.title = config.title or "RandValue <>"
	Action.ctor(self, config)
	self._label = self.properties.label
	self._min = self.properties.min
	self._max = self.properties.max
end

-- Tick method.
function RandValue:tick(tick)
	if self._label then
		tick.blackboard:set(self._label, 
			math.random(self:getRealValue(self._min, tick) or 0, self:getRealValue(self._max, tick) or 0))
		return b3.SUCCESS
	end
    return b3.FAILURE
end

return RandValue
