--[[
	物品恢复
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

local Recovery = class("Recovery", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Recovery:ctor(config)
	table.merge(self,config)
end

-- 执行函数
function Recovery:execute(...) 
	if self.scene == "BATTLE" then
		self:executeInBattle(...)
	elseif self.scene == "MAP" then
		self:executeInMap(...)
	end
end

--[[
	战场上恢复
]]
function Recovery:executeInBattle(onComplete)
	self._isallatking = self.role:getScene():isGeneralAttack()   -- 总攻
	local msgui = self.role:isEnemy() and "message" or "ourmessage"
	self.targets = table.filter_array(self.targets,function(v) return not v:isDead() end)

	local doRecovery = nil
	local recoverTarget = nil
	local showconfig = {
		usecursor	   = false, 
		usesound		= false,
		quickshow	   = true,
		linefeed		= true,
		ctrl_quick	  = false,
		ctrl_complete   = false,
	}
	local extvars = {
		role = self.role:getEntity():getName(),
		item = self.item:getName(),
	}
	
	recoverTarget = function (target,onComplete_)
		if target:isDead() then
			if onComplete_ then onComplete_() end
		else
			-- 统计
			local function doStatistics(recvsolds)
				self.role:doStatistics("treatment",recvsolds)
				target:doStatistics("recovery",recvsolds)
			end

			if self._isallatking then
				local function useEnd()
					if onComplete_ then onComplete_() end
				end
				local function onUsing()
					target:getEntity():recoverSoldiers(math.floor(self.item:getRecovery() / #self.targets),function (recvsolds)
						doStatistics(recvsolds)
						useEnd()
					end)
				end
				audioMgr:playSE(self.item:getUseSE())
				local useeffect = self.item:getItemEffect("use")
				if useeffect then
					target:playEffect(useeffect,onUsing)
				else
					onUsing()
				end
			else
				extvars.target = target:getEntity():getName()

				local msgwin = uiMgr:openUI(msgui)
				msgwin:clearMessage()

				local function useEnd()
					performWithDelay(msgwin,function ()
						uiMgr:closeUI(msgui)
						if onComplete_ then onComplete_() end
					end,C_SHOW_DELAY)
				end
				local function onUsing()
					target:getEntity():recoverSoldiers(math.floor(self.item:getRecovery() / #self.targets),function (recvsolds)
						doStatistics(recvsolds)
						if target:getEntity():isMaxSoldiers() then
							msgwin:appendMessage({
								texts = gameMgr:getStrings("RECOVER_SOLDIERS_ALL",extvars),
								showconfig = showconfig,
								onComplete = useEnd,
							})
						else
							extvars.soldiers = recvsolds
							msgwin:appendMessage({
								texts = gameMgr:getStrings("RECOVER_SOLDIERS",extvars),
								showconfig = showconfig,
								onComplete = useEnd,
							})
						end
					end)
				end
				msgwin:appendMessage({
					texts = gameMgr:getStrings("USE_ITEM",extvars),
					showconfig = showconfig,
					onComplete = function ()
						audioMgr:playSE(self.item:getUseSE())
						local useeffect = self.item:getItemEffect("use")
						if useeffect then
							target:playEffect(useeffect,onUsing)
						else
							onUsing()
						end
					end,
				})
			end
		end
	end
	
	doRecovery = function (onComplete_)
		if #self.targets <= 0 then
			if onComplete_ then onComplete_() end
		else
			if self.item:tryUseItem() then
				local index = 0
				local nextRecovery = nil

				nextRecovery = function ()
					if index + 1 <= #self.targets then
						index = index + 1

						local target = self.targets[index]
						recoverTarget(target,nextRecovery)
					else
						if self.item:isUseUp() then
							self.removeItem(1)
						end
						if onComplete_ then onComplete_() end
					end
				end

				nextRecovery()
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
	end

	if self._isallatking then
		doRecovery(onComplete)
	else
		self.role:selectForward(true,function ()
			doRecovery(function ()
				self.role:selectForward(false,onComplete)
			end)
		end)
	end
end

--[[
	地图上恢复
]]
function Recovery:executeInMap(onComplete)
	self.targets = table.filter_array(self.targets,function(v) return not v:isDead() end)

	if #self.targets <= 0 then
		if onComplete then onComplete(true) end
	else
		if self.item:tryUseItem() then
			local index = 0
			local nextRecover = nil
			local extvars = {
				role = self.role:getName(),
				item = self.item:getName(),
			}
			
			nextRecover = function()
				if index + 1 <= #self.targets then
					index = index + 1
					
					local target = self.targets[index]
					if target:isDead() then
						nextRecover()
					else
						extvars.target = target:getName()
					
						target:recoverSoldiers(math.floor(self.item:getRecovery() / #self.targets),function (recvsolds)
							audioMgr:playSE(self.item:getUseSE())
							if target:isMaxSoldiers() then
								uiMgr:openUI("message",{
									texts = gameMgr:getStrings({"USE_ITEM","RECOVER_SOLDIERS_ALL"},extvars),
									onComplete = nextRecover
								})
							else
								extvars.soldiers = recvsolds
								uiMgr:openUI("message",{
									texts = gameMgr:getStrings({"USE_ITEM","RECOVER_SOLDIERS"},extvars),
									onComplete = nextRecover
								})
							end
						end)
					end
				else
					if self.item:isUseUp() then
						self.removeItem(1)
					end
					if onComplete then onComplete(true) end
				end
			end
	
			nextRecover()
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
end

return Recovery
