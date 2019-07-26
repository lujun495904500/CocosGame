--[[
	叛变AI
]]

-- 显示延时
local C_SHOW_DELAY = 0.5

-- 叛离行为树
local C_B3_BETRAY = "betray"

local Blackboard = require("app.main.modules.behavior3.core.Blackboard")
local Betray = class("Betray", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Betray:ctor(config)
	if config then
		table.merge(self, config)
	end
	self._blackboard = Blackboard:create()
end

--[[
	执行脚本 
	onComplete	完成回调
]]
function Betray:execute(onComplete)
	self._onComplete = onComplete

	if b3Mgr:getB3Tree(C_B3_BETRAY):tick(self, self._blackboard) ~= b3Mgr.SUCCESS then
		if onComplete then onComplete() end
	end
end

-- 获得叛离角色
function Betray:getRole()
	return self.role
end

-- 获得完成回调
function Betray:getOnComplete()
	return self._onComplete
end

return Betray
