--[[
	阵形管理器
--]]
local THIS_MODULE = ...

local FormationManager = class("FormationManager")

-- 获得单例对象
local instance = nil
function FormationManager:getInstance()
	if instance == nil then
		instance = FormationManager:create()
	end
	return instance
end

-- 获得配置
function FormationManager:getConfig(id)
	return dbMgr.formations[id]
end

-- 获得名称
function FormationManager:getName(id)
	return dbMgr.formations[id].name
end

-- 使用的谋略点
function FormationManager:getSP(id)
	return dbMgr.formations[id].sp
end

-- 习得等级
function FormationManager:getLevel(id)
	return dbMgr.formations[id].level
end

-- 获得位置偏移
function FormationManager:getOffest(id,location)
	return dbMgr.formations[id][string.format("offest_%d",location)] or 0
end

-- 获得位置加成
function FormationManager:getPositionAddition(id,type,location)
	return dbMgr.formations[id][string.format("%s_%d",type,location)] or 0
end

-- 获得阵形加成
function FormationManager:getAddition(id,type)
	return dbMgr.formations[id]["add_" .. type] or 0
end

-- 获得布置阵形人数
function FormationManager:getSetRoles(id)
	return dbMgr.formations[id].setroles
end

-- 获得阵形最少人数
function FormationManager:getMinRoles(id)
	return dbMgr.formations[id].minroles
end

-- 地图可用的
function FormationManager:isMapUsable(id)
	return dbMgr.formations[id].map
end

-- 战斗可用的
function FormationManager:isBattleUsable(id)
	return dbMgr.formations[id].battle
end

-- 获得脚本
function FormationManager:getScript(id,type)
	return dbMgr.formations[id]["script_" .. type]
end

-- 获得参数
function FormationManager:getParam(id,type)
	return dbMgr.formations[id]["param_" .. type]
end

-- 获得音效
function FormationManager:getSE(id,type)
	return dbMgr.formations[id]["se_" .. type]
end

-- 获得特效
function FormationManager:getEffect(id,type)
	return dbMgr.formations[id]["effect_" .. type]
end

return FormationManager
