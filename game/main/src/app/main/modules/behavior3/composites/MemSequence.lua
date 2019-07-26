--[[
	MemSequence is similar to Sequence node, but when a child returns a
	`RUNNING` state, its index is recorded and in the next tick the
	MemPriority call the child recorded directly, without calling previous
	children again.
]]
local C_LOGTAG = "MemSequence"

local b3 = require("app.main.modules.behavior3.b3")
local Composite = require("app.main.modules.behavior3.core.Composite")
local MemSequence = class("MemSequence", Composite)

--[[
	Creates an instance of MemSequence.
	config
		children
]]
function MemSequence:ctor(config)
	config = config or {}
	config.name = config.name or "MemSequence"
	Composite.ctor(self, config)
end

-- Open method.
function MemSequence:open(tick)
	tick.blackboard:set('runningChild', 1, tick.tree.id, self.id)
end

-- Tick method.
function MemSequence:tick(tick)
	local index = tick.blackboard:get('runningChild', tick.tree.id, self.id)
	for i = index, #self.children do
		local status = self.children[i]:_execute(tick)
		--logMgr:debug(C_LOGTAG, "index %d status %d", i, status)
		if status ~= b3.SUCCESS then
			if status == b3.RUNNING then
			  	tick.blackboard:set('runningChild', i, tick.tree.id, self.id)
			end
			return status
		end
	end
    return b3.SUCCESS
end

return MemSequence
