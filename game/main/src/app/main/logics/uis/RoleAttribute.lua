--[[
	角色属性
--]]
local THIS_MODULE = ...

-- 头像资源索引
local C_HEAD_IPATH = "res/files/heads"

local MAXPAGE = 3
local S_INPUTKEYS = bit.bor(ctrlMgr.KEY_A,ctrlMgr.KEY_B)

local RoleAttribute = class("RoleAttribute", require("app.main.modules.ui.FrameBase"))

--[[
	构造函数
	config
		params		额外参数
		name		名称
		csb			csb文件
		widgets		组件表
		bindings	绑定表
]]
function RoleAttribute:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function RoleAttribute:dtor()
	self:delete()
	self:release()
end

-- 打开窗口
function RoleAttribute:OnOpen(role) 
	self._role = role
	self._team = role:getTeam()
	self.page = 1
	self:showPage(self.page)
end

-- 关闭窗口
function RoleAttribute:OnClose()
	self._role = nil
	self._team = nil
	self.page = 1
end

-- 显示指定页
function RoleAttribute:showPage(page)
	if page == 1 then
		self:showRole()
	elseif page == 2 then
		self:showSkillFormation()
	else
		self:showStrategy()
	end
end

-- 显示将领信息
function RoleAttribute:showRole()
	self.pl_attributes:setVisible(true)
	self.pl_skillfmts:setVisible(false)
	self.wg_strategys:setVisible(false)

	self:setRoleName(self._role:getName())
	self:setRoleHead(self._role:getHead())
	self:setForce(self._role:getForce())
	self:setIntellect(self._role:getIntellect())
	self:setSpeed(self._role:getSpeed())
	self:setAttack(self._role:getAttack())
	self:setDefense(self._role:getDefense())

	local equips = self._role:getEquipments()
	self:setEquipment(
		equips.W and equips.W:getName() or nil,
		equips.A and equips.A:getName() or nil,
		equips.H and equips.H:getName() or nil,
		equips.S and equips.S:getName() or nil
	)

	self:setSoldiers(self._role:getSoldiers())
end

-- 显示技能和阵型
function RoleAttribute:showSkillFormation()
	if not self._role:getSkills() and not self._role:getFormations() then
		self.page = self.page + 1
		return self:showStrategy()
	end
	self.pl_attributes:setVisible(false)
	self.pl_skillfmts:setVisible(true)
	self.wg_strategys:setVisible(false)

	local skillnames = {}
	local avlskills = self._role:getAvailableSkills(self._team:getLevel())
	skillnames[1] = avlskills.F and skillMgr:getName(avlskills.F) or ""
	skillnames[2] = avlskills.W and skillMgr:getName(avlskills.W) or ""
	skillnames[3] = avlskills.S and skillMgr:getName(avlskills.S) or ""
	skillnames[4] = avlskills.H and skillMgr:getName(avlskills.H) or ""

	local formationnames = {}
	local avlformations = self._role:getAvailableFormations(self._team:getLevel())
	for _,fid in ipairs(avlformations) do 
		formationnames[#formationnames + 1] = formationMgr:getName(fid)
	end
	
	self:setSkills(skillnames)
	self:setFormations(formationnames)
end

-- 显示谋略
function RoleAttribute:showStrategy()
	if not self._role:getStrategys() then
		return self:closeFrame()
	end
	self.pl_attributes:setVisible(false)
	self.pl_skillfmts:setVisible(false)
	self.wg_strategys:setVisible(true)

	local strategynames = {}
	local strategys = self._role:getAvailableStrategys(self._team:getLevel())
	for _,tid in ipairs(strategys) do 
		strategynames[#strategynames + 1] = strategyMgr:getName(tid)
	end

	self:setStrategys(strategynames)
end

-- 设置名字
function RoleAttribute:setRoleName(name)
	self.lb_rolename:setString(name)
end

-- 设置头像
function RoleAttribute:setRoleHead(headimg,flipx)
	if not headimg then
		self.sp_rolehead:setVisible(false)
	else
		self.sp_rolehead:setFlippedX(flipx)
		self.sp_rolehead:setTexture(indexMgr:getIndex(C_HEAD_IPATH .. "/" .. headimg))
		self.sp_rolehead:setVisible(true)
	end
end

-- 设置兵力
function RoleAttribute:setSoldiers(soldiers)
	self.lb_soldiers:setString(tostring(soldiers))
end

-- 设置装备
function RoleAttribute:setEquipment(weapon,armour,helmet,shield)
	if weapon and not self._role:getAvailableWeapon() then
		weapon = ":" .. weapon	-- 无效的武器
	end
	self.wg_equipments:updateParams({
		items = {
			{label = weapon or ""},
			{label = armour or ""},
			{label = helmet or ""},
			{label = shield or ""}
		}
	})
end

-- 设置武力
function RoleAttribute:setForce(value)
	self.lb_forcevalue:setString(tostring(value))
	self.wg_forcebar:setMaxValue(gameMgr:getAttributeMax())
	self.wg_forcebar:setValue(value)
end

-- 设置智力
function RoleAttribute:setIntellect(value)
	self.lb_intellectvalue:setString(tostring(value))
	self.wg_intellectbar:setMaxValue(gameMgr:getAttributeMax())
	self.wg_intellectbar:setValue(value)
end

-- 设置速度
function RoleAttribute:setSpeed(value)
	self.lb_speedvalue:setString(tostring(value))
	self.wg_speedbar:setMaxValue(gameMgr:getAttributeMax())
	self.wg_speedbar:setValue(value)
end

-- 设置攻击
function RoleAttribute:setAttack(value)
	self.lb_attackvalue:setString(tostring(value))
	self.wg_attackbar:setMaxValue(gameMgr:getAttributeMax())
	self.wg_attackbar:setValue(value)
end

-- 设置防御
function RoleAttribute:setDefense(value)
	self.lb_defensevalue:setString(tostring(value))
	self.wg_defensebar:setMaxValue(gameMgr:getAttributeMax())
	self.wg_defensebar:setValue(value)
end

-- 设置技能
function RoleAttribute:setSkills(names)
	local items = {}
	for i,name in ipairs(names) do 
		items[i] = { label = name }
	end
	self.wg_skills:updateParams({ items = items })
end

-- 设置阵型
function RoleAttribute:setFormations(names)
	local items = {}
	for i,name in ipairs(names) do 
		items[i] = { label = name }
	end
	self.wg_formations:updateParams({ items = items })
end

-- 设置谋略
function RoleAttribute:setStrategys(names)
	local items = {}
	for i,name in ipairs(names) do 
		items[i] = { label = name }
	end
	self.wg_strategys:updateParams({ items = items })
end

-- 输入处理
function RoleAttribute:onControlKey(keycode)
	if bit.band(keycode,S_INPUTKEYS) ~= 0 then
		if self.page >= MAXPAGE then
			self:closeFrame()
		else
			self.page = self.page + 1
			self:showPage(self.page)
		end
	end
end

return RoleAttribute
