--[[
	策略 减策计
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

-- 策略命中
local C_TEAMSTY_HIT = "TEAMSTY_HIT"

local ResistStrategy = class("ResistStrategy", import("._StrategyBase"))

-- 构造函数
function ResistStrategy:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行函数
function ResistStrategy:execute(...) 
	if self.scene == "BATTLE" then
		self:executeInBattle(...)
	elseif self.scene == "MAP" then
		self:executeInMap(...)
	end
end

-- 战场上
function ResistStrategy:executeInBattle(onComplete)
	self:effectInBattle(onComplete,function (onComplete_,isgatking,msgui,extvars,showconfig)
		
		-- 统计
		local function doStatistics()
			self.role:doStatistics("styuse")
			self.role:doStatistics("tstyuse")
		end

		local ishit = formulaMgr:calculate(C_TEAMSTY_HIT,{
			attrmax = gameMgr:getAttributeMax(),
		},{
			intellect = self.role:getEntity():getIntellect(),
		})
		if isgatking then
			local function useEnd()
				if onComplete_ then onComplete_(true) end
			end
			if ishit then
				doStatistics()
				self.role:getTeam():addStrategyResistance(math.random(self.param.rmin,self.param.rmax),useEnd)
			else
				useEnd()
			end
		else
			local msgwin = uiMgr:openUI(msgui)
			msgwin:clearMessage()

			local function useEnd()
				performWithDelay(msgwin,function ()
					uiMgr:closeUI(msgui)
					if onComplete_ then onComplete_(true) end
				end,C_SHOW_DELAY)
			end

			local function useResult()
				if ishit then
					doStatistics()
					self.role:getTeam():addStrategyResistance(math.random(self.param.rmin,self.param.rmax),
						msgwin:appendMessage({
							texts = gameMgr:getStrings("SKILL_RESISTSTRATEGY"),
							showconfig = showconfig,
							onComplete = useEnd,
						}))
				else
					useEnd()
				end
			end

			msgwin:appendMessage({
				texts = gameMgr:getStrings("USE_SKILL",extvars),
				showconfig = showconfig,
				onComplete = function ()
					performWithDelay(msgwin,function ()
						msgwin:appendMessage({
							texts = gameMgr:getStrings(ishit and "SUCCESS" or "FAILURE"),
							showconfig = showconfig,
							onComplete = useResult,
						})
					end,C_SHOW_DELAY)
				end
			})
		end
	end)
end

-- 地图上
function ResistStrategy:executeInMap(onComplete)
	self:invalidInMap(onComplete)
end

return ResistStrategy
