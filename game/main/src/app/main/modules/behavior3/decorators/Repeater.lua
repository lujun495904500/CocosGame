--[[
	Repeater is a decorator that repeats the tick signal until the child node
	return `RUNNING` or `ERROR`. Optionally, a maximum number of repetitions
	can be defined.
]]

local b3 = require("app.main.modules.behavior3.b3")
local Decorator = require("app.main.modules.behavior3.core.Decorator")
local Repeater = class("Repeater", Decorator)

--[[
	Creates an instance of Repeater.
	config
		child
	properties
		maxLoop
]]
function Repeater:ctor(config)
	config = config or {}
	config.name = config.name or "Repeater"
	config.title = config.title or "Repeat <maxLoop>x"
	Decorator.ctor(self, config)
	self._maxLoop = self.properties.maxLoop or -1
end

-- Open method.
function Repeater:open(tick)
	local maxLoop = self:getRealValue(self._maxLoop, tick) or -1

	tick.blackboard:set('tconfig', {
		maxLoop = maxLoop,
		i = 1,
	}, tick.tree.id, self.id)
end

-- Tick method.
function Repeater:tick(tick)
	if not self.child then
    	return b3.ERROR
	end

    local tconfig = tick.blackboard:get('tconfig', tick.tree.id, self.id)
    local status = b3.SUCCESS

    while tconfig.maxLoop < 0 or tconfig.i <= tconfig.maxLoop do
		status = self.child:_execute(tick)

		if status == b3.SUCCESS or status == b3.FAILURE then
			tconfig.i = tconfig.i + 1
		else
			break
		end
	end

    return status
end

return Repeater
