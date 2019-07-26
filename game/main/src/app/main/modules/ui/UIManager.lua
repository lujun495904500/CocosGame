--[[
	UI管理器
--]]
local THIS_MODULE = ...

-- 模块名
local C_MODULE_NAME = "__UI__"

-- 注册模块元数据配置
metaMgr:registerModule(C_MODULE_NAME, "src/uis/", nil, "res/uis/frames/")

local UIManager = class("UIManager", cc.Layer)

-- 获得单例对象
local instance = nil
function UIManager:getInstance()
	if instance == nil then
		instance = UIManager:create()
		instance:retain()
	end
	return instance
end

-- 构造函数
function UIManager:ctor()
	self._zorder  = 1		 	-- z 序号
	self._openuis = {}	   		-- UI打开表
	self._frontui = nil	  		-- 最前面的UI
	self._ocdoing = false		-- 正在打开或关闭操作
	self._octasks = {}	   		-- 打开或关闭任务组
end

-- 注册元数据
function UIManager:registerMeta(type, meta)
	metaMgr:registerMeta(C_MODULE_NAME, type, meta)
end

-- 释放元数据
function UIManager:releaseMetas()
	metaMgr:releaseMetas(C_MODULE_NAME)
end

-- 释放UI
function UIManager:releaseUIs(preload)
	metaMgr:releaseObjects(C_MODULE_NAME, preload)
end

-- 附着UI
function UIManager:attach(parent, order)
	self:detach()
	parent:addChild(self, order or 0)
	self._parent = parent
end

-- 分离UI
function UIManager:detach()
	self._parent = nil
	self:removeFromParent()
	self:closeAll()
end

-- 添加打开或关闭任务
function UIManager:addOCTask(task)
	self._octasks[task] = task
end

-- 执行打开或关闭任务
function UIManager:exeOCTask()
	local task = next(self._octasks)
	if task then
		self._octasks[task] = nil
		task()
	end
end

-- 把UI放置到最前面
function UIManager:setFront(ui)
	if ui then
		if ui ~= self._frontui then
			local zorder = ui:getFixedZ()
			if not zorder then
				self._zorder = self._zorder + 1
				zorder = self._zorder
			end
			ui:setLocalZOrder(zorder)
			if not self._frontui or self._frontui:getLocalZOrder() < zorder then
				self._frontui = ui
				ctrlMgr:setTarget(ui)
			end
		end
	else
		self._frontui = nil
		ctrlMgr:setTarget(self._parent)
	end
end

-- 把UI放置到最前面
function UIManager:setFrontByName(uiname)
	if self._ocdoing then
		return self:addOCTask(function() self:setFrontByName(uiname) end)
	else
		local ui = self._openuis[uiname]
		if ui then
			self:setFront(ui)
		end
	end
end

-- 打开UI
function UIManager:openUI(uiname,...)
	if self._ocdoing then
		local args = { ... }
		return self:addOCTask(function() self:openUI(uiname,unpack(args)) end)
	end
	self._ocdoing = true

	local ui = self._openuis[uiname]
	if ui == nil then
		ui = self:getUI(uiname)
		assert(ui, string.format("UI %s not found", uiname))
		self:addChild(ui)
		self._openuis[uiname] = ui
	end
	ui:OnOpen(...)
	self:setFront(ui)

	self._ocdoing = false
	self:exeOCTask()

	return ui
end

-- 打开UI数组
function UIManager:openUIs(uiparams,onComplete)
	local uis = {}
	for i,uiparam in ipairs(uiparams) do
		uis[i] = self:openUI(unpack(uiparam))
	end
	if onComplete then onComplete(unpack(uis)) end
end

-- 关闭UI
function UIManager:closeUI(uiname)
	if self._ocdoing then
		return self:addOCTask(function() self:closeUI(uiname) end)
	end
	self._ocdoing = true

	local ui = self._openuis[uiname]
	if ui then
		if ui == self._frontui then
			local nfui = nil
			for _,opui in pairs(self._openuis) do 
				if self._frontui ~= opui and 
					(nfui == nil or nfui:getLocalZOrder() < opui:getLocalZOrder()) then
					nfui = opui
				end
			end
			self:setFront(nfui)
		end
		ui:OnClose()
		self._openuis[uiname] = nil
		self:removeChild(ui,false)
	end
	
	self._ocdoing = false
	self:exeOCTask()
end

-- 关闭UI数组
function UIManager:closeUIs(...)
	for _,uiname in ipairs({...}) do
		self:closeUI(uiname)
	end
end

-- 单独打开UI
function UIManager:openOnly(uiname,...)
	self:openUI(uiname,...)
	self:closeAll(uiname)
end

-- 关闭除指定之外所有UI
function UIManager:closeAll(except)
	for _,uiname in ipairs(table.keys(self._openuis)) do
		if uiname ~= except then
			self:closeUI(uiname)
		end
	end
end

-- 获得UI
function UIManager:getUI(uiname)
	return metaMgr:getObject(C_MODULE_NAME,uiname)
end

-- 预加载UI
function UIManager:preloadUI(uiname)
	metaMgr:preloadObject(C_MODULE_NAME,uiname)
end

-- 获取所有UI
function UIManager:getAllUIs()
	return metaMgr:getAllObjects(C_MODULE_NAME)
end

-- 加载所有UI
function UIManager:loadAllUIs()
	metaMgr:loadAllObjects(C_MODULE_NAME)
end

-- 输出管理器当前状态
function UIManager:dump()
	metaMgr:dumpModule(C_MODULE_NAME,{
		_zorder = self._zorder,
		_openuis = self._openuis,
		_frontui = self._frontui,
	})
end

return UIManager
