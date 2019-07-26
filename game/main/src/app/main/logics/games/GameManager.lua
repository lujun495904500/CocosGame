--[[
	游戏管理器
--]]
local THIS_MODULE = ...

-- plist索引路径
local C_PLIST_IPATH = "res/plists"

-- ID类型
local C_ID_TYPES = {
	ROLE = 1,
	ITEM = 2,
}

-- 切换特效
local C_TRANSITION = {
	method = "FADE",
	time = 0.4,
}

local GameManager = class("GameManager", require("app.main.modules.index.IndexListener"))

-- 获得单例对象
local instance = nil
function GameManager:getInstance()
	if instance == nil then
		instance = GameManager:create()
		indexMgr:addListener(instance, { C_PLIST_IPATH })
	end
	return instance
end

-------------------------IndexListener-------------------------
-- 清空索引
function GameManager:onIndexesRemoved()
	spriteFrameCache:removeUnusedSpriteFrames()
	self:onIndexesLoaded(C_PLIST_IPATH, indexMgr:getIndex(C_PLIST_IPATH))
end

-- 加载索引路径
function GameManager:onIndexesLoaded(ipath, ivalue)
	if ivalue then
		if ipath == C_PLIST_IPATH then
			for _,plist in ipairs(ivalue) do
				spriteFrameCache:addSpriteFrames(plist)
			end
		end
	end
end
-------------------------IndexListener-------------------------

-- 构造函数
function GameManager:ctor()
	self._nowitemid = 0		-- 物品ID
	self._nowroleid = 0		-- 人物ID
	self._mapenvs = {}		-- 地图环境

	archMgr:addListener(handler(self,GameManager.archiveListener))
end

-- 生成新的物品id
function GameManager:newItemID()
	self._nowitemid = self._nowitemid + 1
	return string.format("%d%d%d",C_ID_TYPES.ITEM,os.time(),self._nowitemid)
end

-- 生成新的角色id
function GameManager:newRoleID()
	self._nowroleid = self._nowroleid + 1
	return string.format("%d%d%d",C_ID_TYPES.ROLE,os.time(),self._nowroleid)
end

-- 存档监听器
function GameManager:archiveListener(type,data,info)
	if type == "LOAD" then

		playMgr:setCurrentPlay(data.play)
		self._mapenvs = data.mapenvs

	elseif type == "SAVE" then 

		data.play = playMgr:getCurrentPlay()
		data.mapenvs = self._mapenvs

	elseif type == "NEW" then

		playMgr:setCurrentPlay(self:getInitPlay())
		self._mapenvs = {}

	end
end

-- 地图环境
function GameManager:setMapEnv(key,value)
	self._mapenvs[key] = value
end
function GameManager:getMapEnv(key)
	return self._mapenvs[key]
end

-- 转义字符串
function GameManager:parseString(str,extvars)
	return varMgr:replace(str,extvars)
end

-- 转义字符串数组
function GameManager:parseStrings(strs,extvars)
	local retstrs = {}
	for i,str in ipairs(strs) do 
		retstrs[i] = self:parseString(str,extvars)
	end
	return retstrs
end

-- 获得指定的字符串数组
function GameManager:getStrings(keys,extvars,consp)
	local tstrs = {}
	if type(keys) == "table" then
		for _,key in ipairs(keys) do
			for _,str in ipairs(dbMgr.strings[key]) do
				if consp then
					if #tstrs <= 0 then
						tstrs[1] = str
					else
						tstrs[1] = tstrs[1] .. consp .. str
					end
				else
					tstrs[#tstrs + 1] = str
				end
			end
		end
	else
		tstrs = dbMgr.strings[keys]
	end
	return self:parseStrings(tstrs,extvars)
end

-- 获得初始剧本
function GameManager:getInitPlay()
	return dbMgr.configs.playinit
end

-- 获得初始地形值
function GameManager:getInitTerrain()
	return dbMgr.configs.terraininit
end

-- 获得NPC地形值
function GameManager:getNPCTerrain()
	return dbMgr.configs.npcterrain
end

-- 获得时间脉搏
function GameManager:getTimeTick()
	return dbMgr.configs.timetick
end

-- 获得找到物品脚本
function GameManager:getFindItemScript()
	return dbMgr.configs.finditemscript
end

-- 获得谋略点初始值
function GameManager:getInitSp()
	return dbMgr.configs.spinit
end

-- 获得谋略点最大值
function GameManager:getSpMax()
	return dbMgr.configs.spmax
end

-- 获得谋略点升级增值
function GameManager:getLeveUpSp()
	return math.random(dbMgr.configs.splvupmin,dbMgr.configs.splvupmax)
end

-- 获得最大属性值
function GameManager:getAttributeMax()
	return dbMgr.configs.attributemax
end

-- 获得默认的队伍名称
function GameManager:getDefaultTeamName()
	return dbMgr.configs.defaultteamname
end

-- 获得指定等级的经验
function GameManager:getLevelExps(level)
	return dbMgr.experiences[dbMgr.configs.levelconfig][string.format("L%d",level)]
end

-- 获得指定等级的学习的技能等
function GameManager:getLevelLearns(level)
	return dbMgr.levellearns[string.format("L%d",level)]
end

-- 获得碰撞音效
function GameManager:getCollisionSE()
	return dbMgr.configs.collisionse
end

-- 获得升级音效
function GameManager:getLevelUpSE()
	return dbMgr.configs.levelupse
end

-- 获得进入战斗音效
function GameManager:getEnterBattleSE()
	return dbMgr.configs.enterbattlese
end

-- 获得战斗攻击脚本
function GameManager:getBattleAttack()
	return dbMgr.configs.battleattack
end

-- 获得战斗防御脚本
function GameManager:getBattleDefense()
	return dbMgr.configs.battledefense
end

-- 获得战斗使用物品脚本
function GameManager:getBattleUseItem()
	return dbMgr.configs.battleuseitem
end

-- 获得地图展示脚本
function GameManager:getMapUseItem()
	return dbMgr.configs.mapuseitem
end

-- 获得防御音效
function GameManager:getDefenseSE()
	return dbMgr.configs.defensese
end

-- 默认命中音效
function GameManager:getDefaultHitSE()
	return dbMgr.configs.defaulthitse
end

-- 奋战命中音效
function GameManager:getExcitedHitSE()
	return dbMgr.configs.excitedhitse
end

-- 默认命中特效
function GameManager:getDefaultHitEffect()
	return dbMgr.configs.defaulthiteffect
end

-- 奋战命中特效
function GameManager:getExcitedtHitEffect()
	return dbMgr.configs.excitedhiteffect
end

-- 防御速度加成
function GameManager:getDefenseSpeed()
	return dbMgr.configs.defensespeed
end

-- 获得默认闪避
function GameManager:getDefaultDodge()
	return dbMgr.configs.defaultdodge
end

-- 获得默认策略闪避
function GameManager:getDefaultStrategyDodge()
	return dbMgr.configs.defaultstydodge
end

-- 获得默认的攻击AI
function GameManager:getDefaultAttackAI()
	return dbMgr.configs.defaultattackai
end

-- 获得默认的叛变AI
function GameManager:getDefaultBetrayAI()
	return dbMgr.configs.defaultbetrayai
end

-- 获得战斗胜利背景音乐
function GameManager:getVictoryBGM()
	return dbMgr.configs.victorybgm
end

-- 获得战斗失败背景音乐
function GameManager:getFailureBGM()
	return dbMgr.configs.failurebgm
end

-- 开始新游戏
function GameManager:startNewGame(name,slot)
	archMgr:newArchive(name,slot)
	archMgr:saveArchive(slot)
	packLoader:loadPacks(playMgr:getPlayPacks(), function ()
		playMgr:doCurrentPlay(false, "PLAY")
	end)
end

-- 开始游戏
function GameManager:startGame(slot)
	archMgr:loadArchive(slot)
	packLoader:loadPacks(playMgr:getPlayPacks(), function ()
		playMgr:doCurrentPlay(false, "PLAY")
	end)
end

-- 队伍失败
function GameManager:majorFailure()
	majorTeam:reviveTeam()
	sceneMgr:setTransition(C_TRANSITION)
	sceneMgr:switchScene("MapScene",gameMgr:getMapEnv("archivemap"))
end

-- 获得当前的宫殿地图
function GameManager:getPalaceMap(town)
	local townconf = dbMgr.towns[town]
	return townconf and townconf.palacemap or nil
end

-- 获得旅店花费
function GameManager:getHostelCost()
	return dbMgr.towns[self:getMapEnv("town")].hotelcost
end

-- 获得训练花费
function GameManager:getTrainingCost()
	return dbMgr.towns[self:getMapEnv("town")].trainingcost
end

-- 获得训练等级
function GameManager:getTrainingLevel()
	return dbMgr.towns[self:getMapEnv("town")].traininglevel
end

-- 获得商店装备
function GameManager:getShopEquips()
	return dbMgr.towns[self:getMapEnv("town")].equipments
end

-- 获得商店物品
function GameManager:getShopItems()
	return dbMgr.towns[self:getMapEnv("town")].items
end

-- 获得卖出折旧率
function GameManager:getSellDepreciate()
	return dbMgr.configs.selldepreciate
end

-- 获得购买折扣率
function GameManager:getBuyDiscount()
	return dbMgr.configs.buydiscount
end

-- 获得休息音乐
function GameManager:getRestBGM()
	return dbMgr.configs.restbgm
end

-- 获得记录音乐
function GameManager:getArchiveBGM()
	return dbMgr.configs.archivebgm
end

-- 获得队伍策略抵抗最大值
function GameManager:getStrategyResistanceMax()
	return dbMgr.configs.teamstyresistmax
end

-- 获得角色头像
function GameManager:getRoleHead(id)
	local roledb = dbMgr.roles[id]
	return roledb and roledb.head or dbMgr.configs.defaulthead
end

-- 确认退出游戏
function GameManager:ensureExitGame()
	uiMgr:openUI("select",{
		autoclose = true,
		showconfig = {
			quickshow = true,
			usesound = false,
			usecursor = false,	  
			ctrl_complete = false,
		},
		messages = gameMgr:getStrings("GAMEEXIT_ENSURE"),
		selects = {
			{
				label = gameMgr:getStrings("CONFIRM")[1],
				type = "Y",
			},{
				label = gameMgr:getStrings("CANCEL")[1],
				type = "N",
			}
		},
		onComplete = function (result,item)
			if result and item.type == "Y" then
				self:onExitGame()
			end
		end
	})
end

-- 当退出游戏
function GameManager:onExitGame()
	netThread:stop()
	logMgr:flushLog()
	director:endToLua()
end

return GameManager
