--[[
	列表窗口
--]]
local THIS_MODULE = ...

local TableWindow = class("TableWindow", cc.Node, 
	require("app.main.modules.uiwidget.UIWidgetBase"),
	import("._TableItem"))

-- 类扩展构造
function TableWindow:clsctor(config)
	table.merge(self,config)
end

-- 构造函数
function TableWindow:ctor(size,anchor,config,params)
	self._size = size
	self._anchor = anchor
	if config then
		table.merge(self,config)
	end

	-- 安装背景
	if self.background then
		local bgconf = self.background
		local resnode = cc.CSLoader:createNode(bgconf.csb)
		self:addChild(resnode)
		self:bindUI(resnode,bgconf.widgets,bgconf.bindings,true)
		if bgconf.context then
			self._bgcontext = self[bgconf.context]
		end
	end

	-- 列表面板
	self._stencil = cc.DrawNode:create()
	local shownode = cc.ClippingNode:create(self._stencil)
	self._showpanel = cc.Layer:create()
	shownode:setPosition(self.bgborder[1] + self.tbborder[1],
		self.bgborder[4] + self.tbborder[4])
	shownode:addChild(self._showpanel)
	self:addChild(shownode)

	-- 可选择光标
	if self.selectable then
		self._cursor = display.newSprite(self.cursorimg)
		self._csrsize = self._cursor:getContentSize()
		self._cursor:setAnchorPoint(cc.p(0,0.5))
		self._showpanel:addChild(self._cursor)
		self._cursor:setVisible(false)
	end

	-- 参数
	self._listener = {}
	self._pagecap = self.itemcolumns * self.itemrows
	self:changeSize(size)
	
	-- 更新参数
	self:updateParams(params)
end

-- 改变窗口大小
function TableWindow:changeSize(size)
	self._size = size
	self:setContentSize(size)
	if self._bgcontext then
		self._bgcontext:setContentSize(size)
	end
	self._bounds = cc.rect(self.bgborder[1]+self.tbborder[1],self.bgborder[3]+self.tbborder[3],
		size.width-self.bgborder[1]-self.bgborder[2]-self.tbborder[1]-self.tbborder[2],
		size.height-self.bgborder[3]-self.bgborder[4]-self.tbborder[3]-self.tbborder[4])
	self._stencil:clear()
	self._stencil:drawSolidRect(cc.p(0,0),cc.p(self._bounds.width,self._bounds.height),cc.c4f(1,0,0,1))
end

--[[
	更新参数
	params  
		items			项目表
		next			下一个
		cancel			拒绝
		hidecsrf		隐藏开始光标
		pageindex		页索引
		selindex		选择索引
		listener		监听器
			trigger		触发
			change		改变
			cancel		拒绝
			overup		向上
			overdown	向下
			overleft	向左
			overright	向右
]]
function TableWindow:updateParams(params)
	self._params = params or {}

	self._tabitems = self._params.items or {}
	self._nextitem = self._params.next or {}
	self._cancelitem = self._params.cancel or {}
	self._pageindex = self._params.pageindex or 1
	self._selindex = self._params.selindex or 1
	self._hidecsrf = self._params.hidecsrf
	
	self._nextitem.onTrigger = function()
		self:nextPageItems()
	end
	self._cancelitem.onTrigger = function()
		self:cancelSelect()
	end
	
	if self._params.listener then
		self:setListener(self._params.listener)
	end
	self:setupPageItems()
end

-- 设置监听器
function TableWindow:setListener(listener)
	self._listener = listener or {}
end

-- 安装页项
function TableWindow:setupPageItems()
	self:clearPageItems()
	if #self._tabitems > 0 then
		self._morepage = (#self._tabitems > self._pagecap)
		if self._morepage then
			self._pagemax = self._pagecap - 1
		else
			self._pagemax = #self._tabitems
		end
		
		self._pagesize = self._pagemax
		
		self:showPageItems()
	else
		self._selindex = nil
		self:updateCursor()
	end
end

-- 显示页项
function TableWindow:showPageItems()
	self:clearPageItems()

	-- 调整窗口大小
	local itemmax = self._pagecap
	if self.adaptrows then  -- 适配行数
		local itemsize = self._pagesize
		if self._morepage then
			itemsize = itemsize + 1
		end
		local itemrows = math.floor((itemsize + self.itemcolumns - 1)/self.itemcolumns)
		itemmax =  itemrows * self.itemcolumns
		self._size.height = self.bgborder[3] + self.bgborder[4] + self.tbborder[3] + self.tbborder[4] +
			(self.itemsize[2] + self.itemspace[2]) * itemrows - self.itemspace[2]
		self:changeSize(self._size)
	end

	-- 添加选择项
	local itemindex = 0
	while itemindex < self._pagesize do
		self:addPageItem(self._tabitems[self._pageindex + itemindex], itemindex)
		itemindex = itemindex + 1
	end
   
	-- 添加翻页项
	if self._morepage then
		local cancelmax = itemmax
		if self._morepage then
			cancelmax = cancelmax - 1
		end
		while itemindex < cancelmax do 
			self:addPageItem(self._cancelitem, itemindex)
			itemindex = itemindex + 1
		end
		self:addPageItem(self._nextitem, itemindex)
	end

	if self._hidecsrf then
		self._hidecsrf = false
		self:hideCursor()
	else
		self:updateCursor()
	end
end

-- 显示下一页项
function TableWindow:nextPageItems()
	local nextindex = self._pageindex + self._pagesize
	local nextsize = self._pagemax
	if nextindex > #self._tabitems then
		nextindex = 1
	else
		nextsize = #self._tabitems - nextindex + 1
		if nextsize > self._pagemax then
			nextsize = self._pagemax
		end
	end

	self._pageindex = nextindex
	self._pagesize = nextsize
	self._selindex = -1

	self:showPageItems()
end

-- 清除页项
function TableWindow:clearPageItems()
	if self._pageitems then
		for _,item in pairs(self._pageitems) do 
			item.widget:removeFromParent()
		end
	end
	self._pageitems = {}
end

-- 添加页项
function TableWindow:addPageItem(itemparams,itemindex)
	local widget = uiwdgMgr:createObject(self.itemwidget.type,
		cc.size(self.itemsize[1],self.itemsize[2]),
		cc.p(self.itemanchor[1],self.itemanchor[2]), self.itemwidget.config, itemparams)
	widget:setAnchorPoint(cc.p(0,0.5))
	local itempos = cc.p(((self.selectable and self._csrsize.width or 0) + self.itemsize[1] + 
		self.itemspace[1]) * (itemindex % self.itemcolumns), self._bounds.height - (self.itemsize[2] + 
		self.itemspace[2]) * math.floor(itemindex / self.itemcolumns))
	widget:setPosition(cc.p(itempos.x + (self.selectable and self._csrsize.width or 0),
		itempos.y - self.itemsize[2] / 2))
	self._showpanel:addChild(widget)

	-- 添加项到页
	self._pageitems[itemindex + 1] = {
		widget = widget,
		params = itemparams,
		cursor = cc.p(itempos.x, itempos.y- self.itemsize[2] / 2)
	}
end

-- 获得项目数量
function TableWindow:getItemCount()
	return self._tabitems and #self._tabitems or 0
end

-- 获得项的行数
function TableWindow:getItemRows()
	return self.itemrows
end

-- 设置指定行数的大小
function TableWindow:sizeToRows(rows)
	self.itemrows = rows
	self._pagecap = self.itemcolumns * self.itemrows
	self._size.height = self.bgborder[3] + self.bgborder[4] + self.tbborder[3] + self.tbborder[4] +
		(self.itemsize[2] + self.itemspace[2]) * self.itemrows - self.itemspace[2]
	self:changeSize(self._size)
end

-- 获得项的列数
function TableWindow:getItemColumns()
	return self.itemcolumns
end

-- 设置指定列数的大小
function TableWindow:sizeToColumns(columns)
	self.itemcolumns = columns
	self._pagecap = self.itemcolumns * self.itemrows
	self._size.width = self.bgborder[1] + self.bgborder[2] + self.tbborder[1] + self.tbborder[1] +
		(self.itemsize[1] + self.itemspace[1]) * self.itemcolumns - self.itemspace[1]
	self:changeSize(self._size)
end

-- 获得页索引
function TableWindow:getPageIndex()
	return self._pageindex
end

-- 获得选择索引
function TableWindow:getSelectIndex()
	return self._selindex
end

-- 隐藏光标
function TableWindow:hideCursor()
	self._cursor:stopAllActions()
	self._cursor:setVisible(false)
end

-- 刷新光标
function TableWindow:updateCursor()
	if self.selectable then
		self:hideCursor()
		if self._selindex then
			if self._selindex <= 0 then
				self._selindex = #self._pageitems
			end
			local selectitem = self._pageitems[self._selindex]
			if selectitem then
				if self._controlable or self.markselect then
					self._cursor:setPosition(selectitem.cursor)
					self._cursor:setVisible(true)
				end
				if self._controlable then
					self._cursor:runAction(cc.Sequence:create(
						cc.Show:create(),cc.DelayTime:create(self.cursordelay),
						cc.CallFunc:create(function() 
							self._cursor:runAction(cc.RepeatForever:create(cc.Blink:create(1,self.cursorrate)))
						end)))
				end
			end 
		end
	end
end

-- 使能控制功能
function TableWindow:enableControl(enable)
	self._controlable = enable
	self:updateCursor()
end

-- 标记选择
function TableWindow:markSelect(marksel)
	self.markselect = marksel
	self:updateCursor()
end

-- 改变选择项(索引 1为第一，小于1为最后)或(坐标行，列)
function TableWindow:changeSelect(index1,index2)
	if self.selectable then
		if index2 == nil then
			self._selindex = index1
		else
			if index1 <= 0 then
				index1 = math.floor(#self._pageitems / self.itemcolumns)
			end
			if index2 <= 0 then
				index2 = self.itemcolumns
			end
			self._selindex = (index1 - 1) * self.itemcolumns + index2
		end
		
		self:updateCursor()
		if self._listener.change then
			self._listener.change(self._pageitems[self._selindex].target,self._selindex)
		end
	end
end

-- 移动选择项
function TableWindow:moveSelect(direct)
	if not self._selindex then return end
	audioMgr:playSE(self.changesound)
	local oldselect = self._selindex
	local itemindex = self._selindex - 1
	local indexrows = math.floor(itemindex / self.itemcolumns)
	local indexcolumns = itemindex % self.itemcolumns
	local rowsmax = math.ceil(#self._pageitems / self.itemcolumns)

	if direct == "UP" then
		if indexrows > 0 then
			indexrows = indexrows - 1
		else
			if self._listener.overup then
				return self._listener.overup()
			elseif self.loopYsel then
				indexrows = rowsmax - 1
				if (indexrows > 0) and 
					((indexrows * self.itemcolumns + indexcolumns + 1) > #self._tabitems) then   -- 超过选择
					indexrows = indexrows - 1
				end
			end
		end
	elseif direct == "DOWN" then
		if indexrows < rowsmax - 1 then
			indexrows = indexrows + 1
			if (indexrows > 0) and 
				((indexrows * self.itemcolumns + indexcolumns + 1) > #self._tabitems) then   -- 超过选择
				indexrows = 0
			end
		else
			if self._listener.overdown then
				return self._listener.overdown()
			elseif self.loopYsel then
				indexrows = 0
			end
		end
	elseif direct == "LEFT" then
		if indexcolumns > 0 then
			indexcolumns = indexcolumns - 1
		else
			if self._listener.overleft then
				return self._listener.overleft()
			elseif self.loopXsel then
				indexcolumns = self.itemcolumns - 1
			end
		end
	elseif direct == "RIGHT" then
		if indexcolumns < self.itemcolumns - 1 then
			indexcolumns = indexcolumns + 1
			if (indexrows > 0) and 
				((indexrows * self.itemcolumns + indexcolumns + 1) > #self._tabitems) then   -- 超过选择
				indexrows = indexrows - 1
			end
		else
			if self._listener.overright then
				return self._listener.overright()
			elseif self.loopXsel then
				indexcolumns = 0
			end
		end
	end

	self._selindex = indexrows * self.itemcolumns + indexcolumns + 1
	self:updateCursor()
	if self._listener.change and oldselect ~= self._selindex then
		self._listener.change(self._pageitems[self._selindex].target,self._selindex)
	end
end

-- 触发选择操作
function TableWindow:triggerSelect()
	if not self._selindex then 
		return self:cancelSelect()
	end
	audioMgr:playSE(self.selectsound)
	local item = self._pageitems[self._selindex]
	if item then
		local itemparams = item.params
		if item.widget:onTrigger(itemparams) then return end
		if itemparams.onTrigger then
			return itemparams.onTrigger(itemparams, self._selindex, self._selindex+self._pageindex-1)
		end
		if self._listener.trigger then
			return self._listener.trigger(itemparams, self._selindex, self._selindex+self._pageindex-1)
		end
	end
end

-- 终止选择操作
function TableWindow:cancelSelect()
	if self._listener.cancel then
		self._listener.cancel()
	end
end

-- 获得焦点回调
function TableWindow:onGetFocus() 
	self:enableControl(true)
end

-- 失去焦点回调
function TableWindow:onLostFocus() 
	self:enableControl(false)
end

-- 当消息窗口输入键时
function TableWindow:onControlKey(keyvalue)
	if self.selectable then
		if keyvalue == ctrlMgr.KEY_UP then
			self:moveSelect("UP")
		elseif keyvalue == ctrlMgr.KEY_DOWN then
			self:moveSelect("DOWN")
		elseif keyvalue == ctrlMgr.KEY_LEFT then
			self:moveSelect("LEFT")
		elseif keyvalue == ctrlMgr.KEY_RIGHT then
			self:moveSelect("RIGHT")
		elseif keyvalue == ctrlMgr.KEY_A then
			self:triggerSelect()
		elseif keyvalue == ctrlMgr.KEY_B then
			self:cancelSelect()
		end
	end
end

return TableWindow
