--[[
	剧本基类
]]

local PlayBase = class("PlayBase", require("app.main.modules.meta.MetaBase"))

-- 构造函数
function PlayBase:ctor(play)
	self._play = play
end

-- 执行函数
function PlayBase:execute(onComplete, ...) end

-- 获得剧本名称
function PlayBase:getName()
	return self:getMetaType()
end

-- 获得前置剧本
function PlayBase:getPrefix()
	return self._play.prefix
end

-- 获得后续剧本
function PlayBase:getFollows()
	return self._play.follows
end

return PlayBase
