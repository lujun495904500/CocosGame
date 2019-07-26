--[[
	Condition is the base class for all condition nodes. Thus, if you want to
	create new custom condition nodes, you need to inherit from this class.
]]

local b3 = require("app.main.modules.behavior3.b3")
local BaseNode = require("app.main.modules.behavior3.core.BaseNode")
local Condition = class("Condition", BaseNode)

--[[
	构造函数
	config
		name
		title
		properties
]]
function Condition:ctor(config)
	config = config or {}
	config.name = config.name or "Condition"
	config.category = b3.CONDITION
	BaseNode.ctor(self, config)
end

return Condition
