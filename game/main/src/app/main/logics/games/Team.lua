--[[
	队伍
--]]
local THIS_MODULE = ...

local AsynchNotifier = require("app.main.modules.common.AsynchNotifier")

local Team = class("Team", require("app.main.logics.games.Serializable"),
	AsynchNotifier)

-- 创建常量
local TEAMATTR = nil	-- 队伍属性表
local function createConstants()
	if not TEAMATTR then
		TEAMATTR = {
			["movespeed"] = Team.setMoveSpeedAdd
		}
	end
end

-- 构造函数
function Team:ctor(type,config)
	createConstants()
	if type == "SERIALIZE" then
		self:loadSerialize(config)
	elseif type ~= "EMPTY" then
		self:initNew()
	end
	self:initNotifier()
end

-- 保存序列
function Team:saveSerialize(serialize)
	serialize = serialize or {}

	serialize._name = self._name
	serialize._level = self._level
	serialize._exps = self._exps
	serialize._asp = self._asp
	serialize._usp = self._usp
	serialize._msp = self._msp
	serialize._formation = self._formation
	serialize._buffs = self._buffs
	serialize._golds = self._golds
	serialize._soldiersmax = self._soldiersmax
	serialize._movespeed = self._movespeed
	serialize._moveterrain = self._moveterrain
	serialize._adviserid = self._adviserid
	serialize._roles = seriaMgr:save(self._roles)
	serialize._rsvroles = seriaMgr:save(self._rsvroles)
	serialize._rsvitems = seriaMgr:save(self._rsvitems)
	serialize._deposititems = seriaMgr:save(self._deposititems)
	
	return serialize
end

-- 加载序列
function Team:loadSerialize(serialize)
	self._name = serialize._name
	self._level = serialize._level or 1
	self._exps = serialize._exps or 0
	self._asp = serialize._asp or 0
	self._usp = serialize._usp or 0
	self._msp = serialize._msp or gameMgr:getInitSp()
	self._formation = serialize._formation
	self._buffs = serialize._buffs or {}
	self._golds = serialize._golds or 0
	self._soldiersmax = serialize._soldiersmax or 0
	self._movespeed = serialize._movespeed or 1
	self._moveterrain = serialize._moveterrain or gameMgr:getInitTerrain()
	self._adviserid = serialize._adviserid or "0"
	self._roles = seriaMgr:load(serialize._roles) or {}
	self._rsvroles = seriaMgr:load(serialize._rsvroles) or {}
	self._rsvitems = seriaMgr:load(serialize._rsvitems) or {}
	self._deposititems = seriaMgr:load(serialize._deposititems) or {}

	for _,role in ipairs(self._roles) do
		role:setTeam(self, true)
	end
	self:unpdateAdviser()
end

-- 初始化新队伍
function Team:initNew()
	self._name = nil				-- 队伍名称
	self._level = 1					-- 等级
	self._exps = 0					-- 经验
	self._asp = 0					-- 可用谋略点
	self._usp = 0					-- 消耗谋略点
	self._msp = gameMgr:getInitSp()	-- 最大谋略点
	self._formation = nil			-- 阵形配置（当前阵形的配置表）
	self._buffs = {}				-- BUFF表
	self._golds = 0					-- 金数量
	self._soldiersmax = 0			-- 队伍最大兵力
	self._movespeed = 1				-- 移动速度
	self._moveterrain = gameMgr:getInitTerrain()	-- 移动地形
	self._adviserid = "0"			-- 军师ID
	self._roles = {}				-- 角色表
	self._rsvroles = {}				-- 后备角色
	self._rsvitems = {}				-- 后备物品
	self._deposititems = {}			-- 寄存物品
	
	self._adviser = nil				-- 军师
	self._skills = nil				-- 技能表
	self._formations = nil			-- 阵型表
	self._strategys = nil			-- 谋略表
end

-- 更新队伍属性
function Team:updateAttribute(attrname)
	local function _updateAttribute(_attrname)
		local funcall = TEAMATTR[_attrname]
		if funcall then
			local value = 0
			for _,role in ipairs(self._roles) do
				if not role:isDead() then
					value = value + role:getTeamAttribute(_attrname)
				end
			end
			funcall(self,value)
		end
	end
	if attrname then
		_updateAttribute(attrname)
	else
		for _,attrname in ipairs(table.keys(TEAMATTR)) do
			_updateAttribute(attrname)
		end
	end
end

-- 队伍名字
function Team:getName()
	if self._name then return self._name end
	if #self._roles > 0 then 
		return gameMgr:getStrings("TEAM_NAME",{ role = self._roles[1]:getName() })[1] 
	end
	return gameMgr:getDefaultTeamName()
end
function Team:setName(name)
	self._name = name
end

-- 获得队伍等级
function Team:getLevel()
	return self._level
end

-- 通知监听器
function Team:notify(onComplete, order, ...)
	local args = { ... }
	AsynchNotifier.notify(self, function ()
		if args[1] == "ROLELEAVE" or args[1] == "ROLEDEAD" then
			if self._adviser == args[2] then
				self:setAdviserID("0")
			end
		end
		if onComplete then onComplete() end
	end, order, ...)
end

-- 获得下一个等级所需经验
function Team:getNextLevelExps()
	local lvupexps = gameMgr:getLevelExps(self._level + 1)
	if lvupexps then
		return lvupexps - self._exps
	end
end

-- 提升队伍等级
function Team:upgradeLevel(msgs)
	local lvupexps = gameMgr:getLevelExps(self._level + 1)
	if not lvupexps then return end

	self._level = self._level + 1
	self._exps = lvupexps
	
	local rolemsgs = { }
	for i,role in ipairs(self._roles) do
		role:onTeamLevelUp(self._level,msgs and rolemsgs or nil)
	end
	self:updateSoldiersMax()

	self._msp = self._msp + gameMgr:getLeveUpSp()
	if self._msp > gameMgr:getSpMax() then
		self._msp = gameMgr:getSpMax()
	end
	self:unpdateAdviser()

	if msgs then
		table.insert(msgs, {
			team = self:getName(),
			roles = rolemsgs,
			msp = self:getMSP()
		})
	end
end

-- 经验
function Team:getExps()
	return self._exps
end
function Team:addExps(aexps,msgs)
	while true do
		local lvupexps = gameMgr:getLevelExps(self._level + 1)
		if not lvupexps then return end

		if self._exps + aexps < lvupexps then
			self._exps = self._exps + aexps
			return
		end
		aexps = aexps - (lvupexps - self._exps)
		self:upgradeLevel(msgs)
	end
end

-- 谋略点
function Team:getSP()
	return math.max(0, self._asp - self._usp)
end
function Team:getMSP()
	return self._msp
end
function Team:recoverSP(maxsp)
	local recvsp = maxsp or self._usp
	self._usp = math.max(0, self._usp - recvsp) 
	return recvsp
end
function Team:tryConsumeSP(sp)
	if self._usp + sp <= self._asp then
		self._usp = self._usp + sp
		return true
	end
end
function Team:lostSP(sp,onComplete)
	self._usp = math.min(self._asp, self._usp + (sp or self._asp))
	if onComplete then onComplete() end
end

-- 阵形
function Team:getFormation()
	return self._formation
end
function Team:setFormation(formation,onComplete)
	self._formation = formation
	self:notify(onComplete, true, "FORMATION", formation)
end

--[[
function Team:updateFormation(onComplete)
	if self._formation then
		if table.nums(self._roles, function (v) return not v:isDead() end) < 
			formationMgr:getMinRoles(self._formation.fid) then
			return self:setFormation(nil, onComplete)
		end
	end
	if onComplete then onComplete() end
end
--]]

-- BUFF
function Team:getBuffs()
	return self._buffs
end
function Team:addBuff(bid,state,onComplete)
	self:removeBuff(bid,function ()
		self._buffs[bid] = state
		self:notify(onComplete,true,"ADDBUFF",bid,state)
	end)
end
function Team:removeBuff(bid,onComplete)
	if not self._buffs[bid] then
		if onComplete then onComplete() end
	else
		self._buffs[bid] = nil
		self:notify(onComplete,true,"REMOVEBUFF",bid)
	end
end
function Team:clearBuff(fn,onComplete)
	table.asyn_walk_sequence(onComplete,table.keys(self._buffs),function (onComplete_,bid)
		local state = self._buffs[bid]
		if not state then
			onComplete_(false)
		else
			if fn(bid,state) then
				self:removeBuff(bid,onComplete_)
			else
				onComplete_(false)
			end
		end
	end)
end

-- 金币
function Team:getGolds()
	return self._golds
end
function Team:addGolds(golds)
	self._golds = self._golds + golds
end
function Team:tryCostGolds(golds)
	if self._golds >= golds then
		self._golds = self._golds - golds
		return true
	end
end

-- 队伍最大兵力
function Team:getSoldiersMax()
	return self._soldiersmax
end
function Team:updateSoldiersMax()
	local soldiers = 0
	for _,role in ipairs(self._roles) do
		if not role:isGuest() then
			local rolesoldmax = role:getSoldierMax()
			if rolesoldmax > soldiers then
				soldiers = rolesoldmax
			end
		end
	end
	self._soldiersmax = soldiers
end

-- 队伍移动速度
function Team:getMoveSpeed()
	return self._movespeed
end
function Team:setMoveSpeedAdd(speedadd)	-- 设置移动速度加成
	self._movespeed = 1 + speedadd
	self:notify(false, true, "MOVESPEED", self._movespeed)
end

-- 移动地形
function Team:getMoveTerrain()
	return self._moveterrain
end
function Team:setMoveTerrain(moveterrain)
	self._moveterrain = moveterrain
end
function Team:addMoveTerrain(terrain)
	self._moveterrain = bit.bor(self._moveterrain,terrain)
end
function Team:removeMoveTerrain(terrain)
	self._moveterrain = bit.band(self._moveterrain,bit.bnot(terrain))
end

-- 更新当前军师
function Team:unpdateAdviser()
	local adviser = self:getRoleByID(self._adviserid)
	if not adviser or adviser:isDead() then
		self._adviser = nil
		self._skills = nil
		self._formations = nil
		self._strategys = nil
		self._asp = 0
	else
		self._adviser = adviser
		self._skills = adviser:getAvailableSkills(self._level)
		self._formations = adviser:getAvailableFormations(self._level)
		self._strategys = adviser:getAvailableStrategys(self._level)

		-- 更新军师谋略点
		self._asp = adviser:getAvailableSP()
	end
end

-- 恢复队伍兵力
function Team:recoverSoldiers()
	for _,role in ipairs(self._roles) do
		if not role:isDead() then
			role:recoverSoldiers()
		end
	end
end

-- 复活角色
function Team:reviveRoles(index)
	if index then
		if self._roles[index]:isDead() then
			self._roles[index]:reviveRole()
		end
	else
		for _,role in ipairs(self._roles) do
			if role:isDead() then
				role:reviveRole()
			end
		end
	end
end

-- 复活队伍
function Team:reviveTeam()
	if self:getAliveCount() <= 0 then
		self:reviveRoles(1)
	end
end

-- 获得军师
function Team:getAdviser()
	return self._adviser
end

-- 获得使用技能
function Team:getSkills()
	return self._skills
end

-- 获得使用队形
function Team:getFormations()
	return self._formations
end

-- 获得使用谋略
function Team:getStrategys()
	return self._strategys
end

-- 军师ID
function Team:setAdviserID(id)
	self._adviserid = id
	self:unpdateAdviser()
end
function Team:getAdviserID()
	return self._adviserid
end

-- 队伍的所有角色
function Team:setRoles(roles)
	self._roles = roles
end
function Team:getRoles()
	return self._roles
end

-- 获得角色数量
function Team:getRoleCount()
	return #self._roles
end

-- 获得队伍存活的角色
function Team:getAliveRoles()
	return table.filter_array(self._roles,function (v)
		return not v:isDead()
	end)
end

-- 获得角色存活数量
function Team:getAliveCount()
	return #self:getAliveRoles()
end

-- 获得指定位置的角色
function Team:getRole(index)
	return self._roles[index or 1]
end

-- 获得指定位置的存活角色
function Team:getAlive(index)
	return self:getAliveRoles()[index or 1]
end

-- 角色加入(携带装备和物品)
function Team:joinRole(role,index,onComplete)
	index = index or (#self._roles + 1)
	table.insert(self._roles,index,role)
	role:setTeam(self)
	self:updateAttribute()
	self:updateSoldiersMax()
	self:notify(onComplete, true, "ROLEJOIN", role, index)
end

-- 角色离开(携带装备和物品)
function Team:leaveRole(index,onComplete)
	local role = self._roles[index]
	if not role then	
		if onComplete then onComplete() end
	else
		table.remove(self._roles,index)
		role:setTeam(nil)
		self:updateAttribute()
		self:updateSoldiersMax()
		self:notify(onComplete, true, "ROLELEAVE", role, index)
	end
end

-- 当收到队员通知
function Team:onRoleNotify(onComplete,role,type,...)
	if type == "TEAM_ATTRIBUTE" then
		self:updateAttribute(...)
	elseif type == "DEAD" then
		self:updateAttribute()
		return self:notify(onComplete, true, "ROLEDEAD", role)
	elseif type == "REVIVE" then
		self:updateAttribute()
		return self:notify(onComplete, true, "ROLEREVIVE", role)
	end
	if onComplete then onComplete() end
end

-- 添加角色
function Team:addRole(role,index)
	local items = self:removeReserveItems()
	if items then
		for _,equipment in ipairs(items.equipments) do 
			local oldequip = role:addEquipment(equipment)
			if oldequip then
				role:addLuggage(oldequip)
			end
		end
		for _,luggage in ipairs(items.luggages) do
			role:addLuggage(luggage)
		end
	end
	self:joinRole(role,index)
end

-- 移除并返回角色
function Team:removeRole(index)
	local role = self._roles[index]
	if role then
		self:addReserveItems(
			role:removeEquipments(),
			role:removeLuggages()
		)
		self:leaveRole(index)
	end
	return role
end

-- 通过ID获得角色和位置
function Team:getRoleByID(id)
	for i,role in ipairs(self._roles) do
		if role:getID() == id then
			return role,i
		end
	end
end

-- 排序角色
function Team:sortRoles(ids,onComplete)
	local newroles = {}
	for i,id in ipairs(ids) do 
		newroles[i] = self:getRoleByID(id)
	end
	self._roles = newroles
	self:notify(onComplete, true, "ROLESORT", newroles)
end

-- 后备角色
function Team:setReserveRoles(rsvroles)
	self._rsvroles = rsvroles
end
function Team:getReserveRoles()
	return self._rsvroles
end

-- 添加后备角色
function Team:addReserveRole(role)
	self._rsvroles[#self._rsvroles + 1] = role
end

-- 移除后备角色
function Team:removeReserveRole(index)
	local role = self._rsvroles[index]
	if role then
		table.remove(self._rsvroles,index)
		return role
	end
end

-- 通过ID获得后备角色和位置
function Team:getReserveRoleByID(id)
	for i,role in ipairs(self._rsvroles) do
		if role:getID() == id then
			return role,i
		end
	end
end

-- 后备物品
function Team:setReserveItems(rsvitems)
	self._rsvitems = rsvitems
end
function Team:getReserveItems()
	return self._rsvitems
end

-- 添加后备物品
function Team:addReserveItems(equipments,luggages)
	self._rsvitems[#self._rsvitems + 1] = {
		equipments = equipments,
		luggages = luggages
	}
end

-- 移除并返回后备物品
function Team:removeReserveItems(index)
	index = index or 1
	local items = self._rsvitems[index]
	if items then
		table.remove(self._rsvitems,index)
		return items
	end
end

-- 寄存物品
function Team:setDepositItems(items)
	self._deposititems = items
end
function Team:getDepositItems()
	return self._deposititems
end
function Team:getDepositCount()
	return #self._deposititems
end

-- 添加寄存物品
function Team:addDepositItem(item)
	self._deposititems[#self._deposititems + 1] = item:upgradeType()
end

-- 移除并返回寄存物品
function Team:removeDepositItem(index)
	local item = self._deposititems[index]
	if item then
		table.remove(self._deposititems,index)
		return item
	end
end

-- 通过ID获得寄存物品和位置
function Team:getDepositItemByID(id)
	for i,item in ipairs(self._deposititems) do
		if item:getID() == id then
			return item,i
		end
	end
end

-- 向队伍中添加物品
function Team:addItem(item)
	-- 堆叠到物品
	for _,role in ipairs(self._roles) do 
		if role:addLuggage(item,"STACK") then return true end
	end
	
	-- 放置物品
	for _,role in ipairs(self._roles) do 
		if role:addLuggage(item,"PLACE") then return true end
	end
	return false
end

return Team
