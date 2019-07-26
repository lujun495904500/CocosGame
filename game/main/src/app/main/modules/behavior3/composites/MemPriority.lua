--[[
	MemPriority is similar to Priority node, but when a child returns a
	`RUNNING` state, its index is recorded and in the next tick the,
	MemPriority calls the child recorded directly, without calling previous
	children again.	
]]

local b3 = require("app.main.modules.behavior3.b3")
local Composite = require("app.main.modules.behavior3.core.Composite")
local MemPriority = class("MemPriority", Composite)

--[[
	Creates an instance of MemPriority.
	config
		children
]]
function MemPriority:ctor(config)
	config = config or {}
	config.name = config.name or "MemPriority"
	Composite.ctor(self, config)
end

-- Open method.
function MemPriority:open(tick)
	tick.blackboard:set('runningChild', 1, tick.tree.id, self.id)
end

-- Tick method.
function MemPriority:tick(tick)
	local index = tick.blackboard:get('runningChild', tick.tree.id, self.id)
	for i = index, #self.children do
		local status = self.children[i]:_execute(tick)
		if status ~= b3.FAILURE then
			if status == b3.RUNNING then
			  tick.blackboard:set('runningChild', i, tick.tree.id, self.id)
			end
			return status
		end
	end
    return b3.FAILURE
end

return MemPriority
