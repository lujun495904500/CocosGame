--[[
	战场队伍
--]]
local THIS_MODULE = ...

-- 撤退延时
local C_RETREAT_DELAY = 0.1

-- 显示延时
local C_SHOW_DELAY = 0.8

-- 状态常量
local C_STATES = {
	-- 免击
	NOATK = {
		S_MJ  = false,		-- 免击计
	},

	-- 免策
	NOSTY = {
		S_MC  = false,		-- 免策计
	},

	-- 隐蔽
	CRYPSIS = {
		S_YD  = false,		-- 烟遁计
	}
}

local BattleRole = require("app.main.logics.games.battle.BattleRole")

local BattleTeam = class("BattleTeam", cc.Layer, 
	require("app.main.modules.common.ClassLayout"), 
	require("app.main.modules.common.StatesList"), 
	require("app.main.modules.control.ControlBase"),
	require("app.main.logics.games.BuffsList"))

--[[
	构造函数

	onComplete		初始化完成回调
	team			队伍实体

	config
		scene		场景
		ai			队伍AI
		isenemy		敌方队伍
		citydef		城防值
]]
function BattleTeam:ctor(onComplete,team,config)
	self:setupLayout()
	self:initStates(C_STATES)
	self:initBuffs("B")

	self._onInitialized = onComplete
	self._team = team
	if config then
		table.merge(self,config)
	end
	self:setupTeam()
end

-- 初始化队伍
function BattleTeam:setupTeam()
	self._retreat = false	-- 战斗撤退
	self._roles = {}		-- 角色
	self._orderroles = {}	-- 排序角色
	self._formation = nil	-- 阵形
	self._styresist = 0		-- 策略抵抗
	self._statistics = {}	-- 统计数据

	-- 异步加载
	table.asyn_walk_sequence(function ()
		self._teamliser = handler(self,BattleTeam.teamListener)
		self._team:addListener(self._teamliser)
		self._sceneliser = handler(self,BattleTeam.sceneListener)
		self.scene:addListener(self._sceneliser, self.isenemy and 30 or 10)

		if self._onInitialized then 
			self._onInitialized(self)
		end
	end, {
		-- 安装战场角色
		function (onComplete_)
			self:setupRoles(onComplete_)
		end

		-- 安装阵形
		,function (onComplete_)
			local formation = self._team:getFormation()
			if formation then
				if #self:getAliveRoles() < formationMgr:getMinRoles(formation.fid) then
					formation = nil
				end
			end
			if not formation then   
				if onComplete_ then onComplete_(false) end
			else
				self:setupFormation(onComplete_, formation, { immediately = true })
			end
		end

		-- 安装Buffs
		,function (onComplete_)
			self:setupBuffs(onComplete_,self._team:getBuffs())
		end
	}, function (onComplete_, fn)
		fn(onComplete_)
	end)
end

-- 检查是否有效
function BattleTeam:isValid()
	return not self._invalid
end

-- 释放队伍
function BattleTeam:release(remove,onComplete)
	if self._invalid then
		if onComplete then onComplete(true) end
	else
		self._invalid = true
		table.asyn_walk_sequence(function ()
			self.scene:removeListener(self._sceneliser)
			self._team:removeListener(self._teamliser)
			self._team:clearBuff(function (bid,state)
				return not buffMgr:isMapUsable(bid)
			end,function ()
				if remove then
					self:removeFromParent(true)
				end
				if onComplete then onComplete(true) end
			end)
		end,self._orderroles,function (onComplete_,role)
			role:release(remove,onComplete_)
		end)
	end
end

-- 队伍监听器
function BattleTeam:teamListener(onComplete, team, type, ...)
	if type == "FORMATION" then
		if not self._retreat then
			local formation = ...
			return self:setupFormation(onComplete, formation, { 
				immediately = self.scene:isGeneralAttack(),
			})
		end
	elseif type == "ROLEDEAD" then
		if self._formation then
			if #self:getAliveRoles() < formationMgr:getMinRoles(self._formation.fid) then
				return self._team:setFormation(nil, onComplete)
			end
		end
	elseif type == "ADDBUFF" then
		local bid,state = ...
		return self:setupBuff(onComplete,bid,state)
	elseif type == "REMOVEBUFF" then
		local bid = ...
		return self:deleteBuff(onComplete,bid)
	end
	if onComplete then onComplete() end
end

-- 场景监听器
function BattleTeam:sceneListener(onComplete,scene,type,...)
	if type =="ACTIONEND" then
		return self:showUnsetFormation(onComplete)
	elseif type =="ROUNDEND" then
		return self:triggerBuffs(onComplete,"ROUND")
	elseif type =="BATTLEEND" then
		if self._formation and not formationMgr:isMapUsable(self._formation.fid) then
			return self._team:setFormation(nil,onComplete)
		end
	end
	if onComplete then onComplete() end
end

-- 队伍统计接口
function BattleTeam:getStatistics()
	return self._statistics
end
function BattleTeam:updateStatistics(stype)
	local rank = self._statistics[stype]
	if not rank then
		rank = table.values(self._roles)
		self._statistics[stype] = rank
	end
	table.sort(rank, function (a,b)
		return (a:getStatistics()[stype] or 0) > (b:getStatistics()[stype] or 0)
	end)
end

-- 显示阵形解散消息
function BattleTeam:showUnsetFormation(onComplete,hide)
	if self._unsetfid then
		local fid = self._unsetfid
		self._unsetfid = nil
		if not self.scene:isGeneralAttack() and not hide then
			local msgui = self:isEnemy() and "message" or "ourmessage"
			local msgwin = uiMgr:openUI(msgui)
			return msgwin:showMessage({
				texts = gameMgr:getStrings("UNSET_FORMATION",{
					team = self._team:getName()
				}),
				showconfig = {
					usecursor		= false, 
					usesound		= false,
					quickshow		= true,
					linefeed		= true,
					ctrl_quick		= false,
					ctrl_complete	= false,
				},
				onComplete = function ()
					performWithDelay(msgwin,function ()
						uiMgr:closeUI(msgui)
						if onComplete then onComplete() end
					end,C_SHOW_DELAY)
				end
			})
		end
	end
	if onComplete then onComplete() end
end

-- 安装战场角色
function BattleTeam:setupRoles(onComplete)
	local adviser = self._team:getAdviser()

	-- 战场角色排序
	local roles_ = {}
	for _,role in ipairs(self._team:getRoles()) do
		if role:isValid() and not role:isDead() and role ~= adviser then
			roles_[#roles_ + 1] = role
			if #roles_ >= self.rolecount then break end
		end
	end
	if #roles_ < self.rolecount and adviser and adviser:isValid() and not adviser:isDead() then
		roles_[#roles_ + 1] = adviser
	end

	table.asyn_walk_sequence(onComplete,roles_,function (_onComplete,role)
		self:addRole(_onComplete,role)
	end)
end

--[[
	安装阵形
	onComplete		完成回调
	formation		阵形配置
		fid			阵形ID

	config
		immediately	立即完成
]]
function BattleTeam:setupFormation(onComplete,formation,config)
	config = config or {}

	if self._formation and not formation then
		self._unsetfid = self._formation.fid
	end

	-- 安装阵形
	local setupFormation = function ()
		table.asyn_walk_together(function ()
			if formation then
				local state = formationMgr:getScript(formation.fid,"state")
				local fscript = state and scriptMgr:createObject(state,table.merge({
						param = formationMgr:getParam(formation.fid,"state"),
						team = self,
					},formation)) or nil
				self._formation = {
					fid = formation.fid,
					script = fscript,
				}
				if fscript then
					return fscript:execute(onComplete,"SETUP",{
						immediately = config.immediately
					})
				end
			end

			if onComplete then onComplete() end
		end,self._orderroles,function (onComplete_,role)
			role:setRoleOffest(onComplete_,
				formation and formationMgr:getOffest(formation.fid,role:getPlace()) or 0,
				{ immediately = config.immediately, })
		end)
	end

	-- 删除当前阵形
	if self._formation then
		if not self._formation.script then
			self._formation = nil
		else
			return self._formation.script:execute(function ()
				self._formation = nil
				setupFormation()
			end,"DELETE",{ immediately = config.immediately })
		end
	end
	setupFormation()
end

-- 设置阵形加成
function BattleTeam:setFormationAddition(addition)
	if self._formation then
		self._formation.addition = addition
	end
end

-- 获得队伍属性加成
function BattleTeam:getAddition(type,location)
	if self._formation then
		local fadd = formationMgr:getAddition(self._formation.fid,type)
		local padd = formationMgr:getPositionAddition(self._formation.fid,type,location)
		return padd * (1 + fadd)
	end
	return 0
end

-- 获得队伍所属场景
function BattleTeam:getScene()
	return self.scene	
end

-- 获得队伍实体
function BattleTeam:getEntity()
	return self._team
end

-- 获得敌对队伍
function BattleTeam:getEnemyTeam()
	return self.scene:getTeam(not self.isenemy)
end

-- 获得城市防御值
function BattleTeam:getCityDefense()
	return self.citydef or 0
end

-- 是否是敌方队伍
function BattleTeam:isEnemy()
	return self.isenemy
end

-- 增加策略抵抗
function BattleTeam:addStrategyResistance(styres,onComplete)
	self._styresist = math.min(self._styresist + styres, gameMgr:getStrategyResistanceMax())
	if onComplete then onComplete() end
end

-- 队伍策略抵抗
function BattleTeam:getStrategyResistance()
	return self._styresist
end

-- 获得战场角色数量
function BattleTeam:getRoleCount()
	return #self._orderroles
end

-- 获得战场角色
function BattleTeam:getRoles()
	return self._orderroles
end

-- 获得指定位置角色
function BattleTeam:getRole(place)
	return self._roles[place]
end

-- 通过位置获得角色索引
function BattleTeam:getRoleIndexByPlace(place)
	for i,role in ipairs(self._orderroles) do
		if role:getPlace() == place then
			return i,role
		end
	end
end

-- 构建排序角色
function BattleTeam:buildOrderRoles()
	self._orderroles = table.values(self._roles)
	table.sort(self._orderroles, function (a,b)
		return a:getPlace() < b:getPlace()
	end)
end

-- 添加角色
function BattleTeam:addRole(onComplete,role,place)
	place = place or (#self._roles + 1)
	self:removeRole(function ()
		BattleRole:create(function (batrole)
			self[string.format("pl_role%d",place)]:addChild(batrole)
			self._roles[place] = batrole
			self:buildOrderRoles()
			if onComplete then onComplete(batrole) end
		end,role, {
			team = self, 
			scene = self.scene,
			place = place, 
			citydef = self.citydef,
			isenemy = self.isenemy 
		})
	end, place)
end

-- 移除角色
function BattleTeam:removeRole(onComplete,place)
	local role_ = self._roles[place]
	if not role_ then
		if onComplete then onComplete(true) end
	else
		role_:release(true,function (result)
			if result then
				self._roles[place] = nil
				self:buildOrderRoles()
			end
			if onComplete then onComplete(result) end
		end)
	end
end

-- 检查 免击
function BattleTeam:isNoAttack()
	return self:checkStates("NOATK")
end

-- 检查 免策
function BattleTeam:isNoStrategy()
	return self:checkStates("NOSTY")
end

-- 检查 隐蔽
function BattleTeam:isCrypsis()
	return self:checkStates("CRYPSIS")
end

-- 获得可控制的角色
function BattleTeam:getControlableRoles()
	return table.filter_array(self._orderroles,function (v)
			return not v:isDead() and not v:isLostControl()
		end)
end

-- 获得存活的角色
function BattleTeam:getAliveRoles()
	return table.filter_array(self._orderroles,function (v)
			return not v:isDead()
		end)
end

-- 查找存活的角色
function BattleTeam:getAliveRole(place)
	local index = self:getRoleIndexByPlace(place)
	for i = index + 1, #self._orderroles do
		local role = self._orderroles[i]
		if not role:isDead() then return role end
	end
	for i = 1, index - 1 do
		local role = self._orderroles[i]
		if not role:isDead() then return role end
	end
end

--[[
	选择角色
	onComplete	  完成回调
	config
		role_dead   选择死亡角色
		role_normal 选择正常角色(默认)
		multisel	多选
]]
function BattleTeam:selectRoles(onComplete,config)
	config = config or {}
	local selindex = 1
	local selectall = false
	
	-- 筛选候选角色
	local selectroles = {}
	for _,role in ipairs(self._orderroles) do
		if role:isDead() then
			if config.role_dead then
				table.insert(selectroles,role)
			end
		else	-- normal
			if config.role_normal ~= false then
				table.insert(selectroles,role)
			end
		end
	end
	if #selectroles <= 0 then
		return onComplete(false)
	end

	local function clearSelect()
		for _,role in ipairs(selectroles) do
			role:onSelect(false)
		end
	end

	local function updateSelect()
		clearSelect()
		if selectall then
			for _,role in ipairs(selectroles) do
				role:onSelect(true,true)
			end
		else
			selectroles[selindex]:onSelect(true)
		end
	end

	self._controller = function (keycode)
		if config.multisel and (keycode == ctrlMgr.KEY_LEFT or keycode == ctrlMgr.KEY_RIGHT) then
			selectall = not selectall
			updateSelect()
		elseif keycode == ctrlMgr.KEY_UP then
			if selindex == 1 then
				selindex = #selectroles
			else
				selindex = selindex - 1
			end
			selectall = false
			updateSelect()
		elseif keycode == ctrlMgr.KEY_DOWN then
			if selindex == #selectroles then
				selindex = 1
			else
				selindex = selindex + 1
			end
			selectall = false
			updateSelect()
		elseif keycode == ctrlMgr.KEY_A then
			self._controller = nil
			ctrlMgr:popTarget()
			clearSelect()
			local selects = {}
			if selectall then
				table.merge(selects,selectroles)
			else
				table.insert(selects, selectroles[selindex])
			end
			onComplete(true,selects)
		elseif keycode == ctrlMgr.KEY_B then
			self._controller = nil
			ctrlMgr:popTarget()
			clearSelect()
			onComplete(false)
		end
	end

	updateSelect()
	ctrlMgr:pushTarget(self)
end

-- 清空回合数据
function BattleTeam:clearRoundData()
	self._statistics.rounds = {}	-- 清空回合统计
	for _,role in ipairs(self._orderroles) do
		role:clearRoundData()
	end
end

-- 检查 队伍是否被击败
function BattleTeam:isDefeated()
	for _,role in ipairs(self._orderroles) do
		if not role:isDead() and not role:isFeigndead() then
			return false
		end
	end
	return true
end

-- 获得角色攻击AI
function BattleTeam:getAttackAI(role)
	return scriptMgr:createObject(self.ai or gameMgr:getDefaultAttackAI(),
		{
			team = self,
			role = role,
		})
end

-- 获得角色叛变AI
function BattleTeam:getBetrayAI(role)
	return scriptMgr:createObject(self.betrayai or gameMgr:getDefaultBetrayAI(),
		{
			team = self,
			role = role,
		})
end

-- 队伍总攻
function BattleTeam:doGeneralAttack(gattack,onComplete)
	table.asyn_walk_together(onComplete,self._orderroles,function (_onComplete,role)
		role:doGeneralAttack(gattack,function ()
			_onComplete(true)
		end)
	end)
end

-- 队伍撤退
function BattleTeam:doRetreats(onComplete)
	self._retreat = true
	table.asyn_walk_sequence(onComplete,self._orderroles,function (_onComplete,role)
		role:doRetreat(function ()
			performWithDelay(self,function ()
				_onComplete(true)
			end,C_RETREAT_DELAY)
		end)
	end)
end

-- 队伍胜利
function BattleTeam:doVictorys(walking,onComplete)
	table.asyn_walk_together(onComplete,self._orderroles,function (_onComplete,role)
		role:doVictory(walking,function ()
			_onComplete(true)
		end)
	end)
end

-- 操作键输入接口
function BattleTeam:onControlKey(keycode)
	if self._controller then
		self._controller(keycode)
	end
end

--------------[[ 统计


--------------]]

return BattleTeam
