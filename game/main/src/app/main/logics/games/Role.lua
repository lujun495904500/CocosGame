--[[
	角色
--]]
local THIS_MODULE = ...
local C_LOGTAG = "Role"

local C_EQUIPTYPES = {"W","A","H","S"}

local AsynchNotifier = require("app.main.modules.common.AsynchNotifier")

local Role = class("Role", require("app.main.logics.games.Serializable"),
	AsynchNotifier)

-- 创建常量
local ROLEATTR = nil	-- 角色属性
local function createConstants()
	if not ROLEATTR then
		ROLEATTR = {
			["force"] 		= { min = 0, max = gameMgr:getAttributeMax() },	-- 武力
			["intellect"] 	= { min = 0, max = gameMgr:getAttributeMax() },	-- 智力
			["speed"] 		= { min = 0, max = gameMgr:getAttributeMax() },	-- 速度
			["attack"] 		= { min = 0, max = gameMgr:getAttributeMax() },	-- 攻击
			["defense"] 	= { min = 0, max = gameMgr:getAttributeMax() },	-- 防御
			["dodge"] 		= { min = 0 },									-- 闪避
			["stydodge"] 	= { min = 0 },									-- 策略闪避
			["styresist"] 	= { min = 0 },									-- 策略抵抗
			["atktimes"] 	= { min = 1 },									-- 攻击次数
		}
	end
end

-- 构造函数
function Role:ctor(type,config,...)
	createConstants()
	if type == "SERIALIZE" then
		self:loadSerialize(config)
	else  -- NEW
		self:initWithDataID(config,...)
	end
	self:initNotifier()
	self._tempdata = {} -- 临时数据
end

-- 保存序列
function Role:saveSerialize(serialize)
	serialize = serialize or {}

	serialize._id = self._id
	serialize._dataid = self._dataid
	serialize._guest = self._guest
	serialize._luggages = seriaMgr:save(self._luggages)
	serialize._equipments = seriaMgr:save(self._equipments)
	serialize._buffs = self._buffs
	serialize._soldiers = self._soldiers
	serialize._soldiermax = self._soldiermax
	serialize._baseattr = self._baseattr

	return serialize
end

-- 加载序列
function Role:loadSerialize(serialize)
	self._id = serialize._id
	self._dataid = serialize._dataid
	self._guest = serialize._guest
	self._luggages = seriaMgr:load(serialize._luggages) or {}
	self._equipments = seriaMgr:load(serialize._equipments) or {}
	self._buffs = serialize._buffs or {}
	self._soldiers = serialize._soldiers or -1
	self._soldiermax = serialize._soldiermax or 0
	self._baseattr = serialize._baseattr or { 
		atktimes = ROLEATTR.atktimes.min 
	}
	
	self._roledb = dbMgr.roles[self._dataid]
	if self._roledb then
		self:loadRoleData()
		for _,equipment in pairs(self._equipments) do
			scriptMgr:createObject(equipment:getEquipScript(),{
				role = self,
				equipment = equipment,
			}):execute("EQUIP_ITEM", true)
		end
		for _,luggage in ipairs(self._luggages) do 
			if iskindof(luggage,"Accessory") and luggage:isEquiped() then
				scriptMgr:createObject(luggage:getEquipScript(),{
					role = self,
					accessory = luggage,
				}):execute("EQUIP_ITEM", true)
			end
		end
		self:updateAttribute()
	else
		logMgr:warn(C_LOGTAG, "role [%d] is't found !!!",self._dataid)
	end

	self:setValid(self:checkValid())
end

-- 通过新创建初始化
function Role:initWithDataID(dataid,guest)
	self._id = gameMgr:newRoleID()		-- 角色ID
	self._dataid 		= dataid		-- 数据ID
	self._guest 		= guest			-- 宾客角色
	self._luggages 		= {}			-- 物品
	self._equipments 	= {}			-- 装备
	self._buffs			= {}			-- Buff
	self._soldiers 		= -1			-- 兵力
	self._soldiermax	= 0				-- 总兵力
	self._baseattr = { 
		atktimes = ROLEATTR.atktimes.min  
	}

	self._roledb = dbMgr.roles[self._dataid]
	if self._roledb then
		self:loadRoleData()
		self:updateAttribute()
	else
		logMgr:warn(C_LOGTAG, "role [%d] is't found !!!",self._dataid)
	end

	self:setValid(self:checkValid())
end

-- 加载角色数据
function Role:loadRoleData()
	-- 角色属性
	self._attribute = {
		force 		= self._roledb.force,
		intellect 	= self._roledb.intellect,
		speed 		= self._roledb.speed,
		dodge 		= (self._roledb.dodge or 0) + gameMgr:getDefaultDodge(),
		stydodge 	= (self._roledb.stydodge or 0) + gameMgr:getDefaultStrategyDodge(),
		styresist 	= self._roledb.styresist,
		attack 		= self._roledb.attack,
		defense 	= self._roledb.defense,
		atktimes 	= self._roledb.atktimes,
	}

	-- 队伍属性
	self._teamattr = {}
end

-- 角色是否有效
function Role:checkValid()
	return (self._roledb ~= nil)
end
function Role:setValid(valid)
	self.valid = valid
end
function Role:isValid()
	return self.valid
end

-- 角色临时数据
function Role:setData(key,value)
	self._tempdata[key] = value
end
function Role:getData(key)
	return self._tempdata[key]
end
function Role:clearData()
	self._tempdata = {}
end

-- 角色是否已死亡
function Role:isDead()
	return (self._soldiers == 0)
end

-- 角色是否是宾客
function Role:isGuest()
	return self._guest
end

-- 获得角色ID
function Role:getID()
	return self._id
end

-- 获得角色数据ID
function Role:getDataID()
	return self._dataid
end

-- 获得角色姓名
function Role:getName()
	return self._roledb.name
end

-- 获得角色头像
function Role:getHead()
	return self._roledb.head or dbMgr.configs.defaulthead
end

-- 获得角色模型
function Role:getModel()
	return self._roledb.model
end

-- 获得角色的技能
function Role:getSkills()
	return self._roledb.skills
end

-- 获得角色的阵型
function Role:getFormations()
	return self._roledb.formations
end

-- 获得角色的谋略
function Role:getStrategys()
	return self._roledb.strategys
end

-- 获得角色的脚本
function Role:getRoleScript(type)
	return self._roledb["script_" .. type]
end

---------------------------[[ 属性

-- 更新角色属性
function Role:updateAttribute(attrname)
	local function _updateAttribute(_attrname)
		local attrconf = ROLEATTR[_attrname]
		if attrconf then
			local value = (self._baseattr[_attrname] or 0) + (self._attribute[_attrname] or 0)
			if attrconf.min ~= nil and value < attrconf.min then
				value = attrconf.min
			elseif attrconf.max ~= nil and value > attrconf.max then
				value = attrconf.max
			end
			self["@" .. _attrname] = value
		end
	end
	if attrname then
		_updateAttribute(attrname)
	else
		for _,attrname in ipairs(table.keys(ROLEATTR)) do
			_updateAttribute(attrname)
		end
	end
end

-- 获得角色属性
function Role:getAttribute(attrname)
	return self["@" .. attrname] or 0
end

-- 角色武力
function Role:getForce()
	return self:getAttribute("force")
end
function Role:addBaseForce(force, noupd)
	self._baseattr.force = (self._baseattr.force or 0) + force
	if not noupd then self:updateAttribute("force") end
end
function Role:addForce(force, noupd)
	self._attribute.force = (self._attribute.force or 0) + force
	if not noupd then self:updateAttribute("force") end
end

-- 角色智力
function Role:getIntellect()
	return self:getAttribute("intellect")
end
function Role:addBaseIntellect(intellect, noupd)
	self._baseattr.intellect = (self._baseattr.intellect or 0) + intellect
	if not noupd then self:updateAttribute("intellect") end
end
function Role:addIntellect(intellect, noupd)
	self._attribute.intellect = (self._attribute.intellect or 0) + intellect
	if not noupd then self:updateAttribute("intellect") end
end

-- 角色速度
function Role:getSpeed()
	return self:getAttribute("speed")
end
function Role:addBaseSpeed(speed, noupd)
	self._baseattr.speed = (self._baseattr.speed or 0) + speed
	if not noupd then self:updateAttribute("speed") end
end
function Role:addSpeed(speed, noupd)
	self._attribute.speed = (self._attribute.speed or 0) + speed
	if not noupd then self:updateAttribute("speed") end
end

-- 角色攻击
function Role:getAttack()
	return self:getAttribute("attack")
end
function Role:addBaseAttack(attack, noupd)
	self._baseattr.attack = (self._baseattr.attack or 0) + attack
	if not noupd then self:updateAttribute("attack") end
end
function Role:addAttack(attack, noupd)
	self._attribute.attack = (self._attribute.attack or 0) + attack
	if not noupd then self:updateAttribute("attack") end
end

-- 角色防御
function Role:getDefense()
	return self:getAttribute("defense")
end
function Role:addBaseDefense(defense, noupd)
	self._baseattr.defense = (self._baseattr.defense or 0) + defense
	if not noupd then self:updateAttribute("defense") end
end
function Role:addDefense(defense, noupd)
	self._attribute.defense = (self._attribute.defense or 0) + defense
	if not noupd then self:updateAttribute("defense") end
end

-- 角色攻击次数
function Role:getAttackTimes()
	return self:getAttribute("atktimes")
end
function Role:addBaseAttackTimes(atktimes, noupd)
	self._baseattr.atktimes = (self._baseattr.atktimes or 0) + atktimes
	if not noupd then self:updateAttribute("atktimes") end
end
function Role:addAttackTimes(atktimes, noupd)
	self._attribute.atktimes = (self._attribute.atktimes or 0) + atktimes
	if not noupd then self:updateAttribute("atktimes") end
end

-- 角色闪避
function Role:getDodge()
	return self:getAttribute("dodge")
end
function Role:addBaseDodge(dodge, noupd)
	self._baseattr.dodge = (self._baseattr.dodge or 0) + dodge
	if not noupd then self:updateAttribute("dodge") end
end
function Role:addDodge(dodge, noupd)
	self._attribute.dodge = (self._attribute.dodge or 0) + dodge
	if not noupd then self:updateAttribute("dodge") end
end

-- 角色策略闪避
function Role:getStrategyDodge()
	return self:getAttribute("stydodge")
end
function Role:addBaseStrategyDodge(stydodge, noupd)
	self._baseattr.stydodge = (self._baseattr.stydodge or 0) + stydodge
	if not noupd then self:updateAttribute("stydodge") end
end
function Role:addStrategyDodge(stydodge, noupd)
	self._attribute.stydodge = (self._attribute.stydodge or 0) + stydodge
	if not noupd then self:updateAttribute("stydodge") end
end

-- 角色策略抵抗
function Role:getStrategyResistance()
	return self:getAttribute("styresist")
end
function Role:addBaseStrategyResistance(styresist, noupd)
	self._baseattr.styresist = (self._baseattr.styresist or 0) + styresist
	if not noupd then self:updateAttribute("styresist") end
end
function Role:addStrategyResistance(styresist, noupd)
	self._attribute.styresist = (self._attribute.styresist or 0) + styresist
	if not noupd then self:updateAttribute("styresist") end
end

-- 队伍属性
function Role:getTeamAttribute(attrname)
	return self._teamattr[attrname] or 0
end
function Role:addTeamAttribute(attrname,attrval, noupd)
	self._teamattr[attrname] = (self._teamattr[attrname] or 0) + attrval
	if not noupd then self:notify(false, true, "TEAM_ATTRIBUTE", attrname) end
end

---------------------------]]

-- 获得可用谋略点
function Role:getAvailableSP()
	local sp = self._team and self._team:getMSP() or 0
	return math.floor(self:getIntellect() / gameMgr:getAttributeMax() * sp)
end

-- 获得当前等级可用的技能
function Role:getAvailableSkills(level)
	local slevels = {}
	local avlskills = {}
	local allskills = self._roledb.skills
	if allskills then
		for sid,_ in pairs(allskills) do 
			local slevel = skillMgr:getLevel(sid)
			local stype = skillMgr:getType(sid)
			if (level >= slevel) and 
				(not slevels[stype] or slevel > slevels[stype]) then
				slevels[stype] = slevel
				avlskills[stype] = sid
			end
		end
	end
	return avlskills
end

-- 获得当前等级可用的阵型
function Role:getAvailableFormations(level)
	local avlformations = {}
	local allformations = self._roledb.formations
	if allformations then
		for fid,_ in pairs(allformations) do 
			local flevel = formationMgr:getLevel(fid)
			if level >= flevel then
				avlformations[#avlformations + 1] = fid
			end
		end
	end
	table.sort(avlformations,function (a,b)
		return formationMgr:getLevel(a) < formationMgr:getLevel(b)
	end)
	return avlformations
end

-- 获得当前等级可用的谋略
function Role:getAvailableStrategys(level)
	local avlstrategys = {}
	local allstrategys = self._roledb.strategys
	if allstrategys then
		for tid,_ in pairs(allstrategys) do 
			local slevel = strategyMgr:getLevel(tid)
			if level >= slevel then
				avlstrategys[#avlstrategys + 1] = tid
			end
		end
	end
	table.sort(avlstrategys,function (a,b)
		return strategyMgr:getLevel(a) < strategyMgr:getLevel(b)
	end)
	return avlstrategys
end

-- 能否学会技能
function Role:canLearnSkill(id)
	return self._roledb.skills and self._roledb.skills[id]
end

-- 能否学会谋略
function Role:canLearnStrategy(id)
	return self._roledb.strategys and self._roledb.strategys[id]
end

-- 能否学会阵形
function Role:canLearnFormation(id)
	return self._roledb.formations and self._roledb.formations[id]
end

-- 获得指定等级学习的技能
function Role:getLearnSkills(level)
	local skills = {}
	local learns = gameMgr:getLevelLearns(level)
	if learns and learns.skills then
		for _,sid in ipairs(learns.skills) do
			if self:canLearnSkill(sid) then
				table.insert(skills, sid)
			end
		end
	end
	return skills
end

-- 获得指定等级学习的谋略
function Role:getLearnStrategys(level)
	local strategys = {}
	local learns = gameMgr:getLevelLearns(level)
	if learns and learns.strategys then
		for _,sid in ipairs(learns.strategys) do
			if self:canLearnStrategy(sid) then
				table.insert(strategys, sid)
			end
		end
	end
	return strategys
end

-- 获得指定等级学习的阵形
function Role:getLearnFormations(level)
	local formations = {}
	local learns = gameMgr:getLevelLearns(level)
	if learns and learns.formations then
		for _,fid in ipairs(learns.formations) do
			if self:canLearnFormation(fid) then
				table.insert(formations, fid)
			end
		end
	end
	return formations
end

-- 检查指定武器是否可以使用
function Role:checkWeapon(item)
	if iskindof(item,"Weapon") then
		return self._roledb.weapon == item:getWeaponType()
	end
end

-- 队伍的BUFF
function Role:getBuffs()
	return self._buffs
end
function Role:addBuff(bid,state,onComplete)
	self:removeBuff(bid,function ()
		self._buffs[bid] = state
		self:notify(onComplete, true, "ADDBUFF", bid, state)
	end)
end
function Role:removeBuff(bid,onComplete)
	if not self._buffs[bid] then
		if onComplete then onComplete() end
	else
		self._buffs[bid] = nil
		self:notify(onComplete, true, "REMOVEBUFF", bid)
	end
end
function Role:clearBuff(fn,onComplete)
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

-- 获得士兵数量
function Role:getSoldiers()
	return (self._soldiers ~= -1) and self._soldiers or 0
end

-- 恢复士兵数
function Role:recoverSoldiers(maxsoldiers,onComplete)
	if self:isDead() then
		if onComplete then onComplete(0,false) end
	else
		maxsoldiers = maxsoldiers or (self._soldiermax - self._soldiers)
		local recvsods = math.min(maxsoldiers,self._soldiermax - self._soldiers)
		self._soldiers = self._soldiers + recvsods
		self:notify(function ()
			if onComplete then onComplete(recvsods,self:isMaxSoldiers()) end
		end, true, "SOLDIERS", self._soldiers)
	end
end

-- 检查当前是否是最大兵力数量
function Role:isMaxSoldiers()
	return (self._soldiers >= self._soldiermax)
end

-- 通知监听器
function Role:notify(onComplete, order, ...)
	local args = { ... }
	AsynchNotifier.notify(self, function ()
		if self._team then
			self._team:onRoleNotify(onComplete,self,unpack(args))
		else
			if onComplete then onComplete() end
		end
	end, order, ...)
end

-- 角色队伍
function Role:getTeam()
	return self._team
end
function Role:setTeam(team, noupd)
	self._team = team
	if team and not noupd then
		self:updateSoldiers() 	-- 根据等级兵力下降
	end
end

-- 损失兵力
function Role:lostSoldiers(soldiers,onComplete)
	if self:isDead() then
		if onComplete then onComplete(0, true) end
	else
		local losses = math.min(soldiers or self._soldiers, self._soldiers)
		self._soldiers = self._soldiers - losses
		self:notify(function ()
			if not self:isDead() then
				if onComplete then onComplete(losses, false) end
			else
				self:notify(function ()
					if onComplete then onComplete(losses, true) end
				end, true, "DEAD")
			end
		end, true, "SOLDIERS", self._soldiers)
	end
end

-- 复活角色
function Role:reviveRole(soldiers,onComplete)
	if not self:isDead() then
		if onComplete then onComplete(self._soldiers) end
	else
		self._soldiers = math.min(soldiers or 500,self._soldiermax)
		self:notify(function ()
			if self:isDead() then
				if onComplete then onComplete(self._soldiers) end
			else
				self:notify(function ()
					if onComplete then onComplete(self._soldiers) end
				end, true, "REVIVE")
			end
		end, true, "SOLDIERS", self._soldiers)
	end
end

-- 获得士兵最大数量
function Role:getSoldierMax()
	return self._soldiermax
end

-- 设置最大的士兵数量(宾客角色)
function Role:setSoldierMax(soldiers)
	if self._guest then
		self._soldiermax = soldiers
		if self._soldiers == -1 or self._soldiers > soldiers then
			self._soldiers = soldiers
			self:notify(false,true,"SOLDIERS",self._soldiers)
		end
	end
end

-- 获得物品数量
function Role:getLuggageCount()
	return #self._luggages
end

-- 获得所有物品
function Role:getLuggages()
	return self._luggages
end

-- 获得指定位置的物品
function Role:getLuggage(index)
	return self._luggages[index]
end

-- 根据ID获得指定行李和位置
function Role:getLuggageByID(id)
	for i,luggage in ipairs(self._luggages) do
		if luggage:getID() == id then
			return luggage,i	
		end
	end
end

-- 向行李中添加物品
--[[
	item	: 物品
	method  : 添加方法 (STACK,PLACE)
]]
function Role:addLuggage(item,method)
	item = item:upgradeType()
	if item:getCount() <= 0 then return true end
	if (not item:isValid()) or item:getStackMax() <=1 then
		method = "PLACE"
	end

	if not method or method == "STACK" then
		for i,luggage in ipairs(self._luggages) do
			luggage:stackItem(item)
			if not item:isValid() then return true end
		end
	end
	if not method or method == "PLACE" then
		if #self._luggages < dbMgr.configs.bagcapacity then
			self._luggages[#self._luggages + 1] = item
			return true
		end
	end
	return false
end

-- 移除指定位置的物品
function Role:removeLuggage(index,count)
	local luggage = self._luggages[index]
	if luggage then
		if iskindof(luggage,"Accessory") and luggage:isEquiped() then
			scriptMgr:createObject(luggage:getEquipScript(),{
				role = self,
				accessory = luggage,
			}):execute("UNEQUIP_ITEM")
			luggage:setEquip(false)
		end
		local item = luggage:splitItem(count or luggage:getCount())
		if not luggage:isValid() then
			table.remove(self._luggages,index)
		end
		return item
	end
end

-- 移除并返回所有携带物品
function Role:removeLuggages()
	local luggages = {}
	while true do
		local luggage = self:removeLuggage(1)
		if not luggage then break end
		luggages[#luggages + 1] = luggage
	end
	return luggages
end

-- 测试是否可以携带指定数量的物品
function Role:canAddToLuggage(item,count)
	if #self._luggages < dbMgr.configs.bagcapacity then
		return true
	else
		count = count or item:getCount()
		for _,luggage in ipairs(self._luggages) do 
			if luggage:getDataID() == item:getDataID() and 
				luggage:getCount() + count <= item:getStackMax() then
				return true
			end
		end
	end
	return false
end

-- 获得所有装备
function Role:getEquipments()
	return self._equipments
end

-- 获得可用的武器
function Role:getAvailableWeapon()
	local weapon = self:getEquipment("W")
	if weapon and self:checkWeapon(weapon) then
		return weapon
	end
end

-- 获得武器
function Role:getWeapon()
	return self:getEquipment("W")
end

-- 装备武器 (是否成功,替换或原来的物品)
function Role:equipWeapon(weapon)
	weapon = weapon:upgradeType()
	if not iskindof(weapon,"Weapon") then
		return false,weapon
	else
		return true,self:addEquipment(weapon)
	end
end

-- 获得盔甲
function Role:getArmour()
	return self:getEquipment("A")
end

-- 装备盔甲 (是否成功,替换或原来的物品)
function Role:equipArmour(armour)
	armour = armour:upgradeType()
	if not iskindof(armour,"Armor") or armour:getArmorType() ~= "A" then
		return false,armour
	else
		return true,self:addEquipment(armour)
	end
end

-- 获得头盔
function Role:getHelmet()
	return self:getEquipment("H")
end

-- 装备头盔 (是否成功,替换或原来的物品)
function Role:equipHelmet(helmet)
	helmet = helmet:upgradeType()
	if not iskindof(helmet,"Armor") or helmet:getArmorType() ~= "H" then
		return false,helmet
	else
		return true,self:addEquipment(helmet)
	end
end

-- 获得盾牌
function Role:getShield()
	return self:getEquipment("S")
end

-- 装备盾牌 (是否成功,替换或原来的物品)
function Role:equipShield(shield)
	shield = shield:upgradeType()
	if not iskindof(shield,"Armor") or shield:getArmorType() ~= "S" then
		return false,shield
	else
		return true,self:addEquipment(shield)
	end
end

-- 获得指定类型的装备
function Role:getEquipment(type)
	return self._equipments[type]
end

-- 根据ID获得指定位置的装备
function Role:getEquipmentTypeByID(id)
	for type,equipment in pairs(self._equipments) do
		if equipment:getID() == id then
			return type	
		end
	end
end

-- 设置指定部位的装备
function Role:addEquipment(item)
	item = item:upgradeType()
	if not iskindof(item,"Equipment") then return item end
	local type = iskindof(item,"Weapon") and "W" or item:getArmorType()
	local oldequip = self:removeEquipment(type)
	self._equipments[type] = item
	scriptMgr:createObject(item:getEquipScript(),{
		role = self,
		equipment = item,
	}):execute("EQUIP_ITEM")
	return oldequip
end

-- 移除指定部位装备
function Role:removeEquipment(type)
	local equipment = self._equipments[type]
	if equipment then
		scriptMgr:createObject(equipment:getEquipScript(),{
			role = self,
			equipment = equipment,
		}):execute("UNEQUIP_ITEM")
		self._equipments[type] = nil
		return equipment
	end
end

-- 移除并返回所有装备
function Role:removeEquipments()
	local equipments = {}
	for _,type in ipairs(C_EQUIPTYPES) do
		local equipment = self:removeEquipment(type)
		if equipment then
			equipments[#equipments + 1] = equipment
		end
	end
	return equipments
end

-- 装备饰品
function Role:equipAccessory(index)
	local luggage = self._luggages[index]
	if luggage then
		if iskindof(luggage,"Accessory") and not luggage:isEquiped() then
			scriptMgr:createObject(luggage:getEquipScript(),{
				role = self,
				accessory = luggage,
			}):execute("EQUIP_ITEM")
			luggage:setEquip(true)
			return true
		end
	end
	return false
end

-- 卸下饰品
function Role:unequipAccessory(index)
	local luggage = self._luggages[index]
	if luggage then
		if iskindof(luggage,"Accessory") and luggage:isEquiped() then
			scriptMgr:createObject(luggage:getEquipScript(),{
				role = self,
				accessory = luggage,
			}):execute("UNEQUIP_ITEM")
			luggage:setEquip(false)
			return true
		end
	end
	return false
end

-- 更新兵力数量
function Role:updateSoldiers()
	local soldierkey = self._roledb.soldier
	if not self._guest and soldierkey then
		local soldierline = dbMgr.soldiers[soldierkey]
		if soldierline then
			local soldiers = soldierline["L" .. tostring(self._team:getLevel())]
			if soldiers then
				self._soldiermax = soldiers
				if self._soldiers == -1 or self._soldiers > soldiers then
					self._soldiers = soldiers
					self:notify(false,true,"SOLDIERS",self._soldiers)
				end
			end
		end
	end
end

-- 当队伍升级调用
function Role:onTeamLevelUp(level,msgs)
	self:updateSoldiers()
	if not self._guest and msgs then
		table.insert(msgs, {
			name = self:getName(),
			soldiers = self:getSoldierMax(),
			skills = self:getLearnSkills(level),
			strategys = self:getLearnStrategys(level),
			formations = self:getLearnFormations(level)
		})
	end
end

return Role
