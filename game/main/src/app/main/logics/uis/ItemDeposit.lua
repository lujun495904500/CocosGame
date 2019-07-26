--[[
	物品寄存
]]
local THIS_MODULE = ...

local ItemDeposit = class("ItemDeposit", require("app.main.modules.ui.FrameBase"), 
	require("app.main.modules.uiwidget.UIWidgetFocusable"))

--[[
	构造函数
	config
		params		额外参数
		name		名称
		csb			csb文件
		widgets		组件表
		bindings	绑定表
]]
function ItemDeposit:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function ItemDeposit:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function ItemDeposit:reinitWidgets()
	self.wg_rolelist:setVisible(false)
	self.wg_items:setVisible(false)
	self.wg_deposits:setVisible(false)
	self.wg_message:setVisible(false)
end

--[[
	打开窗口
	team	物品队伍
	type	D/G 寄存/接收
]]
function ItemDeposit:OnOpen(team,type)
	self:reinitWidgets()
	
	if type == "D" then 
		local selectRole = nil

		selectRole = function()
			self:onSelectRole(team,function (result,role)
				if result then
					if role:getLuggageCount() <= 0 then
						self:showMessage(true,gameMgr:getStrings("DEPOSIT_MSG3",{
							role = role:getName()
						}),function ()
							selectRole()
						end)
					else
						self:onSelectItem(role,function (result,item,index)
							if result then
								local item = role:removeLuggage(index)
								team:addDepositItem(item)
		
								self:showMessage(true,gameMgr:getStrings("THANKS"),function ()
									self:closeFrame()
								end)
							else
								self:showMessage(true,gameMgr:getStrings("WELCOMEAGAIN"),function ()
									self:closeFrame()
								end)
							end
						end)
					end
				else
					self:showMessage(true,gameMgr:getStrings("WELCOMEAGAIN"),function ()
						self:closeFrame()
					end)
				end
			end,type)
		end

		selectRole()
	else	-- G
		self:onSelectDeposit(team,function (result,item,index)
			if result then
				local selectRole = nil

				selectRole = function ()
					self:onSelectRole(team,function (result,role)
						if result then
							if not role:canAddToLuggage(item) then
								
								self:showMessage(true,gameMgr:getStrings("NOT_CARRY_ITEM",{
									select2 = role:getName() 
								}),function ()
									selectRole()
								end)
							else
								role:addLuggage(team:removeDepositItem(index))
								
								self:showMessage(true,gameMgr:getStrings("DEPOSIT_MSG4",{
									role = role:getName() }),function ()
										self:closeFrame()
									end)
							end
						else
							self:showMessage(true,gameMgr:getStrings("WELCOMEAGAIN"),function ()
								self:closeFrame()
							end)
						end
					end,type)
				end
				
				selectRole()
			else
				self:showMessage(true,gameMgr:getStrings("WELCOMEAGAIN"),function ()
					self:closeFrame()
				end)
			end
		end)
	end
end

-- 显示消息
function ItemDeposit:showMessage(show,texts,onComplete,option)
	if show then
		self.wg_message:clearText()
		self.wg_message:showTexts(texts,table.merge({
			usecursor = true,
			hidecsrlast = true,
			onComplete = onComplete
		},option))
		self:pushFocusWidget(self.wg_message)
		self.wg_message:setVisible(true)
	else
		self.wg_message:setVisible(false)
	end
end

-- 选择角色
function ItemDeposit:onSelectRole(team,onComplete,type)
	local roles = team:getRoles()
	local adviser = team:getAdviser()

	local roleitems = {}
	for i,role in ipairs(roles) do 
		roleitems[i] = {
			name = role:isDead() and (":" .. role:getName()) or role:getName(),
			adviser = (adviser==role),
			onTrigger = function()
				self.wg_rolelist:setVisible(false)
				self:showMessage(false)
				self:popFocusWidget()
				if onComplete then onComplete(true,role) end
			end
		}
	end
	self.wg_rolelist:sizeToRows(#roleitems)
	self.wg_rolelist:updateParams({
		items = roleitems,
		listener = {
			cancel = function()
				self.wg_rolelist:setVisible(false)
				self:showMessage(false)
				self:popFocusWidget()
				if onComplete then onComplete(false) end
			end
		}
	})

	self:showMessage(true,gameMgr:getStrings(type == "D" and "WHOSE" or "TOWHOM"),
		function ()
			self:pushFocusWidget(self.wg_rolelist)
		end,
		{ 
			ctrl_complete = false 
		})
end

-- 选择物品
function ItemDeposit:onSelectItem(role,onComplete)
	local luggages = role:getLuggages()
	local lgitems = {}
	for i,luggage in ipairs(luggages) do 
		lgitems[i] = {
			name = luggage:getName(),
			equiped = iskindof(luggage,"Accessory") and luggage:isEquiped(),
			amount = luggage:getStackMax() ~= 1 and luggage:getCount() or nil,
			onTrigger = function()
				self.wg_items:setVisible(false)
				self:showMessage(false)
				self:popFocusWidget()
				if onComplete then onComplete(true,luggage,i) end
			end
		}
	end
	for i = #lgitems + 1,dbMgr.configs.bagcapacity do 
		lgitems[i] = { label = "" }
	end
	self.wg_items:updateParams({
		items = lgitems,
		listener = {
			cancel = function()
				self.wg_items:setVisible(false)
				self:showMessage(false)
				self:popFocusWidget()
				if onComplete then onComplete(false) end
			end
		},
	})
	
	self:showMessage(true,gameMgr:getStrings("WHICH"),
		function ()
			self:pushFocusWidget(self.wg_items)
		end,
		{ 
			ctrl_complete = false 
		})
end

-- 选择寄存物品
function ItemDeposit:onSelectDeposit(team,onComplete)
	local deposits = team:getDepositItems()
	local dpsitems = {}
	for i,deposit in ipairs(deposits) do 
		dpsitems[i] = {
			name = deposit:getName(),
			amount = deposit:getStackMax() ~= 1 and deposit:getCount() or nil,
			onTrigger = function()
				self.wg_deposits:setVisible(false)
				self:showMessage(false)
				self:popFocusWidget()
				if onComplete then onComplete(true,deposit,i) end
			end
		}
	end
	self.wg_deposits:sizeToRows(math.min(#dpsitems,self.depositrows))
	self.wg_deposits:updateParams({
		items = dpsitems,
		next = { name="..." },
		listener = {
			cancel = function()
				self.wg_deposits:setVisible(false)
				self:showMessage(false)
				self:popFocusWidget()
				if onComplete then onComplete(false) end
			end
		},
	})
	
	self:showMessage(true,gameMgr:getStrings("GETWHICH"),
		function ()
			self:pushFocusWidget(self.wg_deposits)
		end,
		{ 
			ctrl_complete = false 
		})
end

-- 关闭窗口
function ItemDeposit:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function ItemDeposit:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function ItemDeposit:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function ItemDeposit:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return ItemDeposit
