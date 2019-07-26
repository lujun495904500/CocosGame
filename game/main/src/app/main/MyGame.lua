--[[
	当前游戏
--]]
local THIS_MODULE = ...
local C_LOGTAG = "MyGame"

local utils = cc.safe_require("utils")
local MyGame = class("MyGame")

-- 构造应用
function MyGame:ctor()
	math.randomseed(os.time())

	self:initEngine()
	self:initModules()
	self:initLogics()
end

-- 初始化引擎
function MyGame:initEngine()
	cc.exports.director = cc.Director:getInstance()
	cc.exports.scheduler = director:getScheduler()
	cc.exports.fileUtils = cc.FileUtils:getInstance()
	cc.exports.fileMgr = L.FileManager:getInstance()
	cc.exports.userDefault = cc.UserDefault:getInstance()
	cc.exports.spriteFrameCache = cc.SpriteFrameCache:getInstance()

end

-- 初始化模块
function MyGame:initModules()
	cc.exports.indexMgr = require("app.main.modules.index.IndexManager"):getInstance()
	cc.exports.metaMgr = require("app.main.modules.meta.MetaManager"):getInstance()
	cc.exports.dbMgr = require("app.main.modules.database.DatabaseManager"):getInstance()
	cc.exports.ctrlMgr = require("app.main.modules.control.ControlManager"):getInstance()
	cc.exports.scriptMgr = require("app.main.modules.script.ScriptManager"):getInstance()
	cc.exports.playMgr = require("app.main.modules.play.PlayManager"):getInstance()
	cc.exports.archMgr = require("app.main.modules.archive.ArchiveManager"):getInstance()
	cc.exports.mapMgr = require("app.main.modules.map.MapManager"):getInstance()
	cc.exports.uiwdgMgr = require("app.main.modules.uiwidget.UIWidgetManager"):getInstance()
	cc.exports.uiMgr = require("app.main.modules.ui.UIManager"):getInstance()
	cc.exports.sceneMgr = require("app.main.modules.scene.SceneManager"):getInstance()
	cc.exports.varMgr = require("app.main.modules.variable.VariableManager"):getInstance()
	cc.exports.formulaMgr = require("app.main.modules.formula.FormulaManager"):getInstance()
	cc.exports.modelMgr = require("app.main.modules.model.ModelManager"):getInstance()
	cc.exports.audioMgr = require("app.main.modules.audio.AudioManager"):getInstance()
	cc.exports.fontMgr = require("app.main.modules.font.FontManager"):getInstance()
	cc.exports.effectMgr = require("app.main.modules.effect.EffectManager"):getInstance()
	cc.exports.packMgr = require("app.main.modules.pack.PackManager"):getInstance()
	cc.exports.b3Mgr = require("app.main.modules.behavior3.Behavior3Manager"):getInstance()
	cc.exports.netClient = require("app.main.modules.network.NetClient"):getInstance()
	cc.exports.netServer = require("app.main.modules.network.NetServer"):getInstance()
	cc.exports.netThread = require("app.main.modules.network.NetThread"):getInstance()
	
end

-- 初始化逻辑
function MyGame:initLogics()
	cc.exports.tools = require("app.main.logics.games.Tools"):getInstance()
	cc.exports.packLoader = require("app.main.logics.games.PackLoader"):getInstance()
	cc.exports.terrainMgr = require("app.main.logics.games.TerrainManager"):getInstance()
	cc.exports.skillMgr = require("app.main.logics.games.SkillManager"):getInstance()
	cc.exports.formationMgr = require("app.main.logics.games.FormationManager"):getInstance()
	cc.exports.strategyMgr = require("app.main.logics.games.StrategyManager"):getInstance()
	cc.exports.buffMgr = require("app.main.logics.games.BuffManager"):getInstance()
	cc.exports.seriaMgr = require("app.main.logics.games.SerializeManager"):getInstance()
	cc.exports.majorTeam = require("app.main.logics.games.MajorTeam"):getInstance()
	cc.exports.gameMgr = require("app.main.logics.games.GameManager"):getInstance()
	
end

-- 运行游戏
function MyGame:run()
	director:setDisplayStats(CC_SHOW_FPS and utils.isDebug())

	-- 设置索引环境配置
	indexMgr:setEnvConfig({
		srcpath = PATH.SOURCE,
		respath = PATH.RESOURCE,
	})

	-- 构建剧本
	playMgr:buildPlays()

	-- 处理启动和基础包加载
	PACK.BOOT.loader = packMgr:createPackLoader(PACK.BOOT.name)
	PACK.BOOT.loader:onLoad()
	for i,packname in ipairs(PACK.BASES) do
		PACK.LOADED[packname].loader = packMgr:createPackLoader(packname)
		PACK.LOADED[packname].loader:onLoad()
	end
	
	-- 启动网络线程
	if FLAG.ENABLENETWORK and gameConfig.enablenetwork then
		netThread:start()
	end
	
	-- 启动场景
	sceneMgr:switchScene("BootScene")

	-- 写入日志缓冲
	logMgr:flushLog()
	
	-- 开发测试
	--[[
	archMgr:newArchive("test",5)

	local role = nil
	majorTeam:setName("刘备军")

	role = tools:createRole("C1")
	majorTeam:joinRole(role)
	role:addEquipment(tools:createItem("I1"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	role = tools:createRole("C2")
	majorTeam:joinRole(role)
	role:addEquipment(tools:createItem("I37"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	role = tools:createRole("C3")
	majorTeam:joinRole(role)
	role:addEquipment(tools:createItem("I19"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	role = tools:createRole("C6")
	majorTeam:joinRole(role)
	role:addEquipment(tools:createItem("I1"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	role = tools:createRole("C12")
	majorTeam:joinRole(role)
	role:addEquipment(tools:createItem("I1"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	majorTeam:setAdviserID(role:getID())

	majorTeam:addExps(180)
	majorTeam:recoverSP()
	majorTeam:recoverSoldiers()

	local enemyteam = tools:createTeam()

	role = tools:createRole("C68",true)
	role:setSoldierMax(300)
	enemyteam:joinRole(role)
	role:addEquipment(tools:createItem("I1"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	role = tools:createRole("C69",true)
	role:setSoldierMax(300)
	enemyteam:joinRole(role)
	role:addEquipment(tools:createItem("I19"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	role = tools:createRole("C70",true)
	role:setSoldierMax(300)
	enemyteam:joinRole(role)
	role:addEquipment(tools:createItem("I19"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	role = tools:createRole("C71",true)
	role:setSoldierMax(300)
	enemyteam:joinRole(role)
	role:addEquipment(tools:createItem("I37"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

	role = tools:createRole("C72",true)
	role:setSoldierMax(300)
	enemyteam:joinRole(role)
	role:addEquipment(tools:createItem("I1"))
	role:addEquipment(tools:createItem("I46"))
	role:addEquipment(tools:createItem("I54"))
	role:addEquipment(tools:createItem("I61"))

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
	--]]
end

return MyGame
