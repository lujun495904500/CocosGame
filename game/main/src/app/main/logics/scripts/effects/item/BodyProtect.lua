--[[
	物品 护身烟
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

local BodyProtect = class("BodyProtect", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function BodyProtect:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行函数
function BodyProtect:execute(...) 
	if self.scene == "BATTLE" then
		self:executeInBattle(...)
	elseif self.scene == "MAP" then
		self:executeInMap(...)
	end
end

-- 战场上
function BodyProtect:executeInBattle(onComplete)
	self._isallatking = self.role:getScene():isGeneralAttack()   -- 总攻
	local msgui = self.role:isEnemy() and "message" or "ourmessage"
	
	local useItem = nil
	local extvars = {
		role = self.role:getEntity():getName(),
		item = self.item:getName(),
	}
	local showconfig = {
		usecursor	   = false, 
		usesound		= false,
		quickshow	   = true,
		linefeed		= true,
		ctrl_quick	  = false,
		ctrl_complete   = false,
	}

	useItem = function (onComplete_)
		if self.item:tryUseItem() then
			
			-- 统计
			local function doStatistics()
				self.role:doStatistics("itemuse")
			end

			local function useEnd()
				self.role:getEntity():getTeam():addBuff(self.param.bid,{
					steps = buffMgr:getParam(self.param.bid).steps
				})
				if self.item:isUseUp() then
					self.removeItem(1)
				end
				doStatistics()
				if onComplete_ then onComplete_() end
			end
			if self._isallatking then
				useEnd()
			else
				local msgwin = uiMgr:openUI(msgui)
				msgwin:showMessage({
					texts = gameMgr:getStrings("USE_ITEM",extvars),
					showconfig = showconfig,
					onComplete = function ()
						performWithDelay(msgwin,function ()
							uiMgr:closeUI(msgui)
							useEnd()
						end,C_SHOW_DELAY)
					end,
				})
			end
		else
			dump(self.item,"使用用尽的物品")
			uiMgr:openUI(msgui,{
				texts = gameMgr:getStrings("BUG",{
					bug = "use invalid item "
				}),
				onComplete = function ()
					self.removeItem(1)
					if onComplete_ then onComplete_() end
				end
			})
		end
	end

	if self._isallatking then
		useItem(onComplete)
	else
		self.role:selectForward(true,function ()
			useItem(function ()
				self.role:selectForward(false,onComplete)
			end)
		end)
	end
end

-- 地图上
function BodyProtect:executeInMap(onComplete)
	local extvars = {
		role = self.role:getName(),
		item = self.item:getName(),
	}

	if self.item:tryUseItem() then
		uiMgr:openUI("message",{
			texts = gameMgr:getStrings("USE_ITEM",extvars),
			onComplete = function ()
				self.role:getTeam():addBuff(self.param.bid,{
					steps = buffMgr:getParam(self.param.bid).steps
				})
				if self.item:isUseUp() then
					self.removeItem(1)
				end
				if onComplete then onComplete(true) end
			end
		})
	else
		dump(self.item,"使用用尽的物品")
		uiMgr:openUI("message",{
			texts = gameMgr:getStrings("BUG",{
				bug = "use invalid item "
			}),
			onComplete = function ()
				self.removeItem(1)
				if onComplete then onComplete(false) end
			end
		})
	end
end

return BodyProtect
