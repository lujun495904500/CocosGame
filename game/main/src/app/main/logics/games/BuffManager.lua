--[[
	BUFF管理器
--]]
local THIS_MODULE = ...

local BuffManager = class("BuffManager")

-- 获得单例对象
local instance = nil
function BuffManager:getInstance()
	if instance == nil then
		instance = BuffManager:create()
	end
	return instance
end

-- 获得BUFF配置
function BuffManager:getConfig(id)
	return dbMgr.buffs[id]
end

-- 获得BUFF名称
function BuffManager:getName(id)
	return dbMgr.buffs[id].name
end

-- 地图可使用
function BuffManager:isMapUsable(id)
	return dbMgr.buffs[id].map
end

-- 战场可使用
function BuffManager:isBattleUsable(id)
	return dbMgr.buffs[id].battle
end

-- 正面效果
function BuffManager:isPositive(id)
	return dbMgr.buffs[id].positive
end

-- 获得BUFF脚本
function BuffManager:getScript(id)
	return dbMgr.buffs[id].script
end

-- 获得BUFF参数
function BuffManager:getParam(id)
	return dbMgr.buffs[id].param
end

return BuffManager
