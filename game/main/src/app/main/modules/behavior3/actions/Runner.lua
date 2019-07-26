--[[
	This action node returns RUNNING always.
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local Runner = class("Runner", Action)

-- Creates an instance of Runner.
function Runner:ctor(config)
	config = config or {}
	config.name = config.name or "Runner"
	Action.ctor(self, config)
end

-- Tick method.
function Runner:tick(tick)
	return b3.RUNNING
end

return Runner
