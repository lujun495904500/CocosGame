--[[
	生成数组
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local Group = class("Group", Action)

--[[
	Creates an instance of Group.
	properties
		label		标签
		elements	元素，以 '|' 分割
]]
function Group:ctor(config)
	config = config or {}
	config.name = config.name or "Group"
	config.title = config.title or "Group <>"
	Action.ctor(self, config)
	self._label = self.properties.label
	self._elements = self.properties.elements
end

-- Tick method.
function Group:tick(tick)
	if self._label then
		local group = {}
		for _,elem in ipairs(string.split(self._elements,'|')) do
			group[#group + 1] = self:getRealValue(elem, tick)
		end
		tick.blackboard:set(self._label, group)
		return b3.SUCCESS
	end
    return b3.FAILURE
end

return Group
