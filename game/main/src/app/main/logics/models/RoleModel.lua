--[[
	人物模型
--]]
local THIS_MODULE = ...

-- 受伤速度
local C_HURT_SPEED = 0.07

local RoleModel = class("RoleModel", import("._BasicalModel"), 
	require("app.main.modules.meta.MetaBase"))

-- 类构造函数
function RoleModel:clsctor(config)
	self:setup(config)
end

-- 类析构函数
function RoleModel:clsdtor()
	self:delete()
end

--[[
	构造函数
	battlewidth		战场宽度
	isenemy			敌人角色
]]
function RoleModel:ctor(battlewidth,isenemy)
	RoleModel.super.ctor(self)
	self._battlewidth = battlewidth
	self._isenemy = isenemy
end

-- 敌人模型
function RoleModel:setEnemy(isenemy)
	self._isenemy = isenemy
end
function RoleModel:isEnemy()
	return self._isenemy
end

-- 地图 行走
function RoleModel:mapWalk(direct,onComplete)
	self:doAction("WALK_" .. direct,onComplete)
end

-- 战场 行走
function RoleModel:battleWalk(onComplete)
	self:mapWalk(self._isenemy and "LEFT" or "RIGHT",onComplete)
end

-- 战场 站立
function RoleModel:battleStand(onComplete)
	self:doAction("STAND_" .. (self._isenemy and "LEFT" or "RIGHT"),onComplete)
end

-- 战场 撤退
function RoleModel:battleRetreat(onComplete)
	self:doAction("STAND_" .. (self._isenemy and "RIGHT" or "LEFT"),onComplete)
end

-- 战场 攻击
function RoleModel:battleAttack(onComplete)
	self:doAction("ATTACK_" .. (self._isenemy and "LEFT" or "RIGHT"),onComplete)
end

-- 战场 死亡
function RoleModel:battleDeath(onComplete)
	self:doAction("DEATH_" .. (self._isenemy and "LEFT" or "RIGHT"),onComplete)
end

-- 战场 胜利
function RoleModel:battleVictory(walk,onComplete)
	if walk then
		self:mapWalk("DOWN",onComplete)
	else
		self:doAction("STAND_DOWN",onComplete)
	end
end

-- 战场 受伤
function RoleModel:battleHurt(onComplete)
	local size = self:getModelSize()
	self:runAction(cc.Sequence:create(
		cc.MoveBy:create(C_HURT_SPEED / 2,cc.p(-size.width / 8,0)),
		cc.MoveBy:create(C_HURT_SPEED,cc.p(size.width / 4,0)),
		cc.MoveBy:create(C_HURT_SPEED,cc.p(-size.width / 4,0)),
		cc.MoveBy:create(C_HURT_SPEED,cc.p(size.width / 4,0)),
		cc.MoveBy:create(C_HURT_SPEED / 2,cc.p(-size.width / 8,0)),
		cc.CallFunc:create(function ()
			if onComplete then onComplete() end
		end)
	))
end

-- 战场 相对移动 
function RoleModel:battleMoveBy(distance,duration,onComplete)
	self:battleWalk(function ()
		self:runAction(cc.Sequence:create(
			cc.MoveBy:create(duration,cc.p(self._isenemy and -distance or distance,0)),
			cc.CallFunc:create(function() 
				self:battleStand(onComplete)
			end)
		))
	end)
end

-- 战场 绝对移动
function RoleModel:battleMoveTo(posx,duration,onComplete)
	self:battleWalk(function ()
		self:runAction(cc.Sequence:create(
			cc.MoveTo:create(duration,cc.p(
				self._isenemy and (self._battlewidth - posx) or posx,
				self:getPositionY())),
			cc.CallFunc:create(function() 
				self:battleStand(onComplete)
			end)
		))
	end)
end

-- 战场 放置
function RoleModel:battlePlaceTo(pos,onComplete)
	self:setPosition(cc.p(self._isenemy and (self._battlewidth - pos.x) or pos.x,pos.y))
	if onComplete then onComplete() end
end

return RoleModel
