--[[
	物品操作
]]
local THIS_MODULE = ...

local ItemOperate = class("ItemOperate", require("app.main.modules.ui.FrameBase"), 
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
function ItemOperate:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function ItemOperate:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function ItemOperate:reinitWidgets()
	self.wg_rolelist:setVisible(false)
	self.wg_items:setVisible(false)
	self.wg_equipments:setVisible(false)
	self.wg_equipinfo:setVisible(false)
	self.wg_operates:setVisible(false)
end

--[[
	打开窗口
	map		 当前地图
	mapteam	 地图队伍
]]
function ItemOperate:OnOpen(map,mapteam)
	self:reinitWidgets()
	
	local team = mapteam:getEntity()
	local roles = team:getRoles()
	local adviser = team:getAdviser()
	local operateItem = nil
	local updateItems = nil
	local updateRoles = nil
	
	operateItem = function(role,type,key)
		-- 获得操作物品
		local function getItem()
			return type == "E" and role:getEquipment(key) or 
				role:getLuggage(key)
		end

		-- 移除操作物品
		local function removeItem(count)
			if type == "E" then
				local rmitem = role:removeEquipment(key)
				updateItems(role,nil,{
					hidecsrf = true
				})
				return rmitem
			else
				local lastcount = role:getLuggageCount()
				local rmitem = role:removeLuggage(key,count)
				updateItems(role,(role:getLuggageCount() ~= lastcount) and 
				{
					hidecsrf = true
				} or {
					pageindex = self.wg_items:getPageIndex(),
					selindex = self.wg_items:getSelectIndex(),
				})
				return rmitem
			end  
		end

		-- 关闭操作
		local function closeOperation()
			uiMgr:closeAll(self:getName())
			self.wg_operates:setVisible(false)
			updateRoles({
				pageindex = self.wg_rolelist:getPageIndex(),
				selindex = self.wg_rolelist:getSelectIndex()
			})
			self:setFocusWidget(type == "L" and self.wg_items or self.wg_equipments)
		end

		self.wg_operates:setListener({
			trigger = function(item_,pindex,index)
				local itype = item_.type
				if itype == "U" then
					local item = getItem()
					local useconf = {
						mapteam = mapteam,
						role = role,
						item = item,
						getItem = getItem,
						removeItem = removeItem,
					}

					local function useItem(config)
						config = table.merge({ 
							scene = "MAP",
							param = item:getItemParam("effect") 
						}, config)
						local effect = item:getItemScript("effect")
						local usescript = effect and scriptMgr:createObject(effect,config) or 
							scriptMgr:createObject(gameMgr:getMapUseItem(),config)
						if usescript then
							usescript:execute(function (success)
								closeOperation()
							end)
						else
							dump(config,"not found item effect",2)
						end
					end

					local action = item:getItemScript("action")
					if not action then
						useItem(useconf)
					else
						scriptMgr:createObject(
							action,
							table.merge({
								scene = "MAP",
								param = item:getItemParam("action"),
							},useconf)
						):execute(function (success,actconf)
							if success then
								useItem(table.merge(actconf,useconf))
							else
								closeOperation()
							end
						end)
					end
				elseif itype == "G" then
					uiMgr:openUI("targetselect",function (success, targets)
						if success then
							local _role = targets[1]
							local item = getItem()
							local extvars = {
								select = role:getName(),
								item = item:getName(),
								select2 = _role:getName(),
							}
							if _role == role then
								uiMgr:openUI("message",{
									autoclose = true,
									texts = gameMgr:getStrings("DELIVER_ITEM_SELF", extvars),
									onComplete = closeOperation
								})
							elseif _role:canAddToLuggage(item,1) then
								_role:addLuggage(removeItem(1))
								uiMgr:openUI("message",{
									autoclose = true,
									texts = gameMgr:getStrings("DELIVER_ITEM", extvars),
									onComplete = closeOperation
								})
							else
								uiMgr:openUI("message",{
									autoclose = true,
									texts = gameMgr:getStrings("NOT_CARRY_ITEM", extvars),
									onComplete = closeOperation
								})
							end
						else
							closeOperation()
						end
					end,{
						team = team,
						role_dead = true,
					})
				elseif itype == "E" then
					local item = getItem()
					local extvars = {
						select  =   role:getName(),
						item	=   item:getName()
					}
					if type == "E" then
						if not role:canAddToLuggage(item) then
							uiMgr:openUI("message",{
								autoclose = true,
								texts = gameMgr:getStrings("NOT_UNEQUIP_ITEM", extvars),
								onComplete = closeOperation
							})
						else
							role:addLuggage(removeItem(1))
							updateItems(role)
							uiMgr:openUI("message",{
								autoclose = true,
								texts = gameMgr:getStrings("UNEQUIP_ITEM", extvars),
								onComplete = closeOperation
							})
						end
					else
						if iskindof(item,"Equipment") then
							if iskindof(item,"Weapon") and not role:checkWeapon(item) then
								uiMgr:openUI("message",{
									autoclose = true,
									texts = gameMgr:getStrings("NOT_EQUIP_ITEM", extvars),
									onComplete = closeOperation
								})
							else
								local olditem = role:addEquipment(removeItem(1))
								if olditem then
									role:addLuggage(olditem)
								end
								updateItems(role,{
									hidecsrf = true
								})
								uiMgr:openUI("message",{
									autoclose = true,
									texts = gameMgr:getStrings("EQUIP_ITEM", extvars),
									onComplete = closeOperation
								})
							end
						elseif iskindof(item,"Accessory") then
							if item:isEquiped() then
								role:unequipAccessory(key)
								updateItems(role,{
									pageindex = self.wg_items:getPageIndex(),
									selindex = self.wg_items:getSelectIndex(),
								})
								uiMgr:openUI("message",{
									autoclose = true,
									texts = gameMgr:getStrings("UNEQUIP_ITEM", extvars),
									onComplete = closeOperation
								})
							else
								role:equipAccessory(key)
								updateItems(role,{
									pageindex = self.wg_items:getPageIndex(),
									selindex = self.wg_items:getSelectIndex(),
								})
								uiMgr:openUI("message",{
									autoclose = true,
									texts = gameMgr:getStrings("EQUIP_ITEM", extvars),
									onComplete = closeOperation
								})
							end
						else
							uiMgr:openUI("message",{
								autoclose = true,
								texts = gameMgr:getStrings("NOT_EQUIP_ITEM", extvars),
								onComplete = closeOperation
							})
						end
					end
				else	-- L
					local item = removeItem()
					local extvars = {
						select  =   role:getName(),
						item	=   item:getName()
					}
					if map then
						map:addEvent(false,"RESEARCH","__" .. tostring(os.time()),{
							bounds = map:getMajorTeam():getBounds(),
							script = {
								script = gameMgr:getFindItemScript(),
								config = {
									finds = {
										{ item = item }
									}
								}
							},
							single = true
						})
					end
					uiMgr:openUI("message",{
						autoclose = true,
						texts = gameMgr:getStrings("DROP_ITEM", extvars),
						onComplete = closeOperation
					})
				end
			end,
			cancel = closeOperation
		})
		self.wg_operates:changeSelect(1)
		self:setFocusWidget(self.wg_operates)
	end

	updateItems = function(role,ioption,eoption)
		-- 装备信息
		self.equip_attack:setString(tostring(role:getAttack()))
		self.equip_defense:setString(tostring(role:getDefense()))

		-- 物品
		local luggages = role:getLuggages()
		local lgitems = {}
		for i,luggage in ipairs(luggages) do 
			lgitems[i] = {
				name = luggage:getName(),
				equiped = iskindof(luggage,"Accessory") and luggage:isEquiped(),
				amount = luggage:getStackMax() ~= 1 and luggage:getCount() or nil,
				onTrigger = function()
					operateItem(role,"L",i)
				end
			}
		end
		for i = #lgitems + 1,dbMgr.configs.bagcapacity do 
			lgitems[i] = { label = "" }
		end
		self.wg_items:updateParams(table.merge({
			items = lgitems,
			listener = {
				cancel = function()
					self.wg_items:markSelect(false)
					self.wg_equipments:markSelect(false)
					self:setFocusWidget(self.wg_rolelist)
				end,
				overup = function()
					self.wg_items:markSelect(false)
					self.wg_equipments:markSelect(true)
					self.wg_equipments:changeSelect(3)
					self:setFocusWidget(self.wg_equipments)
				end,
				overdown = function()
					self.wg_items:markSelect(false)
					self.wg_equipments:markSelect(true)
					self.wg_equipments:changeSelect(1)
					self:setFocusWidget(self.wg_equipments)
				end
			},
		},ioption))

		-- 装备
		local equips = role:getEquipments()
		local eqitems = { }
		for _,key in ipairs({"W","A","H","S"}) do
			local equip = equips[key]
			if not equip then
				eqitems[#eqitems + 1] = { label = "" }
			else
				local eqpname = equip:getName()
				if key == "W" and not role:getAvailableWeapon() then
					eqpname = ":" .. eqpname	-- 无效的武器
				end
				eqitems[#eqitems + 1] = {
					label = eqpname,
					onTrigger = function()
						operateItem(role,"E",key)
					end
				}
			end
		end
		self.wg_equipments:updateParams(table.merge({
			items = eqitems,
			listener = {
				cancel = function()
					self.wg_items:markSelect(false)
					self.wg_equipments:markSelect(false)
					self:setFocusWidget(self.wg_rolelist)
				end,
				overup = function()
					self.wg_items:markSelect(true)
					self.wg_equipments:markSelect(false)
					self.wg_items:changeSelect(dbMgr.configs.bagcapacity)
					self:setFocusWidget(self.wg_items)
				end,
				overdown = function()
					self.wg_items:markSelect(true)
					self.wg_equipments:markSelect(false)
					self.wg_items:changeSelect(1)
					self:setFocusWidget(self.wg_items)
				end
			}
		},eoption))
	end

	updateRoles = function (option)
		local roleitems = {}
		for i,role in ipairs(roles) do 
			roleitems[i] = {
				name = role:isDead() and (":" .. role:getName()) or role:getName(),
				adviser = (adviser==role),
				onTrigger = function()
					self.wg_items:markSelect(true)
					self:setFocusWidget(self.wg_items)
				end
			}
		end
		self.wg_rolelist:sizeToRows(#roleitems)
		self.wg_rolelist:updateParams(table.merge({
			items = roleitems,
			listener = {
				cancel = function()
					self:closeFrame()
				end,
				change = function(item,index_)
					self.wg_items:markSelect(false)
					updateItems(roles[index_])
				end
			}
		},option))
	end

	-- 初始化角色列表
	if #roles > 0 then
		updateRoles()
		updateItems(roles[1])
	end
	
	self.wg_items:setVisible(true)
	self.wg_equipinfo:setVisible(true)
	self.wg_equipments:setVisible(true)
	self:setFocusWidget(self.wg_rolelist)
end

-- 关闭窗口
function ItemOperate:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function ItemOperate:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function ItemOperate:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function ItemOperate:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return ItemOperate
