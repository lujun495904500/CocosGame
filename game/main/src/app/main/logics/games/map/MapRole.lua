--[[
	地图角色
--]]
local THIS_MODULE = ...

local MapRole = class("MapRole", cc.Layer)

-- 构造函数
--[[
	onComplete		初始化完成回调
	role			角色实体

	config
		mapteam		地图队伍 
		pos			位置
		face		面向

		inithide	初始隐藏

		map			地图
]]
function MapRole:ctor(onComplete,role,config)
	self._onInitialized = onComplete
	self._role = role
	if config then
		table.merge(self,config)
	end
	self:setupRole()
end

-- 安装角色
function MapRole:setupRole()
	self._moving = false
	self._rolemodel = modelMgr:createObject(self._role:getModel())
	self._rolemodel:mapWalk(self.face)
	self._rolemodel:setPosition(self.map:getMoveOffest())
	self:addChild(self._rolemodel)
	self:setPosition(self.pos)
	if self.inithide then
		self:setVisible(false)
	end
	
	if self._onInitialized then 
		self._onInitialized(self)
	end
end

-- 检查是否有效
function MapRole:isValid()
	return not self._invalid
end

-- 释放角色
function MapRole:release(remove,onComplete)
	self._invalid = true
	if remove then
		self:removeFromParent(true) 
	end
	if onComplete then onComplete(true) end
end

-- 测试角色是否在移动
function MapRole:testMoving()
	return self._moving
end

-- 获得角色位置
function MapRole:getPosition()
	return self.pos
end

-- 获得角色上一个位置
function MapRole:getLastPosition()
	return self._lastpos
end

-- 测试是否为指定位置
function MapRole:testPosition(x,y)
	return (self.pos.x == x and self.pos.y == y)
end

-- 获得角色方向
function MapRole:getFace()
	return self.face
end

-- 面向指定方向
function MapRole:faceDirect(direct,onComplete)
	self._rolemodel:mapWalk(direct,function ()
		self.face = direct
		if onComplete then onComplete() end
	end)
end

-- 移动到指定位置,返回移动函数
function MapRole:moveToPos(destpos,movetime,movestep,stepwait)
	self._lastpos = clone(self.pos)
	local direct = tools:getDirect(self.pos,destpos)
	
	if not direct then
		self:setVisible(true)
	else
		local caction
		local offest = cc.pSub(destpos,self.pos)
		if movestep > 0 then
			caction = cc.Repeat:create(cc.Sequence:create(
				cc.MoveBy:create(movetime / movestep,
					cc.p(offest.x / movestep,offest.y / movestep)),
				cc.DelayTime:create(stepwait)),movestep)
		else
			caction = cc.MoveBy:create(movetime,offest)
		end
		self.pos = clone(destpos)

		return function (onComplete)
			self:faceDirect(direct,function ()
				self._moving = true
				self:runAction(cc.Sequence:create(
					caction,
					cc.Place:create(destpos),
					cc.CallFunc:create(function()
						self._moving = false
						if onComplete then onComplete(true) end
					end)
				))
			end)
		end
	end
end

-- 设置角色速度
function MapRole:setSpeed(speed)
	self._rolemodel:setModelSpeed(speed)
end

-- 下一个模型位置
function MapRole:getNextPos(method)
	if method ~= "POINT" then
		local nextpos = cc.pAdd(self.pos,self.map:getDirectOffest(tools:getOppositeDirect(self.face))) 
		if self.mapteam:testReach(nextpos) then
			return  { pos = nextpos, face = self.face }
		end
	end

	return { pos = clone(self.pos), face = self.face, inithide = true }
end

-- 更新角色
function MapRole:updateRole(role,onComplete)
	if role:getDataID() ~= self._role:getDataID() then
		self:removeChild(self._rolemodel,true)
		self._rolemodel = modelMgr:createObject(role:getModel())
		self._rolemodel:mapWalk(self.face)
		self._rolemodel:setPosition(self.map:getMoveOffest())
		self:addChild(self._rolemodel)
	end
	self._role = role
	if onComplete then onComplete() end
end

-- 尝试使用物品
function MapRole:tryUseItem(onComplete,item,...)
	return self.mapteam:tryUseItem(onComplete,self,item,...)
end

-- 执行对话操作
function MapRole:doTalk(onComplete,face,role,...)
	self:faceDirect(face)
	local talk = self._role:getData("TALK")
	if talk then
		local script = scriptMgr:createObject(talk.script,talk.config)
		if script then
			return script:execute(onComplete,role,...)
		end
	end
	if onComplete then onComplete(false) end
end

-- 执行查看操作
function MapRole:doLook(onComplete,face,...)
	self:faceDirect(face)
	local look = self._role:getData("LOOK")
	if look then
		local script = scriptMgr:createObject(look.script,look.config)
		if script then
			return script:execute(onComplete,...)
		end
	end
	if onComplete then onComplete(false) end
end

-- 获得角色实体
function MapRole:getEntity()
	return self._role
end

return MapRole
