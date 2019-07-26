--[[
	Decorator is the base class for all decorator nodes. Thus, if you want to
	create new custom decorator nodes, you need to inherit from this class.	
]]

local b3 = require("app.main.modules.behavior3.b3")
local BaseNode = require("app.main.modules.behavior3.core.BaseNode")
local Decorator = class("Decorator", BaseNode)

--[[
	构造函数
	config
		child
		name
		title
		properties
]]
function Decorator:ctor(config)
	config = config or {}
	config.name = config.name or "Decorator"
	config.category = b3.DECORATOR
	BaseNode.ctor(self, config)
	self.child = self.child or nil
end

return Decorator
