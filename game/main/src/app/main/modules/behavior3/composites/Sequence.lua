--[[
	The Sequence node ticks its children sequentially until one of them
	returns `FAILURE`, `RUNNING` or `ERROR`. If all children return the
	success state, the sequence also returns `SUCCESS`.
]]

local b3 = require("app.main.modules.behavior3.b3")
local Composite = require("app.main.modules.behavior3.core.Composite")
local Sequence = class("Sequence", Composite)

--[[
	Creates an instance of Sequence.
	config
		children
]]
function Sequence:ctor(config)
	config = config or {}
	config.name = config.name or "Sequence"
	Composite.ctor(self, config)
end

-- Tick method.
function Sequence:tick(tick)
	for _,child in ipairs(self.children) do
      	local status = child:_execute(tick)

		if status ~= b3.SUCCESS then
			return status
		end
    end

    return b3.SUCCESS
end

return Sequence
