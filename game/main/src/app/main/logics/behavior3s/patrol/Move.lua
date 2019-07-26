--[[
	巡逻移动
]]

local b3 = require("app.main.modules.behavior3.b3")
local Action = require("app.main.modules.behavior3.core.Action")
local Move = class("Move", Action)

--[[
	Creates an instance of Move.
	properties
		direct	 移动方向
]]
function Move:ctor(config)
	config = config or {}
	config.name = config.name or "Move"
	config.title = config.title or "Move <>"
	Action.ctor(self, config)
	self._direct = self.properties.direct
end

-- Tick method.
function Move:tick(tick)
	if self._direct then
		tick.target:moveDirect(self:getRealValue(self._direct, tick))
		return b3.SUCCESS
	end
    return b3.FAILURE
end

return Move
