--[[
	The MaxTime decorator limits the maximum time the node child can execute.
	Notice that it does not interrupt the execution itself (i.e., the child
	must be non-preemptive), it only interrupts the node after a `RUNNING`
	status.	
]]

local b3 = require("app.main.modules.behavior3.b3")
local Decorator = require("app.main.modules.behavior3.core.Decorator")
local MaxTime = class("MaxTime", Decorator)

--[[
	Creates an instance of MaxTime.
	config
		child
	properties
		maxTime
]]
function MaxTime:ctor(config)
	config = config or {}
	config.name = config.name or "MaxTime"
	config.title = config.title or "Max <maxTime>ms"
	Decorator.ctor(self, config)
	self._maxTime = self.properties.maxTime or 0
end

-- Open method.
function MaxTime:open(tick)
	local startTime = os.clock()
	local maxTime = self:getRealValue(self._maxTime, tick) or 0
	
    tick.blackboard:set('tconfig', {
		maxTime = maxTime,
		startTime = startTime,
	}, tick.tree.id, self.id)
end

-- Tick method.
function MaxTime:tick(tick)
	if not self.child then
    	return b3.ERROR
	end

    local currTime = os.clock()
    local tconfig = tick.blackboard:get('tconfig', tick.tree.id, self.id)

    local status = self.child:_execute(tick)
    if (currTime - tconfig.startTime) * 1000 >= tconfig.maxTime then
      	return b3.FAILURE
	end

    return status
end

return MaxTime
