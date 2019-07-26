--[[
	DEMO 战斗
]]

-- 切换特效
local C_TRANSITION = {
	method = "TURNOFFTILES",
	time = 0.7,
}

local DemoBattle = class("DemoBattle", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function DemoBattle:ctor(config)
	if config then
		if type(config) == "table" then
			table.merge(self,config)
		else	-- string
			self:parse(config)
		end
	end
end

-- 执行对话
function DemoBattle:execute(onComplete)
	if onComplete then onComplete() end

	local map = sceneMgr:getCurrentScene()
	gameMgr:setMapEnv("battlemap",map:buildMapArchive())

	local role = nil
	local enemyteam = tools:createTeam()

	role = tools:createRole("C68",true)
	role:setSoldierMax(400)
	enemyteam:joinRole(role)
	role:addEquipment(tools:createItem("I1"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	role = tools:createRole("C69",true)
	role:setSoldierMax(400)
	enemyteam:joinRole(role)
	role:addEquipment(tools:createItem("I19"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	role = tools:createRole("C70",true)
	role:setSoldierMax(400)
	enemyteam:joinRole(role)
	role:addEquipment(tools:createItem("I19"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	role = tools:createRole("C71",true)
	role:setSoldierMax(400)
	enemyteam:joinRole(role)
	role:addEquipment(tools:createItem("I38"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	role = tools:createRole("C214",true)
	role:setSoldierMax(400)
	enemyteam:joinRole(role)
	role:addEquipment(tools:createItem("I19"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	role = tools:createRole("C72",true)
	role:setSoldierMax(400)
	enemyteam:joinRole(role)
	role:addEquipment(tools:createItem("I1"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))
	enemyteam:setAdviserID(role:getID())

	enemyteam:setFormation({ fid = "F4" })

	audioMgr:playSE(gameMgr:getEnterBattleSE())
	sceneMgr:setTransition(C_TRANSITION)
	sceneMgr:switchScene("BattleScene",{
		our = {
			team = majorTeam,
		},
		enemy = {
			team = enemyteam,
		},
		terrain = "plain",
		environment = "city",
		bgm = "battle_4",
	})
end

-- 解析配置
function DemoBattle:parse(config)
	
end

return DemoBattle
