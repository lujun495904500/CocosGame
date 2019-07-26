--[[
	This action node returns `ERROR` always.
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local Error = class("Error", Action)

-- Creates an instance of Error.
function Error:ctor(config)
	config = config or {}
	config.name = config.name or "Error"
	Action.ctor(self, config)
end

-- Tick method.
function Error:tick(tick)
	return b3.ERROR
end

return Error
