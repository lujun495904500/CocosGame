--[[
	Log message
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local Log = class("Log", Action)

--[[
	Creates an instance of Log.
	properties
		type
		tag
		log
]]
function Log:ctor(config)
	config = config or {}
	config.name = config.name or "Log"
	config.title = config.title or "Log <log>"
	Action.ctor(self, config)
	self._type = self.properties.type
	self._tag = self.properties.tag
	self._log = self.properties.log
end

-- Tick method.
function Log:tick(tick)
	logMgr[self:getRealValue(self._type, tick) or "info"](logMgr, 
		self:getRealValue(self._tag, tick) or "B3", self:getRealValue(self._log, tick) or "")
    return b3.SUCCESS
end

return Log
