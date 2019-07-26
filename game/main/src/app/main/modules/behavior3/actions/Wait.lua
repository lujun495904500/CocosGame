--[[
	Wait a few seconds.
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local Wait = class("Wait", Action)

--[[
	Creates an instance of Wait.
	properties
		milliseconds
]]
function Wait:ctor(config)
	config = config or {}
	config.name = config.name or "Wait"
	config.title = config.title or "Wait <milliseconds>ms"
	Action.ctor(self, config)
	self._waittime = self.properties.milliseconds or 0
end

-- Open method.
function Wait:open(tick)
	local startTime = os.clock()
	local waitTime = self:getRealValue(self._waittime, tick) or 0
	
    tick.blackboard:set('tconfig', {
		startTime = startTime,
		waitTime = waitTime,
	}, tick.tree.id, self.id)
end

-- Tick method.
function Wait:tick(tick)
	local currTime = os.clock()
    local tconfig = tick.blackboard:get('tconfig', tick.tree.id, self.id)

    if (currTime - tconfig.startTime) * 1000 >= tconfig.waitTime then
    	return b3.SUCCESS
	end

    return b3.RUNNING
end

return Wait
