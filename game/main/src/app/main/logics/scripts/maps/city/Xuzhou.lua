--[[
	徐州
--]]

local Xuzhou = class("Xuzhou", require("app.main.modules.script.ScriptBase"))

-- 初始化地图
function Xuzhou:initMap(scene)
	print("初始化 地图")
end

-- 释放地图
function Xuzhou:releaseMap(scene)
	print("释放 地图")
end

return Xuzhou
