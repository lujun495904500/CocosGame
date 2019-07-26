--[[
	物品复活
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

local Revive = class("Revive", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Revive:ctor(config)
	table.merge(self,config)
end

-- 执行函数
function Revive:execute(...) 
	if self.scene == "BATTLE" then
		self:executeInBattle(...)
	elseif self.scene == "MAP" then
		self:executeInMap(...)
	end
end

--[[
	战场上复活
]]
function Revive:executeInBattle(onComplete)
	self._isallatking = self.role:getScene():isGeneralAttack()   -- 总攻
	local msgui = self.role:isEnemy() and "message" or "ourmessage"
	self.targets = table.filter_array(self.targets,function(v) return v:isDead() end)

	local reviveTarget = nil
	local doRevive = nil
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

	reviveTarget = function (target,onComplete_)
		if not target:isDead() then
			if onComplete_ then onComplete_() end
		else
			-- 统计
			local function doStatistics()
				self.role:doStatistics("evocate")
				target:doStatistics("revive")
			end

			if self._isallatking then
				local function useEnd()
					if onComplete_ then onComplete_() end
				end
				local function onUsing()
					target:getEntity():reviveRole(math.floor(self.item:getReviveSoldiers() / #self.targets),function ()
						doStatistics()
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
					target:getEntity():reviveRole(math.floor(self.item:getReviveSoldiers() / #self.targets),function ()
						doStatistics()
						msgwin:appendMessage({
							texts = gameMgr:getStrings("TARGET_REVIVE",extvars),
							showconfig = showconfig,
							onComplete = useEnd,
						})
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

	doRevive = function (onComplete_)
		if #self.targets <= 0 then
			if onComplete_ then onComplete_() end
		else
			if self.item:tryUseItem() then
				local index = 0
				local nextRevive = nil
	
				nextRevive = function ()
					if index + 1 <= #self.targets then
						index = index + 1
		
						local target = self.targets[index]
						reviveTarget(target,nextRevive)
					else
						if self.item:isUseUp() then
							self.removeItem(1)
						end
						if onComplete_ then onComplete_() end
					end
				end
	
				nextRevive()
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
		doRevive(onComplete)
	else
		self.role:selectForward(true,function ()
			doRevive(function ()
				self.role:selectForward(false,onComplete)
			end)
		end)
	end
end

--[[
	地图上复活
]]
function Revive:executeInMap(onComplete)
	self.targets = table.filter_array(self.targets,function(v) return v:isDead() end)

	if #self.targets <= 0 then
		if onComplete then onComplete(true) end
	else
		local extvars = {
			role = self.role:getName(),
			item = self.item:getName(),
		}
	
		if self.item:tryUseItem() then
			local index = 0
			local reviveTarget = nil
			local nextRevive = nil
	
			reviveTarget = function(target,onComplete_)
				if not target:isDead() then
					if onComplete_ then onComplete_() end
				else
					extvars.target = target:getName()
	
					target:reviveRole(math.floor(self.item:getReviveSoldiers() / #self.targets),function ()
						audioMgr:playSE(self.item:getUseSE())
						uiMgr:openUI("message",{
							texts = gameMgr:getStrings({"USE_ITEM","TARGET_REVIVE"},extvars),
							onComplete = onComplete_
						})
					end)
				end
			end
	
			nextRevive = function ()
				if index + 1 <= #self.targets then
					index = index + 1
	
					local target = self.targets[index]
					reviveTarget(target,nextRevive)
				else
					if self.item:isUseUp() then
						self.removeItem(1)
					end
					if onComplete then onComplete(true) end
				end
			end
	
			nextRevive()
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

return Revive
