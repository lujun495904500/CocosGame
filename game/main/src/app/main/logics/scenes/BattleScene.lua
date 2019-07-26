--[[
	战斗场景
]]
local THIS_MODULE = ...

-- 头像资源索引
local C_HEAD_IPATH = "res/files/heads"

-- 攻击延时
local C_ATTACK_DELAY = 0.3

-- 速度波动
local C_SPEED_SWING = 0.1

-- 结算波动
local C_BALANCE_SWING = 0.1

-- 战斗结算
local C_BATTLE_BALANCE = "BATTLE_BALANCE"

-- 切换特效
local C_TRANSITION = {
	method = "FADE",
	time = 0.4,
}

-- 战斗环境模块
local C_BATENV_MODULE = "BATTLEENV"

-- 注册模块元数据配置
metaMgr:registerModule(C_BATENV_MODULE, "src/battles/envs", "res/battles/envs")

local AsynchNotifier = require("app.main.modules.common.AsynchNotifier")
local BattleTeam = require("app.main.logics.games.battle.BattleTeam")

local BattleScene = class("BattleScene", require("app.main.modules.scene.SceneBase"), 
	require("app.main.modules.common.ClassLayout"),
	AsynchNotifier)

-- 构造场景
--[[
	onComplete			初始化完成回调
	config
		our
			team		我方队伍
			ai			队伍AI
			betrayai	叛变AI
			citydef		城防状态
		enemy
			team		敌方队伍
			ai			队伍AI
			betrayai	叛变AI
			citydef		城防状态
		balance			结算信息
		terrain			地形
		environment		战场环境
		bgm				背景音乐
]]
function BattleScene:ctor(onComplete,config)
	self._onInitialized = onComplete
	if config then
		table.merge(self,config)
	end
	self:setup()
	self:setupBattle()
end

-- 析构场景
function BattleScene:dtor(onComplete)
	self._onDestroyed = onComplete
	self:delete()
	self:deleteBattle()
end

-- 安装战场
function BattleScene:setupBattle()
	self._rdcount = 0		-- 回合数
	self._events = {}		-- 事件表

	-- 初始化
	self:setupLayout()
	self:initNotifier()

	-- 战场环境
	self:setEnvironment(self.environment)

	-- 异步加载
	table.asyn_walk_sequence(function ()
		-- 战斗结算信息
		if not self.balance then
			local roles = {}
			for _,role in ipairs(self.enemy.team:getRoles()) do
				roles[#roles + 1] = {
					soldiers = role:getSoldiers(),
				}
			end
			local exps,golds = formulaMgr:calculate(C_BATTLE_BALANCE,{

			},roles)
			self.balance = {
				exps = tools:getSwingRand(exps,C_BALANCE_SWING),
				golds = tools:getSwingRand(golds,C_BALANCE_SWING),
			}
		end

		-- 添加UI层
		uiMgr:attach(self)

		-- 添加控制层
		if not device.IS_WINDOWS then
			ctrlMgr:attachGamePad(self)
		end

		-- 播放背景音乐
		audioMgr:playBGM(self.bgm)

		if self._onInitialized then 
			self._onInitialized(self)
		end
	end,{
		-- 战场我方队伍
		function (onComplete_)
			BattleTeam:create(function (batteam)
				self._ourteam = batteam
				self.pl_ourteam:addChild(batteam)
				onComplete_(true)
			end,self.our.team,{ 
				scene = self, 
				ai = self.our.ai, 
				citydef = self.our.citydef,
				isenemy = false 
			})
		end

		-- 战场敌方队伍
		,function (onComplete_)
			BattleTeam:create(function(batteam)
				self._enemyteam = batteam
				self.pl_enemyteam:addChild(batteam)
				onComplete_(true)
			end,self.enemy.team,{ 
				scene = self, 
				ai = self.enemy.ai, 
				citydef = self.enemy.citydef,
				isenemy = true 
			})
		end

		-- 剧本安装
		,function (onComplete_)
			playMgr:doCurrentPlay(function ()
				onComplete_(true)
			end,"SETUPBATTLE",self)
		end
	},function (onComplete_,fn)
		fn(onComplete_)
	end)
end

-- 删除战场
function BattleScene:deleteBattle()
	-- 异步卸载
	table.asyn_walk_sequence(function ()
		-- 停止背景音乐
		audioMgr:stopBGM()

		-- 移除UI
		uiMgr:detach()

		if self._onDestroyed then 
			self._onDestroyed(self)
		end
	end,{
		-- 删除剧本
		function (onComplete_)
			playMgr:doCurrentPlay(onComplete_,"DELETEBATTLE",self)
		end

		-- 释放战场队伍
		,function (onComplete_)
			self:releaseTeams(onComplete_)
		end
		
	},function (onComplete_,fn)
		fn(onComplete_)
	end)
end

-- 释放战场队伍
function BattleScene:releaseTeams(onComplete)
	table.asyn_walk_sequence(onComplete,{
		-- 战场敌方队伍
		function (onComplete_)
			self._enemyteam:release(false,onComplete_)
		end
		
		-- 战场我方队伍
		,function (onComplete_)
			self._ourteam:release(false,onComplete_)
		end
	},function (onComplete_,fn)
		fn(onComplete_)
	end)
end

-- 添加事件
function BattleScene:addEvent(onComplete,trigger,key,event)
	local events = self._events[trigger]
	if not events then
		events = {}
		self._events[trigger] = events
	end
	if (not event.enable or archMgr:checkEventPoint(unpack(event.enable))) and
		(not event.disable or not archMgr:checkEventPoint(unpack(event.disable))) then
		event.escript = event.escript or scriptMgr:createObject(event.script.script,event.script.config)
		if event.escript then
			return event.escript:execute(function (result)
				if result then
					events[key] = event
				end
				if onComplete then onComplete(result) end
			end,"SETUP", self, event)
		end
	end
	if onComplete then onComplete(false) end
end

-- 移除事件
function BattleScene:removeEvent(onComplete,trigger,key)
	local events = self._events[trigger]
	if events then 
		local event = events[key]
		if event and event.escript then
			return event.escript:execute(function (result)
				if result then
					events[key] = nil 
				end
				if onComplete then onComplete(result) end
			end,"DELETE")
		end
	end
	if onComplete then onComplete(false) end
end

-- 触发事件
function BattleScene:triggerEvents(onComplete,trigger,...)
	local args = { ... }
	table.asyn_walk_sequence(function ()
		if onComplete then onComplete(false) end
	end,self._events[trigger] or {},function (_onComplete,event,key)
		if event.escript and 
			(not event.enable or archMgr:checkEventPoint(unpack(event.enable))) and
			(not event.disable or not archMgr:checkEventPoint(unpack(event.disable))) then
			return event.escript:execute(function (result)
				if not result then
					_onComplete(false)
				else
					if not event.single then
						if onComplete then onComplete(true) end
					else
						self:removeEvent(function ()
							if onComplete then onComplete(true) end
						end,trigger,key)
					end
				end
			end,"TRIGGER",unpack(args))
		end
		_onComplete(false)
	end)
end

-- 通知消息
function BattleScene:notify(onComplete, order, ...)
	local args = { ... }
	AsynchNotifier.notify(self, function ()
		self:triggerEvents(onComplete,unpack(args))
	end, order, ...)
end

-- 场景开始
function BattleScene:onBegin()
	self:beginBattle()
end

-- 开始战斗
function BattleScene:beginBattle()

	--self._ourteam:setState("NOATK","S_MJ",true)
	--self._ourteam:setState("NOSTY","S_MC",true)

	--self._ourteam:getRole(2):setState("BETRAY","S_PL",true)
	--self._ourteam:getRole(2):setState("LOSTCTRL","S_PL",true)

	--self._enemyteam:getRole(2):setState("STYBACK","S_CF",true)
	--self._enemyteam:getRole(3):setState("STYBACK","S_CF",true)

	--self._ourteam:getRole(2):getEntity():lostSoldiers()

	self:notify(function ()
		-- 选择动作
		self:selectAction()
	end, true, "BATTLEBEGIN")
end

-- 结束战斗
function BattleScene:endBattle(onComplete, ...)
	self._battleend = true
	self:notify(onComplete, true, "BATTLEEND", ...)
end

-- 检查战斗是否结束
function BattleScene:isBattleEnd()
	return self._battleend
end

-- 选择动作
function BattleScene:selectAction()
	self._ourteam:clearRoundData()
	self._enemyteam:clearRoundData()

	uiMgr:openUI("battlefunction", self)
end

-- 取消动作选择
function BattleScene:onCancelAction()
	self:selectAction()
end

--[[
	发起攻击
	config
		onComplete		完成回调
		ourteam			我方队伍
		enemyteam		敌方队伍
]]
function BattleScene:openAttack(config)
	config = config or {}
	self._rdcount = self._rdcount + 1
	
	-- 排序攻击角色
	local roles_ = {}
	if config.ourteam ~= false then
		roles_ = table.merge_array(roles_,self._ourteam:getAliveRoles())
	end
	if config.enemyteam ~= false then
		roles_ = table.merge_array(roles_,self._enemyteam:getAliveRoles())
	end
	local orderroles = {}
	for i,role in ipairs(roles_) do
		orderroles[i] = {
			role = role,
			speed = tools:getSwingRand(role:getSpeed(),C_SPEED_SWING),
		}
	end
	table.sort(orderroles,function (a,b)
		return a.speed > b.speed
	end)

	

	-- 角色序列攻击
	self:notify(function ()
		table.asyn_walk_sequence(function ()
			self:notify(function ()
				if config.onComplete then config.onComplete(false) end
			end, true, "ROUNDEND", self._rdcount)
		end,orderroles,function (_onComplete,roleconf,index)
			local role = roleconf.role
			role:doRoundAction(function ()
				self:notify(function ()
					self:checkBattleResult(function (result,victeam)
						if result then
							self:notify(function ()
								if config.onComplete then config.onComplete(true,victeam) end
							end, true, "ROUNDEND", self._rdcount)
						else
							performWithDelay(self,function ()
								_onComplete(true)
							end,C_ATTACK_DELAY)
						end
					end)
				end, true, "ACTIONEND", role, self._rdcount)
			end)
		end)
	end, true, "ROUNDBEGIN", self._rdcount)
end

-- 检查战斗结果
function BattleScene:checkBattleResult(onComplete)
	if onComplete then
		if self._ourteam:isDefeated() then
			onComplete(true,self._enemyteam)
		elseif self._enemyteam:isDefeated() then
			onComplete(true,self._ourteam)
		else
			onComplete(false)
		end
	end
end

-- 发起总攻
function BattleScene:openGeneralAttack(onComplete_)
	local doAttacks = nil
	local cancelAttacks = nil
	local stopAttacks = false

	doAttacks = function ()
		local _doAttacks = nil
		
		_doAttacks = function(result,victeam)
			if result then
				self._controller = nil
				ctrlMgr:popTarget()
				self._gattack = false
				self:hideBattleHead(false)
				self:hideBattleHead(true)
				if onComplete_ then onComplete_(true,victeam) end
			else
				if stopAttacks then
					self._controller = nil
					ctrlMgr:popTarget()
					cancelAttacks()
				else
					self:openAttack({
						onComplete = _doAttacks
					})
				end
			end
		end

		table.asyn_walk_together(function ()
			self._gattack = true
			self:showBattleHead(self._ourteam:getRole(1))
			self:showBattleHead(self._enemyteam:getRole(1))
			self._controller = function (keycode)
				if keycode == ctrlMgr.KEY_B then
					self._controller = nil
					stopAttacks = true
				end
			end
			ctrlMgr:pushTarget(self)
			_doAttacks()	
		end, { self._ourteam, self._enemyteam }, function (_onComplete,team,index)
			team:doGeneralAttack(true,function ()
				_onComplete(true)
			end)
		end)
	end

	cancelAttacks = function ()
		table.asyn_walk_together(function ()
			self._gattack = false
			self:hideBattleHead(false)
			self:hideBattleHead(true)
			if onComplete_ then onComplete_(false) end
		end, { self._ourteam, self._enemyteam }, function (_onComplete,team,index)
			team:doGeneralAttack(false,function ()
				_onComplete(true)
			end)
		end)
	end

	doAttacks()
end

-- 当前正在总攻
function BattleScene:isGeneralAttack()
	return self._gattack
end

-- 发起撤退追杀
function BattleScene:openRetreatHunt(team,onComplete)
	local doRetreatHunt = nil
	local onAttackEnd = nil

	onAttackEnd =  function(result,victeam)
		self._gattack = false
		self:hideBattleHead(team:isEnemy())
		if result then
			if onComplete then onComplete(true,victeam) end
		else
			team:doGeneralAttack(false,function ()
				if onComplete then onComplete(false) end
			end)
		end
	end

	doRetreatHunt = function ()
		self._gattack = true
		self:showBattleHead(team:getRole(1))
		team:doGeneralAttack(true,function ()
			self:openAttack({
				ourteam = not team:isEnemy(),
				enemyteam = team:isEnemy(),
				onComplete = onAttackEnd
			})
		end)
	end

	doRetreatHunt()
end

-- 撤退成功
function BattleScene:retreatSuccess()
	self:endBattle(function ()
		self._ourteam:doRetreats(function ()
			self:exitBattle("T")
		end)
	end)
end

-- 当战斗有结果
function BattleScene:onBattleResult(victeam)
	local victory = (victeam == self._ourteam)

	local function balanceBattle()
		table.asyn_walk_together(function ()
			self:notify(function ()
				self:exitBattle(victory and "V" or "F")
			end, true, "BATTLEBALANCE", victory, victeam)
		end,{
			function (_onComplete)
				audioMgr:listenFinish(audioMgr:playBGM(
					victory and gameMgr:getVictoryBGM() or gameMgr:getFailureBGM(),false),function ()
						victeam:doVictorys(false,_onComplete)
					end)
			end,
			function (_onComplete)
				victeam:doVictorys(true,function ()
					if victory then
						local lvupmsgs = {}
						self.our.team:addGolds(self.balance.golds)
						self.our.team:addExps(self.balance.exps,lvupmsgs)
		
						local function battleLevelUp()
							uiMgr:openUI("battlelevelup",{
								autoclose = true,
								lvupmsgs = lvupmsgs,
								onComplete = _onComplete
							})
						end
		
						uiMgr:openUI("battlevictory",{
							ourteam = self.our.team,
							enemyteam = self.enemy.team,
							golds = self.balance.golds,
							exps = self.balance.exps,
							continue = (#lvupmsgs > 0),
							onComplete = function ()
								if #lvupmsgs > 0 then
									battleLevelUp()
								else
									_onComplete()
								end
							end
						})
					else
						uiMgr:openUI(victeam:isEnemy() and "message" or "ourmessage",{
							texts = gameMgr:getStrings("BATTLE_FAILURE",{
								our = self.our.team:getName(),
								enemy = self.enemy.team:getName(),
							}),
							showconfig = {
								ctrl_complete = false,
							},
							onComplete = _onComplete
						})
					end
				end)
			end
		}, function (onComplete,fn,index)
			fn(onComplete)
		end)
	end

	self:endBattle(balanceBattle, victeam)
end

-- 退出战斗
function BattleScene:exitBattle(method)
	self._controller = function ()
		self._controller = nil

		self:notify(function ()
			self:releaseTeams(function ()
				if method == "F" then
					gameMgr:majorFailure()
				else	-- V T
					sceneMgr:setTransition(C_TRANSITION)
					sceneMgr:switchScene("MapScene",gameMgr:getMapEnv("battlemap"))
				end
			end)
		end, true, "BATTLEEXIT")
	end
	ctrlMgr:setTarget(self)
end

-- 尝试使用物品
function BattleScene:tryUseItem(onComplete,role,item,...)
	-- 物品使用事件
	self:triggerEvents(onComplete,"USEITEM",role,item,...)
end

--[[
	显示战场角色头像
	role		战场角色
]]
function BattleScene:showBattleHead(role)
	local isenemy = (role:getTeam() ~= self._ourteam)
	local sp_widget = isenemy and self.sp_enemyhead or self.sp_ourhead
	local headindex = role:getEntity():getHead()
	if headindex then
		sp_widget:setFlippedX(isenemy)
		sp_widget:setTexture(indexMgr:getIndex(C_HEAD_IPATH .. "/" .. headindex))
		sp_widget:setVisible(true)
	else
		sp_widget:setVisible(false)
	end
end

--[[
	隐藏战场头像
	isenemy			敌方头像
]]
function BattleScene:hideBattleHead(isenemy)
	local sp_widget = isenemy and self.sp_enemyhead or self.sp_ourhead
	sp_widget:setVisible(false)
end

-- 获得战场环境
function BattleScene:getEnvironment()
	return self._environment
end

-- 设置战场环境
function BattleScene:setEnvironment(env)
	self._environment = env
	local battleenv = metaMgr:createObject(C_BATENV_MODULE, env)
	if battleenv then
		local plsize = self.pl_environment:getContentSize()
		battleenv:setPosition(cc.p(plsize.width/2,plsize.height/2))
		self.pl_environment:addChild(battleenv)
	end
end

-- 获得战场的BGM
function BattleScene:getBGM()
	return self.bgm
end

-- 获得我方队伍
function BattleScene:getOurTeam()
	return self._ourteam
end

-- 获得敌方队伍
function BattleScene:getEnemyTeam()
	return self._enemyteam
end

-- 获得队伍
function BattleScene:getTeam(isenemy)
	return isenemy and self._enemyteam or self._ourteam
end

-- 当输入键值
function BattleScene:onControlKey(keycode)
	if self._controller then
		self._controller(keycode)
	end
end

return BattleScene
