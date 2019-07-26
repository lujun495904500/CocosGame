--[[
	Priority ticks its children sequentially until one of them returns
	`SUCCESS`, `RUNNING` or `ERROR`. If all children return the failure state,
	the priority also returns `FAILURE`.	
]]

local b3 = require("app.main.modules.behavior3.b3")
local Composite = require("app.main.modules.behavior3.core.Composite")
local Priority = class("Priority", Composite)

--[[
	Creates an instance of Priority.
	config
		children
]]
function Priority:ctor(config)
	config = config or {}
	config.name = config.name or "Priority"
	Composite.ctor(self, config)
end

-- Tick method.
function Priority:tick(tick)
	for _,child in ipairs(self.children) do
      	local status = child:_execute(tick)

		if status ~= b3.FAILURE then
			return status
		end
    end

    return b3.FAILURE
end

return Priority
