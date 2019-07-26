--[[
	The Inverter decorator inverts the result of the child, returning `SUCCESS`
	for `FAILURE` and `FAILURE` for `SUCCESS`.	
]]

local b3 = require("app.main.modules.behavior3.b3")
local Decorator = require("app.main.modules.behavior3.core.Decorator")
local Inverter = class("Inverter", Decorator)

--[[
	Creates an instance of Inverter.
	config
		child
]]
function Inverter:ctor(config)
	config = config or {}
	config.name = config.name or "Inverter"
	Decorator.ctor(self, config)
end

-- Tick method.
function Inverter:tick(tick)
	if not self.child then
    	return b3.ERROR
	end

    local status = self.child:_execute(tick)

    if status == b3.SUCCESS then
      	status = b3.FAILURE
    elseif status == b3.FAILURE then
      	status = b3.SUCCESS
	end

    return status
end

return Inverter
