--[[
	RepeatUntilFailure is a decorator that repeats the tick signal until the
	node child returns `FAILURE`, `RUNNING` or `ERROR`. Optionally, a maximum
	number of repetitions can be defined.	
]]

local b3 = require("app.main.modules.behavior3.b3")
local Decorator = require("app.main.modules.behavior3.core.Decorator")
local RepeatUntilFailure = class("RepeatUntilFailure", Decorator)

--[[
	Creates an instance of RepeatUntilFailure.
	config
		child
	properties
		maxLoop
]]
function RepeatUntilFailure:ctor(config)
	config = config or {}
	config.name = config.name or "RepeatUntilFailure"
	config.title = config.title or "Repeat Until Failure"
	Decorator.ctor(self, config)
	self._maxLoop = self.properties.maxLoop or -1
end

-- Open method.
function RepeatUntilFailure:open(tick)
	local maxLoop = self:getRealValue(self._maxLoop, tick) or -1

	tick.blackboard:set('tconfig', {
		maxLoop = maxLoop,
		i = 1,
	}, tick.tree.id, self.id)
end

-- Tick method.
function RepeatUntilFailure:tick(tick)
	if not self.child then
    	return b3.ERROR
	end

    local tconfig = tick.blackboard:get('tconfig', tick.tree.id, self.id)
    local status = b3.ERROR

    while tconfig.maxLoop < 0 or tconfig.i <= tconfig.maxLoop do
		status = self.child:_execute(tick)

		if status == b3.SUCCESS then
			tconfig.i = tconfig.i + 1
		else
			break
		end
	end

    return status
end

return RepeatUntilFailure
