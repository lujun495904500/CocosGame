--[[
	索引监听器
--]]

local IndexListener = class("IndexListener")

-- 回调:索引加载
function IndexListener:onIndexesLoaded(ipath, ivalue) end

-- 回调:索引移除(可能非清空)
function IndexListener:onIndexesRemoved() end

return IndexListener
