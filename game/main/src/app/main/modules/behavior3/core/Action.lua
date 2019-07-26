--[[
	Action is the base class for all action nodes. Thus, if you want to create
	new custom action nodes, you need to inherit from this class.
]]

local b3 = require("app.main.modules.behavior3.b3")
local BaseNode = require("app.main.modules.behavior3.core.BaseNode")
local Action = class("Action", BaseNode)

--[[
	构造函数
	config
		name
		title
		properties
]]
function Action:ctor(config)
	config = config or {}
	config.name = config.name or "Action"
	config.category = b3.ACTION
	BaseNode.ctor(self, config)
end

return Action
