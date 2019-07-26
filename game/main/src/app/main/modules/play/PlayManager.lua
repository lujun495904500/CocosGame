--[[
	剧本管理器
--]]
local THIS_MODULE = ...

-- 模块名
local C_MODULE_NAME = "__Play__"

-- 注册模块元数据配置
metaMgr:registerModule(C_MODULE_NAME,"src/plays/")

local PlayManager = class("PlayManager")

-- 获得单例对象
local instance = nil
function PlayManager:getInstance()
	if instance == nil then
		instance = PlayManager:create()
	end
	return instance
end

-- 构造函数
function PlayManager:ctor()
	self._curplay = nil		 	-- 当前剧本
	self._curobject = nil	  	-- 当前剧本对象
end

-- 构建剧本
function PlayManager:buildPlays()
	self._plays = gameConfig.plays
	for _,pname in ipairs(table.keys(self._plays)) do
		local play = self._plays[pname]
		if play.prefix then
			local preplay = self._plays[play.prefix]
			if preplay then
				preplay.follows = preplay.follows or {}
				preplay.follows[#preplay.follows + 1] = pname
			end
		end
	end
end

-- 设置当前剧本
function PlayManager:setCurrentPlay(play)
	self._curplay = play
	self._curobject = nil
end

-- 获得当前剧本
function PlayManager:getCurrentPlay()
	return self._curplay
end

-- 执行当前剧本
function PlayManager:doCurrentPlay(onComplete, ...)
	if not self._curobject then
		self._curobject = self:createObject(self._curplay)
	end
	self._curobject:execute(onComplete, ...)
end

-- 获得前置剧本
function PlayManager:getPrefixPlay(pname)
	local play = self._plays[pname or self._curplay]
	return play and play.prefix
end

-- 获得后续剧本
function PlayManager:getFollowPlays(pname)
	local play = self._plays[pname or self._curplay]
	return play and play.follows
end

-- 获得剧本依赖包
function PlayManager:getPlayPacks(pname)
	local packs = {}

	local play = self._plays[pname or self._curplay]
	while play do
		table.insert(packs,1,play.pack)
		play = play.prefix and self._plays[play.prefix] or nil
	end
	
	return table.merge_array(PACK.BASES, packs)
end

-- 注册剧本
function PlayManager:registerPlay(pname, play)
	metaMgr:registerMeta(C_MODULE_NAME, pname, play)
end

-- 释放剧本
function PlayManager:releasePlays()
	metaMgr:releaseMetas(C_MODULE_NAME)
end

-- 获得剧本
function PlayManager:getPlay(pname)
	return metaMgr:getMeta(C_MODULE_NAME, pname)
end

-- 脚本调用
local function callScript(instance,...)
	instance:execute(...)
end

-- 创建脚本对象
function PlayManager:createObject(pname,...)
	local playobj = metaMgr:createObject(C_MODULE_NAME, pname, self._plays[pname], ...)
	if playobj then
		getmetatable(playobj).__call = callScript
	end
	return playobj
end

-- 输出管理器当前状态
function PlayManager:dump()
	metaMgr:dumpModule(C_MODULE_NAME)
end

return PlayManager
