--[[
	巡逻AI
]]

-- 巡逻行为树
local C_B3_PATROL = "patrol"

local Blackboard = require("app.main.modules.behavior3.core.Blackboard")
local Patrol = class("Patrol", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Patrol:ctor(config)
	if config then
		table.merge(self,config)
	end
	self._blackboard = Blackboard:create()
end

-- 执行
function Patrol:execute()
	if not self.team:getMoveState() then
		b3Mgr:getB3Tree(C_B3_PATROL):tick(self, self._blackboard)
	end
end

-- 移动到指定方向
function Patrol:moveDirect(direct)
	if direct then
		self.team:tryMove(direct)
	end
end

-- 获得可以移动的方向
function Patrol:getDirects()
	local map 		= self.map
	local team 		= self.team
	local pos 		= team:getPosition()
	local terrain 	= team:getMoveTerrain()
	local bounds 	= self.bounds
	local stepsize 	= self.stepsize

	local directs = {}

	local directmap = {
		["RIGHT"] 	= cc.p(pos.x + stepsize.width,pos.y),
		["LEFT"] 	= cc.p(pos.x - stepsize.width,pos.y),
		["UP"] 		= cc.p(pos.x,pos.y + stepsize.height),
		["DOWN"] 	= cc.p(pos.x,pos.y - stepsize.height),
	}
	for direct,dpos in pairs(directmap) do
		if self:containPos(bounds, dpos) and map:testReach(dpos, terrain, team) then
			directs[#directs + 1] = direct
		end
	end

	return directs
end

-- 测试是否包含指定点
function Patrol:containPos(bounds,pos)
	if pos.x > bounds.x and pos.x < bounds.x + bounds.width and
		pos.y >= bounds.y and pos.y < bounds.y + bounds.height then
			return true
	end
	return false
end

return Patrol
