--[[
	技能管理器
--]]
local THIS_MODULE = ...

local SkillManager = class("SkillManager")

-- 获得单例对象
local instance = nil
function SkillManager:getInstance()
	if instance == nil then
		instance = SkillManager:create()
	end
	return instance
end

-- 获得技能配置
function SkillManager:getConfig(id)
	return dbMgr.skills[id]
end

-- 获得技能名
function SkillManager:getName(id)
	return dbMgr.skills[id].name
end

-- 获得技能类型
function SkillManager:getType(id)
	return dbMgr.skills[id].type
end

-- 技能使用的谋略点
function SkillManager:getSP(id)
	return dbMgr.skills[id].sp
end

-- 技能习得等级
function SkillManager:getLevel(id)
	return dbMgr.skills[id].level
end

-- 获得威力
function SkillManager:getPower(id)
	return dbMgr.skills[id].power
end

-- 地图可用的
function SkillManager:isMapUsable(id)
	return dbMgr.skills[id].map
end

-- 战斗可用的
function SkillManager:isBattleUsable(id)
	return dbMgr.skills[id].battle
end

-- 获得脚本
function SkillManager:getScript(id,type)
	return dbMgr.skills[id]["script_" .. type]
end

-- 获得参数
function SkillManager:getParam(id,type)
	return dbMgr.skills[id]["param_" .. type]
end

-- 获得音效
function SkillManager:getSE(id,type)
	return dbMgr.skills[id]["se_" .. type]
end

-- 获得特效
function SkillManager:getEffect(id,type)
	return dbMgr.skills[id]["effect_" .. type]
end

return SkillManager
