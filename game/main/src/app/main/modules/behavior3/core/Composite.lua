--[[
	Composite is the base class for all composite nodes. Thus, if you want to
	create new custom composite nodes, you need to inherit from this class.
]]

local b3 = require("app.main.modules.behavior3.b3")
local BaseNode = require("app.main.modules.behavior3.core.BaseNode")
local Composite = class("Composite", BaseNode)

--[[
	构造函数
	config
		children
		name
		title
		properties
]]
function Composite:ctor(config)
	config = config or {}
	config.name = config.name or "Composite"
	config.category = b3.COMPOSITE
	BaseNode.ctor(self, config)
	self.children = self.children or {}
end

return Composite
