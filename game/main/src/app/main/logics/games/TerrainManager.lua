--[[
	地形管理器
--]]
local THIS_MODULE = ...

-- 地形索引路径
local C_TERRAIN_IPATH = "db/terrains"

local TerrainManager = class("TerrainManager", require("app.main.modules.index.IndexListener"))

-- 获得单例对象
local instance = nil
function TerrainManager:getInstance()
	if instance == nil then
		instance = TerrainManager:create()
		indexMgr:addListener(instance, { C_TERRAIN_IPATH })
	end
	return instance
end

-- 构造函数
function TerrainManager:ctor()
	self._terrains = {}		-- 地形表
	self._valuesmap = {}	-- 地形值映射表
end

-------------------------IndexListener-------------------------
-- 清空索引
function TerrainManager:onIndexesRemoved()
	self:releaseTerrains()
	self:onIndexesLoaded(C_TERRAIN_IPATH, indexMgr:getIndex(C_TERRAIN_IPATH))
end

-- 加载索引路径
function TerrainManager:onIndexesLoaded(ipath, ivalue)
	if ivalue then
		if ipath == C_TERRAIN_IPATH then
			for _,dbfile in pairs(ivalue) do
				for terrain,config in pairs(indexMgr:readJson(dbfile)) do
					self:registerTerrain(terrain, config)
				end
			end
		end
	end
end
-------------------------IndexListener-------------------------

-- 注册地形
function TerrainManager:registerTerrain(terrain,config)
	self._terrains[terrain] = config
	self._valuesmap[config.value] = config
end

-- 释放地形
function TerrainManager:releaseTerrains()
	self._terrains = {}
	self._valuesmap = {}
end

-- 获得地形值
function TerrainManager:getValue(terrain)
	return self._terrains[terrain].value
end

-- 获得地形脚本
function TerrainManager:getScript(terrain)
	local config = self._terrains[terrain]
	if config and not config.sobject and config.script then
		config.sobject = scriptMgr:createObject(config.script,config)
	end
	return config and config.sobject or nil
end

-- 根据地形值获得脚本
function TerrainManager:getScriptByValue(value)
	local config = self._valuesmap[value]
	if config and not config.sobject and config.script then
		config.sobject = scriptMgr:createObject(config.script,config)
	end
	return config and config.sobject or nil
end

-- 输出管理器当前状态
function TerrainManager:dump()
	dump(self._terrains, "TerrainManager", 3)
end

return TerrainManager
