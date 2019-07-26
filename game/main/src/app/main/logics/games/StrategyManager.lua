--[[
	策略管理器
--]]
local THIS_MODULE = ...

local StrategyManager = class("StrategyManager")

-- 获得单例对象
local instance = nil
function StrategyManager:getInstance()
	if instance == nil then
		instance = StrategyManager:create()
	end
	return instance
end

-- 获得配置
function StrategyManager:getConfig(id)
	return dbMgr.strategys[id]
end

-- 获得名称
function StrategyManager:getName(id)
	return dbMgr.strategys[id].name
end

-- 使用的谋略点
function StrategyManager:getSP(id)
	return dbMgr.strategys[id].sp
end

-- 习得等级
function StrategyManager:getLevel(id)
	return dbMgr.strategys[id].level
end

-- 地图可用的
function StrategyManager:isMapUsable(id)
	return dbMgr.strategys[id].map
end

-- 战斗可用的
function StrategyManager:isBattleUsable(id)
	return dbMgr.strategys[id].battle
end

-- 获得脚本
function StrategyManager:getScript(id,type)
	return dbMgr.strategys[id]["script_" .. type]
end

-- 获得参数
function StrategyManager:getParam(id,type)
	return dbMgr.strategys[id]["param_" .. type]
end

-- 获得音效
function StrategyManager:getSE(id,type)
	return dbMgr.strategys[id]["se_" .. type]
end

-- 获得特效
function StrategyManager:getEffect(id,type)
	return dbMgr.strategys[id]["effect_" .. type]
end

return StrategyManager
