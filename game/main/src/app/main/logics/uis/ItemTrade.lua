--[[
	物品贸易
]]
local THIS_MODULE = ...

local ItemTrade = class("ItemTrade", require("app.main.modules.ui.FrameBase"), 
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
function ItemTrade:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function ItemTrade:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function ItemTrade:reinitWidgets()
	self.wg_rolelist:setVisible(false)
	self.wg_targetlist:setVisible(false)
	self.wg_items:setVisible(false)
	self.wg_goods:setVisible(false)
	self.wg_message:setVisible(false)
	self.pl_golds:setVisible(false)
end

--[[
	打开窗口
	team	物品队伍
	type	B/S 购买/卖出
	goods	购买的商品
]]
function ItemTrade:OnOpen(team,type,goods)
	self:reinitWidgets()

	if type == "B" then
		local selectGood = nil
		local buyOther = nil

		buyOther = function ()
			uiMgr:openUI("select",{
				autoclose = true,
				messages = gameMgr:getStrings("SHOP_MSG8"),
				selects = {
					{
						label = gameMgr:getStrings("YES")[1],
						type = "Y",
					},{
						label = gameMgr:getStrings("NO")[1],
						type = "N",
					}
				},
				onComplete = function (result,item)
					if result and item.type == "Y" then
						selectGood()
					else
						self:showMessage(true,gameMgr:getStrings("THANKS"),function ()
							self:closeFrame()
						end)
					end
				end
			})
		end

		selectGood = function ()
			self:showGolds(true,team)
			self:onSelectGood(goods,function (result,good,costs)
				if result then
					if team:getGolds() < costs then
						self:showMessage(true,gameMgr:getStrings("SHOP_MSG6"),function ()
							self:closeFrame()
						end)
					else
						local selectTarget = nil

						selectTarget = function ()
							self:onSelectTarget(team,function (result,role)
								if result then
									if not role:canAddToLuggage(good,1) then
										self:showMessage(true,gameMgr:getStrings("NOT_CARRY_ITEM",{
											select2 = role:getName() 
										}),function ()
											selectTarget()
										end)
									else
										local function doBuy()
											team:tryCostGolds(costs)
											self:showGolds(true,team)
											role:addLuggage(good:copy())

											self.wg_goods:setVisible(false)
											self.wg_targetlist:setVisible(false)
											buyOther()
										end

										if iskindof(good,"Weapon") and not role:checkWeapon(good) then
											uiMgr:openUI("select",{
												autoclose = true,
												messages = gameMgr:getStrings("SHOP_MSG7",{
													role = role:getName()
												}),
												selects = {
													{
														label = gameMgr:getStrings("YES")[1],
														type = "Y",
													},{
														label = gameMgr:getStrings("NO")[1],
														type = "N",
													}
												},
												onComplete = function (result,item)
													if result and item.type == "Y" then
														doBuy()
													else
														selectTarget()
													end
												end
											})
										else
											doBuy()
										end
									end
								else
									self:showGolds(false)
									self:showMessage(true,gameMgr:getStrings("WELCOMEAGAIN"),function ()
										self:closeFrame()
									end)
								end
							end)
						end
						
						selectTarget()
					end
				else
					self:showGolds(false)
					self:showMessage(true,gameMgr:getStrings("WELCOMEAGAIN"),function ()
						self:closeFrame()
					end)
				end
			end)
		end

		selectGood()
	else	-- S
		local selectRole = nil
		local sellOther = nil

		sellOther = function (msgs)
			uiMgr:openUI("select",{
				autoclose = true,
				messages = msgs,
				selects = {
					{
						label = gameMgr:getStrings("YES")[1],
						type = "Y",
					},{
						label = gameMgr:getStrings("NO")[1],
						type = "N",
					}
				},
				onComplete = function (result,item)
					if result and item.type == "Y" then
						selectRole()
					else
						self:showMessage(true,gameMgr:getStrings("THANKS"),function ()
							self:closeFrame()
						end)
					end
				end
			})
		end

		selectRole = function ()
			self:showGolds(true,team)
			self:onSelectRole(team,function (result,role)
				if result then
					if role:getLuggageCount() <= 0 then
						self:showGolds(false)
						self:showMessage(true,gameMgr:getStrings("SHOP_MSG1",{
							role = role:getName()
						}),function ()
							selectRole()
						end)
					else
						local selectItem = nil 

						selectItem = function ()
							self:showGolds(false)
							self:onSelectItem(role,function (result,item,index)
								if result then
									if not item:isSellable() then
										self:showMessage(true,gameMgr:getStrings("SHOP_MSG2"),function ()
											selectItem()
										end)
									else
										local golds = math.floor(item:getPrice() * gameMgr:getSellDepreciate())
										uiMgr:openUI("select",{
											autoclose = true,
											messages = gameMgr:getStrings("SHOP_MSG3",{
												golds = golds
											}),
											selects = {
												{
													label = gameMgr:getStrings("YES")[1],
													type = "Y",
												},{
													label = gameMgr:getStrings("NO")[1],
													type = "N",
												}
											},
											onComplete = function (result,item)
												if result and item.type == "Y" then
													role:removeLuggage(index,1)
													team:addGolds(golds > 0 and golds or 0)
													self:showGolds(true,team)
													sellOther(gameMgr:getStrings("SHOP_MSG4"))
												else
													sellOther(gameMgr:getStrings("SHOP_MSG5"))
												end 
											end
										})
									end
								else
									self:showGolds(false)
									self:showMessage(true,gameMgr:getStrings("WELCOMEAGAIN"),function ()
										self:closeFrame()
									end)
								end
							end)
						end
						
						selectItem()
					end
				else
					self:showGolds(false)
					self:showMessage(true,gameMgr:getStrings("WELCOMEAGAIN"),function ()
						self:closeFrame()
					end)
				end
			end)
		end

		selectRole()
	end
end

-- 显示金
function ItemTrade:showGolds(show,team)
	if show then
		self.lb_golds:setString(tostring(team:getGolds()))
		self.pl_golds:setVisible(true)
	else
		self.pl_golds:setVisible(false)
	end
end

-- 显示消息
function ItemTrade:showMessage(show,texts,onComplete,option)
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
function ItemTrade:onSelectRole(team,onComplete,type)
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

	self:showMessage(true,gameMgr:getStrings("WHOSE"),
		function ()
			self:pushFocusWidget(self.wg_rolelist)
		end,
		{ 
			ctrl_complete = false 
		})
end

-- 选择物品
function ItemTrade:onSelectItem(role,onComplete)
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

-- 选择商品
function ItemTrade:onSelectGood(goods,onComplete)
	local gooditems = {}
	for _,good in ipairs(goods) do 
		local item = tools:createItem(good)
		if item:isSellable() then
			gooditems[#gooditems + 1] = {
				name = item:getName(),
				amount = math.floor(item:getPrice() * gameMgr:getBuyDiscount()),
				onTrigger = function(item_)
					self:showMessage(false)
					self:popFocusWidget()
					if onComplete then onComplete(true,item,item_.amount) end
				end
			}
		end
		
	end
	self.wg_goods:sizeToRows(math.min(#gooditems,self.goodsmax))
	self.wg_goods:updateParams({
		items = gooditems,
		next = { name="..." },
		listener = {
			cancel = function()
				self.wg_goods:setVisible(false)
				self:showMessage(false)
				self:popFocusWidget()
				if onComplete then onComplete(false) end
			end
		},
	})
	
	self:showMessage(true,gameMgr:getStrings("BUYWHICH"),
		function ()
			self:pushFocusWidget(self.wg_goods)
		end,
		{ 
			ctrl_complete = false 
		})
end

-- 选择目标
function ItemTrade:onSelectTarget(team,onComplete)
	local roles = team:getRoles()
	local adviser = team:getAdviser()

	local roleitems = {}
	for i,role in ipairs(roles) do 
		roleitems[i] = {
			name = role:isDead() and (":" .. role:getName()) or role:getName(),
			adviser = (adviser==role),
			onTrigger = function()
				self:showMessage(false)
				self:popFocusWidget()
				if onComplete then onComplete(true,role) end
			end
		}
	end
	self.wg_targetlist:sizeToRows(#roleitems)
	self.wg_targetlist:updateParams({
		items = roleitems,
		listener = {
			cancel = function()
				self.wg_goods:setVisible(false)
				self.wg_targetlist:setVisible(false)
				self:showMessage(false)
				self:popFocusWidget()
				if onComplete then onComplete(false) end
			end
		}
	})

	self:showMessage(true,gameMgr:getStrings("TOWHOM"),
		function ()
			self:pushFocusWidget(self.wg_targetlist)
		end,
		{ 
			ctrl_complete = false 
		})
end

-- 关闭窗口
function ItemTrade:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function ItemTrade:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function ItemTrade:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function ItemTrade:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return ItemTrade
