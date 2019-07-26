--[[
	战场角色
--]]
local THIS_MODULE = ...

-- 显示延时
local C_SHOW_DELAY = 0.8

-- 兵力条放大因子
local C_SOLDIERBAR_SCALE = 1.5

-- 模型速度
local C_MODLE_SPEED = 2

-- 胜利速度
local C_VICTORY_SPEED = 4

-- 操作移动时间
local C_OPERMOVE_TIME = 0.2

-- 光标间距
local C_CURSOR_SPACE = 3

-- 隐藏 延时时间、阶段、闪耀时间
local C_HIDE_DELAYTIME = 1
local C_HIDE_STEP = 4
local C_HIDE_BLINKTIME = 0.5

-- 状态常量
local C_STATES = {
	-- 击免
	ATKNO = {
		F_BG = false,		-- 八卦阵
	},

	-- 击反
	ATKBACK = {
		F_BG = false,		-- 八卦阵
	},

	-- 策免
	STYNO = {
		_E = false,			
	},

	-- 策返
	STYBACK = {
		S_CF = false,		-- 策返计
	},

	-- 失控
	LOSTCTRL = {
		S_YX = false,		-- 疑心计
		S_LJ = false,		-- 离间计
		S_FX = false,		-- 傅杀计
		S_PL = false,		-- 叛乱计
	},

	-- 叛变
	BETRAY = {
		S_LJ = false,		-- 离间计
		S_PL = false,		-- 叛乱计
	},
	
	-- 假死
	FEIGNDEAD = {
		S_FX = false,		-- 傅杀计
		S_PL = false,		-- 叛乱计
	},

	-- 回合
	ROUND = {
		DEFENSE = false,	-- 防御
	}
}

local BattleRole = class("BattleRole", cc.Layer, 
	require("app.main.modules.common.ClassLayout"), 
	require("app.main.modules.common.StatesList"),
	require("app.main.logics.games.BuffsList"))

--[[
	数据统计说明
	damage		伤害量
	p_damage	物理伤害量
	s_damage	计谋伤害量
	hurt		受伤量
	p_hurt		物理受伤量
	s_hurt		计谋受伤量
	treatment	角色治疗量
	recovery	角色恢复量
	kill		杀死角色次数
	dead		角色死亡次数
	evocate		角色招魂次数
	revive		角色复活次数
	defense		角色防御次数
	formation	布阵次数
	itemuse		物品使用次数
	styuse		策略使用次数
	tstyuse		队伍策略使用次数
	styhit		策略命中次数
	lostctrl	失控次数
	betray		叛变次数
	hatred		仇恨目标
]]

--[[
	构造函数

	onComplete		初始化完成回调
	role			角色实体

	config
		isenemy		敌方角色
		citydef		城防值
		place		位置
]]
function BattleRole:ctor(onComplete,role,config)
	self:setupLayout()
	self:initStates(C_STATES)
	self:initBuffs("B")

	self._onInitialized = onComplete
	self._role = role
	if config then
		table.merge(self,config)
	end
	self:setupRole()
end

-- 初始化角色
function BattleRole:setupRole()
	self._roleoffest = 0	-- 角色偏移
	self._statistics = {}	-- 统计数据
	
	-- 选择布局组件
	if self.isenemy then
		self.pl_myrole:setVisible(false)
		self.pl_enemyrole:setVisible(true)
		self._bounds = self.pl_enemyrole:getContentSize()

		self.lb_name = self.enemy_name
		self.lb_soldiers = self.enemy_soldiers
		self.wg_soldiersbar = self.enemy_soldiersbar
	else
		self.pl_myrole:setVisible(true)
		self.pl_enemyrole:setVisible(false)
		self._bounds = self.pl_myrole:getContentSize()

		self.lb_name = self.my_name
		self.lb_soldiers = self.my_soldiers
		self.wg_soldiersbar = self.my_soldiersbar
	end
	
	-- 初始化角色数据
	self.lb_name:setString(self._role:getName())
	self.lb_soldiers:setString(tostring(self._role:getSoldiers()))
	self.wg_soldiersbar:setMaxValue(majorTeam:getSoldiersMax() * C_SOLDIERBAR_SCALE)
	self.wg_soldiersbar:setValue(self._role:getSoldiers())

	-- 初始化角色模型
	self._rolemodel = modelMgr:createObject(self._role:getModel(),
		self._bounds.width,self.isenemy)
	self._rolesize = self._rolemodel:getModelSize()
	self._rolemodel:setModelSpeed(C_MODLE_SPEED)
	self._rolemodel:battleStand()
	self._rolemodel:battlePlaceTo(cc.p(self:getStandX(), self.roleY))
	self:addChild(self._rolemodel)
	
	-- 异步加载
	table.asyn_walk_sequence(function ()
		self._roleliser = handler(self,BattleRole.roleListener)
		self._role:addListener(self._roleliser)
		self._sceneliser = handler(self,BattleRole.sceneListener)
		self.scene:addListener(self._sceneliser,self.isenemy and 40 or 20)

		if self._onInitialized then 
			self._onInitialized(self)
		end
	end,{
		-- 安装Buffs
		function (onComplete_)
			self:setupBuffs(onComplete_,self._role:getBuffs())
		end
	},function (onComplete_,fn)
		fn(onComplete_)
	end)
end

-- 检查是否有效
function BattleRole:isValid()
	return not self._invalid
end

-- 释放角色
function BattleRole:release(remove,onComplete)
	self._invalid = true
	self.scene:removeListener(self._sceneliser)
	self._role:removeListener(self._roleliser)
	self._role:clearBuff(function (bid,state)
		return not buffMgr:isMapUsable(bid)
	end,function ()
		if remove then
			self:removeFromParent(true)
		end
		if onComplete then onComplete(true) end
	end)
end

-- 角色监听器
function BattleRole:roleListener(onComplete,role,type,...)
	if type == "SOLDIERS" then
		local soldiers = ...
		self.lb_soldiers:setString(tostring(soldiers))
		self.wg_soldiersbar:setValue(soldiers)
	elseif type == "ADDBUFF" then
		local bid,state = ...
		return self:setupBuff(onComplete,bid,state)
	elseif type == "REMOVEBUFF" then
		local bid = ...
		return self:deleteBuff(onComplete,bid)
	elseif type == "DEAD" then
		return self._rolemodel:battleDeath(function ()
			self._role:clearBuff(function (bid,state)
				return not buffMgr:isMapUsable(bid)
			end,onComplete)
		end)
	elseif type == "REVIVE" then
		if self.scene:isGeneralAttack() then
			return self:doGeneralAttack(true,onComplete)
		else
			return self._rolemodel:battleStand(function ()
				self._rolemodel:battleMoveTo(self:getStandX(), C_OPERMOVE_TIME,onComplete)
			end)
		end
	end
	if onComplete then onComplete() end
end

-- 场景监听器
function BattleRole:sceneListener(onComplete,scene,type,...)
	if type =="ROUNDEND" then
		if not self:isDead() then
			return self:triggerBuffs(onComplete,"ROUND")
		end
	elseif type == "BATTLEEND" then
		local victeam = ...
		if not self:isDead() and self.team ~= victeam then
			return self._rolemodel:battleStand(onComplete)
		end
	end
	if onComplete then onComplete() end
end

-- 角色统计接口
function BattleRole:getStatistics()
	return self._statistics
end
function BattleRole:doStatistics(stype, value)
	value = value or 1
	if type(value) == "number" then
		self._statistics[stype] = (self._statistics[stype] or 0) + value
		self.team:updateStatistics(stype)
	else
		self._statistics[stype] = value
	end
end

-- 获得总攻X位置
function BattleRole:getGeneralAttackX(offest)
	return math.floor(self.p.gattack + self._rolesize.width * (offest or 0))
end

-- 获得站立X位置
function BattleRole:getStandX(offest)
	return math.floor(self.p.stand + self._rolesize.width * (self._roleoffest + (offest or 0)))
end

-- 角色位置
function BattleRole:getPlace()
	return self.place
end

-- 角色是否死亡
function BattleRole:isDead()
	return self._role:isDead()
end

-- 获得角色实体
function BattleRole:getEntity()
	return self._role
end

-- 获得队伍所属场景
function BattleRole:getScene()
	return self.scene	
end

-- 获得角色所属队伍
function BattleRole:getTeam()
	return self.team
end

-- 是否是敌方角色
function BattleRole:isEnemy()
	return self.isenemy
end

-- 获得攻击力 (队伍加成后)
function BattleRole:getAttack()
	return self._role:getAttack() * (1 + self.team:getAddition("attack", self.place))
end

-- 移除城市防御值
function BattleRole:removeCityDefense(onComplete)
	self.citydef = nil
	if onComplete then onComplete() end
end

-- 获得城市防御值
function BattleRole:getCityDefense()
	return self.citydef or 0
end

-- 获得防御力 (队伍加成后)
function BattleRole:getDefense()
	return (self._role:getDefense() + self:getCityDefense()) * 
		(1 + self.team:getAddition("defense",self.place))
end

-- 获得速度 (队伍加成后)
function BattleRole:getSpeed()
	return (self._role:getSpeed() + (self._rspeed and self._rspeed or 0)) * 
		(1 + self.team:getAddition("speed",self.place))
end

-- 获得闪避 (队伍加成后)
function BattleRole:getDodge()
	return self._role:getDodge() * (1 + self.team:getAddition("dodge",self.place))
end

-- 获得策略闪避 (队伍加成后)
function BattleRole:getStrategyDodge()
	return self._role:getStrategyDodge() * (1 + self.team:getAddition("stydodge",self.place))
end

-- 获得策略抵抗 (队伍加成后)
function BattleRole:getStrategyResistance()
	return (self._role:getStrategyResistance() + self.team:getStrategyResistance()) * 
		(1 + self.team:getAddition("styresist",self.place))
end

--[[
	设置角色偏移
	onComplete			完成回掉
	offest				偏移值
	config
		immediately		立即完成	
]]
function BattleRole:setRoleOffest(onComplete,offest,config)
	config = config or {}

	self._roleoffest = offest
	if not self._role:isDead() and not self.scene:isGeneralAttack() then
		if config.immediately then
			self._rolemodel:battlePlaceTo(cc.p(self:getStandX(), self.roleY),onComplete)
		else
			self._rolemodel:battleMoveTo(self:getStandX(), C_OPERMOVE_TIME,onComplete)
		end
	else
		if onComplete then onComplete() end
	end
end

--[[
	设置角色隐藏
	onComplete			完成回调
	hide				隐藏还是显示
	config
		immediately		立即完成
]]
function BattleRole:setRoleHide(onComplete,hide,config)
	config = config or {}
	if config.immediately or self.scene:isBattleEnd() then
		self._rolemodel:setVisible(not hide)
		if onComplete then onComplete() end
	else
		local actions = {}
		local delaytime = C_HIDE_DELAYTIME
		for i = 1,C_HIDE_STEP do
			actions[#actions + 1] = cc.Blink:create(C_HIDE_BLINKTIME,bit.lshift(1,i-1))
			if i ~= C_HIDE_STEP then
				actions[#actions + 1] = cc.DelayTime:create(delaytime)
				delaytime = delaytime / 2 
			end
		end
		
		self._rolemodel:runAction(cc.Sequence:create(
			hide and cc.Sequence:create(actions) or cc.Sequence:create(actions):reverse(),
			hide and cc.Hide:create() or cc.Show:create(),
			cc.CallFunc:create(function ()
				if onComplete then onComplete() end
			end)
		))
	end
end

-- 检查 失控
function BattleRole:isLostControl()
	return self:checkStates("LOSTCTRL")
end

-- 检查 击免
function BattleRole:isAttackNo()
	return self:checkStates("ATKNO")
end

-- 检查 击反
function BattleRole:isAttackBack()
	return self:checkStates("ATKBACK")
end

-- 检查 策免
function BattleRole:isStrategyNo()
	return self:checkStates("STYNO")
end

-- 检查 策反
function BattleRole:isStrategyBack()
	return self:checkStates("STYBACK")
end

-- 检查 叛变
function BattleRole:isBetray()
	return self:checkStates("BETRAY")
end

-- 检查 假死
function BattleRole:isFeigndead()
	return self:checkStates("FEIGNDEAD")
end

-- 回合防御
function BattleRole:setRoundDefense(state)
	self:setState("ROUND","DEFENSE",state)
end
function BattleRole:isRoundDefending()
	return self:checkState("ROUND","DEFENSE")
end

-- 获得攻击脚本
function BattleRole:getAttackScript()
	local script = nil

	local weapon = self._role:getAvailableWeapon()
	script = weapon and weapon:getAttackScript() or nil
	if script then return script end

	script = self._role:getRoleScript("attack")
	if script then return script end
	
	return gameMgr:getBattleAttack()
end

-- 获得防御脚本
function BattleRole:getDefenseScript()
	local script = nil

	local shield = self._role:getShield()
	script = shield and shield:getDefenseScript() or nil
	if script then return script end

	script = self._role:getRoleScript("defense")
	if script then return script end

	return gameMgr:getBattleDefense()
end

-- 角色选择前进
function BattleRole:selectForward(select,onComplete)
	if not self:isDead() then
		self._rolemodel:battleMoveTo(self:getStandX(select and 1 or 0), C_OPERMOVE_TIME,onComplete)
	else
		if onComplete then onComplete() end
	end
end

-- 队伍总攻
function BattleRole:doGeneralAttack(gattack,onComplete)
	if not self:isDead() then
		if gattack then
			self._rolemodel:battleMoveTo(self:getGeneralAttackX(0),
				C_OPERMOVE_TIME,function ()
					self._rolemodel:battleWalk(onComplete)
				end)
		else
			self._rolemodel:battleMoveTo( self:getStandX(), C_OPERMOVE_TIME,function ()
					self._rolemodel:battleStand(onComplete)
				end)
		end
	else
		if onComplete then onComplete() end
	end
end

-- 当角色被选择
function BattleRole:onSelect(select,allflag)
	if select then
		if not self._selhand then
			self._selhand = display.newSprite(self.selectimg)
			self._selhand:setFlippedX(self.isenemy)
			self:addChild(self._selhand)
		end
		self._selhand:stopAllActions()
		local modelx,modely = self._rolemodel:getPosition()
		self._selhand:setPosition(cc.p(
			modelx + (self._rolesize.width + C_CURSOR_SPACE) * (self.isenemy and -1 or 1),
			modely + self._rolesize.height / 2
		))
		self._selhand:setVisible(true)
		if allflag then
			self._selhand:runAction(cc.RepeatForever:create(cc.Blink:create(1,self.cursorrate)))
		end
	else
		if self._selhand then
			self._selhand:stopAllActions()
			self._selhand:setVisible(false)
		end
	end
end

-- 播放特效
function BattleRole:playEffect(ename,onComplete)
	local effect = effectMgr:createObject(ename,
		{ 
			fromenemy = not self.isenemy,
			onComplete = onComplete
		})
	effect:setPosition(cc.p(self._rolemodel:getPosition()))
	self:addChild(effect)
end

-- 攻击动作
function BattleRole:doAttack(onComplete)
	if not self:isDead() then
		self._rolemodel:battleAttack(onComplete)
	else
		if onComplete then onComplete() end
	end
end

-- 撤退动作
function BattleRole:doRetreat(onComplete)
	if not self:isDead() then
		self._rolemodel:battleRetreat(onComplete)
	else
		if onComplete then onComplete() end
	end
end

-- 胜利动作
function BattleRole:doVictory(walk,onComplete)
	if not self:isDead() then
		self._rolemodel:setModelSpeed(C_VICTORY_SPEED)
		self._rolemodel:battleVictory(walk,onComplete)
	else
		if onComplete then onComplete() end
	end
end

-- 受到攻击
function BattleRole:onAttacked(effect,onComplete)
	table.asyn_walk_together(onComplete,{
		-- 被攻击特效
		function (onComplete_)
			self:playEffect(effect,onComplete_)
		end

		-- 受伤效果
		,function (onComplete_)
			self._rolemodel:battleHurt(onComplete_)
		end
	},function (onComplete_,fn)
		fn(onComplete_)
	end)
end

-- 设置回合动作
function BattleRole:setRoundAction(action)
	self._raction = action
end

-- 回合速度
function BattleRole:setRoundSpeed(speed)
	self._rspeed = speed
end
function BattleRole:getRoundSpeed()
	return self._rspeed
end

--[[
	执行回合动作
	onComplete_	完成回调
]] 
function BattleRole:doRoundAction(onComplete_)
	if self:isDead() then
		if onComplete_ then onComplete_() end
	else
		if not self.scene:isGeneralAttack() then
			self.scene:showBattleHead(self)
		end

		local function doEnd()
			if not self.scene:isGeneralAttack() then
				self.scene:hideBattleHead(self:isEnemy())
			end
			if onComplete_ then onComplete_() end
		end

		if not self._raction then
			if self:isBetray() then
				self:setRoundAction(self.team:getBetrayAI(self))
			elseif not self:isLostControl() then
				self:setRoundAction(self.team:getAttackAI(self))
			end
		end

		if self._raction then
			self._raction:execute(doEnd)
		else
			performWithDelay(self, doEnd, C_SHOW_DELAY)
		end
	end
end

-- 清空回合数据
function BattleRole:clearRoundData()
	self:clearStates("ROUND")
	self:setRoundAction()
	self:setRoundSpeed()
end

return BattleRole
