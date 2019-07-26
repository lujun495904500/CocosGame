--[[
	策略 复活
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

local Revive = class("Revive", import("._StrategyBase"))

-- 构造函数
function Revive:ctor(config)
	if config then
		table.merge(self,config)
	end
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
	self:effectTargetsInBattle(onComplete,table.filter_array(self.targets,function(v) return v:isDead() end),
		function (onComplete__,target,isgatking,msgui,extvars,showconfig)
			if not target:isDead() then
				if onComplete__ then onComplete__() end
			else
				-- 统计
				local function doStatistics()
					self.role:doStatistics("evocate")
					target:doStatistics("revive")
				end

				if isgatking then
					local function useEnd()
						if onComplete__ then onComplete__() end
					end
					local function onUsing()
						target:getEntity():reviveRole(math.floor(math.random(self.param.smin,self.param.smax) / #self.targets),function ()
							doStatistics()
							useEnd()
						end)
					end
					audioMgr:playSE(strategyMgr:getSE(self.strategy,"use"))
					local useeffect = strategyMgr:getEffect(self.strategy,"use")
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
							if onComplete__ then onComplete__() end
						end,C_SHOW_DELAY)
					end
					local function onUsing()
						target:getEntity():reviveRole(math.floor(math.random(self.param.smin,self.param.smax) / #self.targets),function ()
							doStatistics()
							msgwin:appendMessage({
								texts = gameMgr:getStrings("TARGET_REVIVE",extvars),
								showconfig = showconfig,
								onComplete = useEnd,
							})
						end)
					end
					msgwin:appendMessage({
						texts = gameMgr:getStrings("USE_SKILL",extvars),
						showconfig = showconfig,
						onComplete = function ()
							audioMgr:playSE(strategyMgr:getSE(self.strategy,"use"))
							local useeffect = strategyMgr:getEffect(self.strategy,"use")
							if useeffect then
								target:playEffect(useeffect,onUsing)
							else
								onUsing()
							end
						end,
					})
				end
			end
		end)
end

--[[
	地图上复活
]]
function Revive:executeInMap(onComplete)
	self:effectTargetsInMap(onComplete,
		table.filter_array(self.targets, function(v) return v:isDead() end),
		function (onComplete_, target, extvars)
			if not target:isDead() then
				onComplete_(true)
			else
				extvars.target = target:getName()
				target:reviveRole(math.floor(math.random(self.param.smin,self.param.smax) / #self.targets),function ()
					audioMgr:playSE(strategyMgr:getSE(self.strategy,"use"))
					uiMgr:openUI("message",{
						texts = gameMgr:getStrings({"USE_SKILL","TARGET_REVIVE"},extvars),
						onComplete = onComplete_
					})
				end)
			end
		end)
end

return Revive
