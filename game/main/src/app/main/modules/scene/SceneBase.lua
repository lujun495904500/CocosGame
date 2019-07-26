--[[
	场景基类
]]
local SceneBase = class("SceneBase", cc.Node, 
	require("app.main.modules.control.ControlBase"), 
	require("app.main.modules.meta.MetaBase"))

------------------------------------------

-- 场景开始
function SceneBase:onBegin() end

------------------------------------------

-- 析构场景 
function SceneBase:dtor(onComplete)
	if onComplete then onComplete() end
end

-- 安装场景
function SceneBase:setup()
	self:registerScriptHandler(function(state)
		if state == "enterTransitionFinish" then
			ctrlMgr:clearPressed()
			ctrlMgr:setTarget(self)
			self:onBegin()
		end
	end)
end

-- 删除场景 
function SceneBase:delete()
	self:unregisterScriptHandler()
	ctrlMgr:setTarget(nil)
end

-- 显示场景
function SceneBase:showWithScene(transition, time, more)
	self:setVisible(true)
	local scene = display.newScene(self.name_)
	scene:addChild(self)
	display.runScene(scene, transition, time, more)
	return self
end

-- 获得焦点
function SceneBase:onGetFocus() 
	self._active = true
end

-- 失去焦点
function SceneBase:onLostFocus()
	self._active = false
end

-- 检查场景是否激活
function SceneBase:isActive()
	return self._active
end

return SceneBase
