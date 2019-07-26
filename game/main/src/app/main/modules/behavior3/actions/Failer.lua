--[[
	This action node returns `FAILURE` always.
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local Failer = class("Failer", Action)

-- Creates an instance of Failer.
function Failer:ctor(config)
	config = config or {}
	config.name = config.name or "Failer"
	Action.ctor(self, config)
end

-- Tick method.
function Failer:tick(tick)
	return b3.FAILURE
end

return Failer
