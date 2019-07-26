--[[
	地图队伍
--]]
local THIS_MODULE = ...

local C_MOVETIME = 0.32

local C_STEPWAIT = 0.1

-- 状态常量
local C_STATES = {
	-- 隐蔽
	CRYPSIS = {
		I_HSY = false,		-- 护身烟
		S_YD  = false,		-- 烟遁计
	},

	-- 消毒 
	DISINFECT = {
		S_XD  = false,		-- 杀毒计
	}
}

local MapRole = require("app.main.logics.games.map.MapRole")

local MapTeam = class("MapTeam", cc.Layer,
	require("app.main.modules.common.StatesList"),
	require("app.main.logics.games.BuffsList"))

-- 构造函数
--[[
	onComplete		初始化完成回调
	team			队伍实体
   
	config
		major		主角
		pos			位置
		method		方式
		face		面向

		faces		面向数组
		
		map			所在地图
		key			队伍键值
]]
function MapTeam:ctor(onComplete,team,config)
	self._onInitialized = onComplete
	self._team = team
	if config then
		table.merge(self,config)
	end
	self:setupTeam()
end

-- 安装队伍
function MapTeam:setupTeam()
	self._movestate= false
	self._roles = {}		-- 角色
	
	-- 初始化
	self:initStates(C_STATES)
	self:initBuffs("M")

	--异步加载
	table.asyn_walk_sequence(function ()
		self:setMoveSpeed(self._team:getMoveSpeed())

		self._teamliser = handler(self,MapTeam.teamListener)
		self._team:addListener(self._teamliser)

		--if self.major then
		--	self:setupBuff("B3",{ steps = 10 })
		--end

		if self._onInitialized then 
			self._onInitialized(self)
		end
	end,{
		-- 更新角色
		function (onComplete_)
			self:updateRoles(onComplete_)
		end

		-- 安装Buffs
		,function (onComplete_)
			self:setupBuffs(onComplete_,self._team:getBuffs())
		end
	},function (onComplete_,fn)
		fn(onComplete_)
	end)
end

-- 检查是否有效
function MapTeam:isValid()
	return not self._invalid
end

-- 释放队伍
function MapTeam:release(remove,onComplete)
	self._invalid = true
	self:deleteRoles(remove,function ()
		self._team:removeListener(self._teamliser)
		if remove then 
			self:removeFromParent(true) 
		end
		if onComplete then onComplete(true) end
	end)
end

-- 队伍监听器
function MapTeam:teamListener(onComplete,team,type,...)
	if #type >= 4 and type:sub(1,4) == "ROLE" then
		return self:updateRoles(onComplete)
	elseif type == "MOVESPEED" then
		local movespeed = ...
		self:setMoveSpeed(movespeed)
	elseif type == "ADDBUFF" then
		local bid,state = ...
		return self:setupBuff(onComplete,bid,state)
	elseif type == "REMOVEBUFF" then
		local bid = ...
		return self:deleteBuff(onComplete,bid)
	end
	if onComplete then onComplete() end
end

-- 检查 消毒状态
function MapTeam:isDisinfect()
	return self:checkStates("DISINFECT")
end

-- 检查 隐蔽状态
function MapTeam:isCrypsis()
	return self:checkStates("CRYPSIS")
end

-- 更新角色
function MapTeam:updateRoles(onComplete)
	local roles = table.filter_array(self._team:getRoles(),function(r)
		return not r:isDead()
	end) 
	local scount = dbMgr.configs.teamshow
	table.asyn_walk_sequence(onComplete, table.range(math.max(#roles, #self._roles)), function (onComplete_,i)
		if not self._roles[i] then
			if i <= scount then
				return MapRole:create(function (maprole)
					self:addChild(maprole,scount - i)
					self._roles[i] = maprole
					onComplete_(true)
				end,roles[i],table.merge({
					mapteam = self,
					map = self.map
				},self:getPosConfig(i)))
			end
		elseif not roles[i] then
			return self._roles[i]:release(true,function (result)
				if result then
					self._roles[i] = nil
				end
				onComplete_(result)
			end)
		else
			return self._roles[i]:updateRole(roles[i],onComplete_)
		end
		onComplete_(false)
	end)
end

-- 删除角色
function MapTeam:deleteRoles(remove,onComplete)
	table.asyn_walk_sequence(function ()
		self._roles = {}
		if onComplete then onComplete(true) end
	end,self._roles,function (onComplete_,role)
		role:release(remove,function (result)
			onComplete_(result)
		end)
	end)
end

-- 从地图移除该队伍
function MapTeam:removeFromMap(onComplete)
	self.map:removeTeam(onComplete,self.key)
end

-- 更新队伍
function MapTeam:updateTeam(config,onComplete)
	if config then
		table.merge(self,config)
	end
	self:deleteRoles(true,function ()
		self:updateRoles(onComplete)
	end)
end

-- 获取队伍角色面向
function MapTeam:getFaces()
	local faces = {}
	for _,rolemodel in ipairs(self._roles) do 
		faces[#faces + 1] = rolemodel:getFace()
	end
	return faces
end

-- 设置移动速度
function MapTeam:setMoveSpeed(speed)
	self._speed = speed
	self._movetime = C_MOVETIME * (1 / speed)
end

-- 获得模型位置配置
function MapTeam:getPosConfig(index)
	local posconf = nil
	if index == 1 then
		posconf = {pos = clone(self.pos), face = self.face}
	else
		posconf = self._roles[index - 1]:getNextPos(self.method)
	end
	if not self.method and self.faces and index <= #self.faces then
		posconf.face = self.faces[index]
	end
	return posconf
end

-- 测试某个点是否可以到达
function MapTeam:testReach(pos) 
	return self.map:testReach(pos,self._team:getMoveTerrain(),self)
end

-- 触发正在进入某点事件
function MapTeam:tryReaching(pos,onComplete)
	if not self:testReach(pos) then
		if self.major then
			audioMgr:playSE(gameMgr:getCollisionSE())
		end
	else
		self.map:notify(function (result)
			if not result then
				onComplete()
			end
		end, true, "TRYREACHING", pos, self)
	end
end

-- 触发进入完成事件
function MapTeam:onReached(pos,onComplete)
	self.map:triggerTerrain(function ()
		self:triggerBuffs(function ()
			self.map:notify(onComplete, true, "ONREACHED", pos, self)
		end,"STEP")
	end,pos,self)
end

-- 尝试移动 direct:方向
function MapTeam:tryMove(direct,onComplete)
	if self._movestate or #self._roles <= 0 then 
		if onComplete then onComplete(false) end
	else
		-- 计算偏移
		local offest = self.map:getDirectOffest(direct)
		return self._roles[1]:faceDirect(direct,function ()
			local destpos = cc.pAdd(self._roles[1]:getPosition(),offest)
			self:tryReaching(clone(destpos),function ()
				-- 计算移动阶梯数
				local movestep = self.map:getDirectSteps(destpos,direct)
				
				-- 构建移动对象组
				local movefns = {}
				for i,role in ipairs(self._roles) do
					local mfm = role:moveToPos(clone(i == 1 and destpos or self._roles[i-1]:getLastPosition()),
						self._movetime, movestep, C_STEPWAIT)
					if mfm then
						movefns[#movefns + 1] = mfm
					end
				end
				if self.major then
					movefns[#movefns + 1] = function (onComplete_)
						self.map:moveToOffest(onComplete_, 
							cc.p(-offest.x,-offest.y), 
							self._movetime, movestep, C_STEPWAIT)
					end
				end

				-- 执行移动操作
				self:setMoveState(true)
				table.asyn_walk_together(function ()
					self:setMoveState(false)
					self:onReached(destpos,function ()
						if onComplete then onComplete(true) end
					end)
				end,movefns,function (onComplete_,fn)
					fn(onComplete_)
				end)
			end)
		end)
	end
end

-- 测试指定位置是否使用
function MapTeam:testPosition(x,y)
	for _,role in ipairs(self._roles) do 
		if role:testPosition(x,y) then
			return true
		end
	end
	return false
end

-- 尝试进行对话操作
function MapTeam:tryTalk(onComplete,role,...)
	return self.map:tryTalk(onComplete,clone(self:getPosition()),self:getFace(),self,role,...)
end

-- 尝试进行调查操作
function MapTeam:tryResearch(onComplete)
	return self.map:tryResearch(onComplete,clone(self:getPosition()),self:getFace())
end

-- 尝试使用物品
function MapTeam:tryUseItem(onComplete,role,item,...)
	return self.map:tryUseItem(onComplete,clone(self:getPosition()),self:getFace(),self,role,item,...)
end

-- 尝试调起对话操作
function MapTeam:tryDoTalk(onComplete,pos,face,role,...)
	local args = { ... }
	table.asyn_walk_sequence(function ()
		if onComplete then onComplete(false) end
	end,self._roles,function (onComplete_,role_)
		if not role_:testPosition(pos.x,pos.y) then
			onComplete_(true)
		else
			role_:doTalk(function (result)
				if onComplete then onComplete(result) end
			end,face,role,unpack(args))
		end
	end)
end

-- 尝试调起查看操作
function MapTeam:tryDoLook(onComplete,pos,face,...)
	local args = { ... }
	table.asyn_walk_sequence(function ()
		if onComplete then onComplete(false) end
	end,self._roles,function (onComplete_,role_)
		if not role_:testPosition(pos.x,pos.y) then
			onComplete_(true)
		else
			role_:doLook(function (result)
				if onComplete then onComplete(result) end
			end,face,unpack(args))
		end
	end)
end

-- 设置移动状态
function MapTeam:setMoveState(state)
	local change = self._movestate ~= state
	self._movestate = state
	if change then
		local mspeed = state and (1 + self._speed) or 1
		for _,rolemodel in ipairs(self._roles) do 
			rolemodel:setSpeed(mspeed)
		end
	end
end

-- 获得移动状态
function MapTeam:getMoveState()
	return self._movestate
end

-- 获得队伍移动地形
function MapTeam:getMoveTerrain()
	return self._team:getMoveTerrain()
end

-- 获得队伍指定角色位置
function MapTeam:getPosition(index)
	if #self._roles == 0 then
		return self.pos
	else
		return self._roles[index or 1]:getPosition()
	end
end

-- 获得当前队伍的边界
function MapTeam:getBounds()
	return self.map:getCoordBounds(self:getPosition())
end

-- 获得队伍指定角色面向
function MapTeam:getFace(index)
	if #self._roles == 0 then
		return self.face
	else
		return self._roles[index or 1]:getFace()
	end
end

-- 获得队伍实体
function MapTeam:getEntity()
	return self._team
end

return MapTeam
