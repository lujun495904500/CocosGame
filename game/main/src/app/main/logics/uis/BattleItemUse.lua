--[[
	战场物品使用
]]
local THIS_MODULE = ...

local BattleItemUse = class("BattleItemUse", require("app.main.modules.ui.FrameBase"), 
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
function BattleItemUse:ctor(config)
	self:setup(config)
	self:retain()
	self:initFrame()
end

-- 析构函数
function BattleItemUse:dtor()
	self:delete()
	self:release()
end

-- 初始化窗口
function BattleItemUse:initFrame()
	self:setFocusWidget(self.wg_items)
end

--[[
	打开窗口
	config 
		role		使用角色
		onComplete	完成回调
]]
function BattleItemUse:OnOpen(config)
	local luggages = config.role:getEntity():getLuggages()
	local lugitems = {}
	for i,luggage in ipairs(luggages) do
		table.insert(lugitems,{
			name = luggage:getName(),
			amount = luggage:getStackMax() ~= 1 and luggage:getCount() or nil,
			onTrigger = (function(item,pindex,index)
				local itemconf = {
					index = i,
					item = luggage,
					removeItem = (function (count)
						return config.role:getEntity():removeLuggage(i,count)
					end)
				}
				
				local function useItem(config_)
					config_ = table.merge({ 
						scene = "BATTLE",
						role = config.role,
						param = luggage:getItemParam("effect") 
					},config_)
					local effect = luggage:getItemScript("effect")
					local usescript = effect and scriptMgr:createObject(effect,config_) or 
						scriptMgr:createObject(gameMgr:getBattleUseItem(),config_)
					if usescript then
						config.role:setRoundAction(usescript)
						self:closeFrame()
						if config.onComplete then 
							config.onComplete(true) 
						end
					else
						dump(config_,"not found item effect",2)
						self:closeFrame()
						if config.onComplete then 
							config.onComplete(true) 
						end
					end
				end

				local action = luggage:getItemScript("action")
				if not action then
					useItem(itemconf)
				else
					scriptMgr:createObject(
						action,
						table.merge({
							scene = "BATTLE",
							role = config.role,
							param = luggage:getItemParam("action")
						},itemconf)
					):execute(function (success,actconf)
						if success then
							useItem(table.merge(actconf,itemconf))
						end
					end)
				end  
			end)
		})
	end
	self.wg_items:updateParams({
		items = lugitems,
		listener = {
			cancel = function()
				self:closeFrame()
				if config.onComplete then 
					config.onComplete(false) 
				end
			end
		}
	})
end

-- 获得焦点回调
function BattleItemUse:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function BattleItemUse:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function BattleItemUse:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return BattleItemUse
