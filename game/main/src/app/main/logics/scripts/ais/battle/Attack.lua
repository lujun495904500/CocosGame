--[[
	攻击AI
]]

-- 显示延时
local C_SHOW_DELAY = 0.5

-- 攻击行为树
local C_B3_ATTACK = "attack"

local Blackboard = require("app.main.modules.behavior3.core.Blackboard")
local Attack = class("Attack", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Attack:ctor(config)
	if config then
		table.merge(self, config)
	end
	self._blackboard = Blackboard:create()
end

--[[
	执行脚本 
	onComplete	完成回调
]]
function Attack:execute(onComplete)
	self._onComplete = onComplete

	if b3Mgr:getB3Tree(C_B3_ATTACK):tick(self, self._blackboard) ~= b3Mgr.SUCCESS then
		if onComplete then onComplete() end
	end
end

-- 获得叛离角色
function Attack:getRole()
	return self.role
end

-- 获得完成回调
function Attack:getOnComplete()
	return self._onComplete
end

return Attack
