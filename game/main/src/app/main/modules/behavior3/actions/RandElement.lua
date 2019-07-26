--[[
	随机元素(数组)
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local RandElement = class("RandElement", Action)

--[[
	Creates an instance of RandElement.
	properties
		label	标签
		group	数组名
]]
function RandElement:ctor(config)
	config = config or {}
	config.name = config.name or "RandElement"
	config.title = config.title or "RandElement <>"
	Action.ctor(self, config)
	self._label = self.properties.label
	self._group = self.properties.group
end

-- Tick method.
function RandElement:tick(tick)
	local group = self:getRealValue(self._group, tick)
	if self._label and group and #group > 0 then
		local rindex = math.random(1, #group)
		tick.blackboard:set(self._label, group[rindex])
		return b3.SUCCESS
	end
    return b3.FAILURE
end

return RandElement
