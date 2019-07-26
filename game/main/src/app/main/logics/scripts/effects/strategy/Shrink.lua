--[[
	策略 缩地计
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

local Shrink = class("Shrink", import("._StrategyBase"))

-- 构造函数
function Shrink:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行函数
function Shrink:execute(...) 
	if self.scene == "BATTLE" then
		self:executeInBattle(...)
	elseif self.scene == "MAP" then
		self:executeInMap(...)
	end
end

-- 战场上
function Shrink:executeInBattle(onComplete)
	self:invalidInBattle(onComplete)
end

-- 地图上
function Shrink:executeInMap(onComplete)
	self:effectInMap(onComplete,function (onComplete_,extvars)
		local outtype = gameMgr:getMapEnv("outtype")
		if outtype then
			uiMgr:openUI("message",{
				texts = gameMgr:getStrings("USE_SKILL",extvars),
				onComplete = function ()
					audioMgr:playSE(strategyMgr:getSE(self.strategy,"use"))
					performWithDelay(sceneMgr:getCurrentScene(),function ()
						sceneMgr:getCurrentScene():teleportMap({
							mapname = gameMgr:getMapEnv(outtype),
							inpos = gameMgr:getMapEnv(outtype .. "_in"),
							inmethod = "POINT",
							inface = "DOWN"
						})
						if onComplete_ then onComplete_(true) end
					end,self.param.delay)
				end
			})
		else -- not
			uiMgr:openUI("message",{
				texts = gameMgr:getStrings({"USE_SKILL","NO_EFFECT"},extvars),
				onComplete = function ()
					if onComplete_ then onComplete_(false) end
				end
			})
		end
	end)
end

return Shrink
