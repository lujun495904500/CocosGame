--[[
	Demo 剧本
]]
local THIS_MODULE = ...

-- 切换特效
local C_TRANSITION = {
	method = "FADE",
	time = 0.4,
}
local Play = class("Play", require("app.main.modules.play.PlayBase"),
	require("app.main.logics.plays.MapSetup"))

-- 执行函数
function Play:execute(onComplete,type,...)
	if type == "PLAY" then
		sceneMgr:setTransition(C_TRANSITION)
		if not archMgr:checkEventPoint(unpack(tools:parseEPoint("SHOW_PREFACE"))) then
			return sceneMgr:switchScene("DemoScene")
		else
			return sceneMgr:switchScene("MapScene",gameMgr:getMapEnv("archivemap"))
			--[[
			sceneMgr:switchScene("MapScene",{
				mapname = "town_xuzhou",
				inpos = "p_enter",
				inmethod = "LINE",
				inface = "UP",
			})
			--]]
		end
	elseif type == "SETUPMAP" then
		return self:setupMap(onComplete,...)
	elseif type == "DELETEMAP" then
		return self:deleteMap(onComplete,...)
	end
	if onComplete then onComplete() end
end

-- 安装地图
function Play:setupMap(onComplete,map)
	self:setupMapConfigs(onComplete,map,import(".MapObjects",THIS_MODULE))
end

-- 删除地图
function Play:deleteMap(onComplete,map)
	if onComplete then onComplete() end
end

return Play
