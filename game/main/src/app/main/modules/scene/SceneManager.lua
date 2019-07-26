--[[
	场景管理器
--]]
local THIS_MODULE = ...
local C_LOGTAG = "SceneManager"

-- 模块名
local C_MODULE_NAME = "__Scene__"

-- 注册模块元数据配置
metaMgr:registerModule(C_MODULE_NAME, "src/scenes")

local SceneManager = class("SceneManager")

-- 获得单例对象
local instance = nil
function SceneManager:getInstance()
	if instance == nil then
		instance = SceneManager:create()
	end
	return instance
end

-- 构造函数
function SceneManager:ctor()
	self._transition = {}		-- 切换特效
	self._curscene = nil	 	-- 当前场景
end

-- 获得当前场景
function SceneManager:getCurrentScene()
	return self._curscene
end

-- 释放元数据
function SceneManager:releaseMetas()
	metaMgr:releaseMetas(C_MODULE_NAME)
end

--[[
	设置切换特效
	transition  
		method	  方式
		time		时间
		more		更多参数
]]
function SceneManager:setTransition(transition)
	self._transition = transition or {}
end

-- 切换场景
function SceneManager:switchScene(sclass, ...)
	logMgr:info(C_LOGTAG, "switch to scene : %s", sclass)

	local scenemeta = metaMgr:getMeta(C_MODULE_NAME, sclass)
	assert(scenemeta, string.format("scene %s not found", sclass))

	local args = { ... }
	local function _showNewScene()
		scenemeta:create(function (scene)
			assert(scene, string.format("scene %s create failure", sclass))
			self._curscene = scene
			self._curscene:showWithScene(self._transition.method, self._transition.time, self._transition.more)
		end,unpack(args))
	end

	if not self._curscene then
		_showNewScene()
	else
		self._curscene:dtor(function ()
			self._curscene = nil
			_showNewScene()
		end)
	end
end

-- 输出管理器当前状态
function SceneManager:dump()
	metaMgr:dumpModule(C_MODULE_NAME)
end

return SceneManager
