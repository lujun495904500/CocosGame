--[[
	UI可绑定接口
--]]
local THIS_MODULE = ...

local UIBindable = class("UIBindable")

--[[
	绑定UI
	rootnode	根节点
	widgets	 组件
	bindings	变量
	exports	 导出名称
]] 
function UIBindable:bindUI(rootnode, widgets, bindings, exports)
	self._uis = {}

	if rootnode then
		-- 绑定组件
		if widgets then
			for wgname,wgconf in pairs(widgets) do
				local layout = rootnode:getChildByPath(wgconf.source)
				local wgsize = layout:getContentSize()
				local wganchor = layout:getAnchorPoint()
				local widget = uiwdgMgr:createObject(wgconf.type,clone(wgsize),clone(wganchor),
					wgconf.config,wgconf.params)
				widget:setAnchorPoint(wganchor)
				widget:setPosition(cc.p(wganchor.x*wgsize.width,wganchor.y*wgsize.height))
				layout:addChild(widget)
				self._uis[wgname] = widget
			end
		end

		-- 绑定变量
		if bindings then
			for vname,nodename in pairs(bindings) do
				local bindnode = rootnode:getChildByPath(nodename)
				self._uis[vname] = bindnode
			end
		end

		-- 导出名称
		if exports == true then
			table.merge(self,self._uis)
		elseif type(exports) == "table" then
			for epname,vname in pairs(exports) do
				self[epname] = self._uis[vname]
			end
		end
	end
end

-- 获得指定的UI组件
function UIBindable:getUI(uname)
	return self._uis[uname]
end

-- 获得UI组件表
function UIBindable:getUIs(unames)
	local uis = {}
	if unames then
		for i,uname in ipairs(unames) do
			uis[i] = self:getUI(uname)
		end
	end
	return uis
end

return UIBindable
