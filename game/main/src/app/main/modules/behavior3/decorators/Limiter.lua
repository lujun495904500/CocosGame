--[[
	This decorator limit the number of times its child can be called. After a
	certain number of times, the Limiter decorator returns `FAILURE` without
	executing the child.	
]]

local b3 = require("app.main.modules.behavior3.b3")
local Decorator = require("app.main.modules.behavior3.core.Decorator")
local Limiter = class("Limiter", Decorator)

--[[
	Creates an instance of Limiter.
	config
		child
	properties
		maxLoop
]]
function Limiter:ctor(config)
	config = config or {}
	config.name = config.name or "Limiter"
	config.title = config.title or "Limit <maxLoop> Activations"
	Decorator.ctor(self, config)
	self._maxLoop = self.properties.maxLoop or 0
end

-- Open method.
function Limiter:open(tick)
	local maxLoop = self:getRealValue(self._maxLoop, tick) or 0
	
	tick.blackboard:set('tconfig', {
		maxLoop = maxLoop,
		i = 1,
	}, tick.tree.id, self.id)
end

-- Tick method.
function Limiter:tick(tick)
	if not self.child then
    	return b3.ERROR
	end

	local tconfig =  tick.blackboard:get("tconfig", tick.tree.id, self.id)

    if tconfig.i <= tconfig.maxLoop then
		local status = self.child:_execute(tick)

		if status == b3.SUCCESS or status == b3.FAILURE then
			tconfig.i = tconfig.i + 1
		end
		return status
	end

    return b3.FAILURE
end

return Limiter
