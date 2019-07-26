--[[	默认包加载器
]]
local THIS_MODULE = ...

local PackLoader = class("PackLoader")

-- 构造包加载器
function PackLoader:ctor(packname)
	self._packname = packname
end

-- 获得包名
function PackLoader:getPackName()
	return self._packname
end

-- 包加载调用
function PackLoader:onLoad()
	-- 索引配置
	local indexconf = "res/" .. self._packname .. "/indexes.json"
	if fileUtils:isFileExist(indexconf) then
		indexMgr:loadIndexFileConfig(indexconf, self._packname)
	end
end

-- 包释放调用
function PackLoader:onRelease()
	-- 索引配置
	indexMgr:removeIndexNode(self._packname)
end

return PackLoader
