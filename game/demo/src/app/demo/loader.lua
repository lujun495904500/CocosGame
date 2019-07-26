--[[
	包加载器测试
]]
local C_LOGTAG = "TestLoader"

local PackLoader = require("app.main.modules.pack.PackLoader")
local TestLoader = class("TestLoader", PackLoader)

-- 包加载调用
function TestLoader:onLoad()
	logMgr:info(C_LOGTAG, "TestLoader %s ON LOAD",self:getPackName())
	PackLoader.onLoad(self)
end

-- 包释放调用
function TestLoader:onRelease()
	PackLoader.onRelease(self)
	logMgr:info(C_LOGTAG, "TestLoader %s ON RELEASE",self:getPackName())
end

return TestLoader
