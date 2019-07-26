--[[
	This action node returns `SUCCESS` always.
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local Succeeder = class("Succeeder", Action)

-- Creates an instance of Succeeder.
function Succeeder:ctor(config)
	config = config or {}
	config.name = config.name or "Succeeder"
	Action.ctor(self, config)
end

-- Tick method.
function Succeeder:tick(tick)
	return b3.SUCCESS
end

return Succeeder
