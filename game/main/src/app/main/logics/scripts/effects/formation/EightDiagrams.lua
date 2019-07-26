--[[
	阵形 八卦阵
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

local EightDiagrams = class("EightDiagrams", import("._FormationBase"))

-- 构造函数
function EightDiagrams:ctor(config)
	table.merge(self,config)
end

-- 执行函数
function EightDiagrams:execute(...) 
	if self.scene == "BATTLE" then
		self:executeInBattle(...)
	elseif self.scene == "MAP" then
		self:executeInMap(...)
	end
end

--[[
	战场上 
]]
function EightDiagrams:executeInBattle(onComplete)
	self:setInBattle(onComplete,function (onComplete_,isgatking,msgui,extvars,showconfig)
		
		-- 统计
		local function doStatistics()
			self.role:doStatistics("formation")
		end

		if isgatking then
			local function setEnd()
				doStatistics()
				if onComplete_ then onComplete_(true) end
			end
			self.role:getEntity():getTeam():setFormation({
				fid = self.formation,
				front = self.targets[1]:getEntity():getID(),
			},setEnd)
		else
			local msgwin = uiMgr:openUI(msgui)
			msgwin:clearMessage()

			local function setEnd()
				performWithDelay(msgwin,function ()
					uiMgr:closeUI(msgui)
					doStatistics()
					if onComplete_ then onComplete_(true) end
				end,C_SHOW_DELAY)
			end

			msgwin:appendMessage({
				texts = gameMgr:getStrings("SET_FORMATION",extvars),
				showconfig = showconfig,
				onComplete = function ()
					self.role:getEntity():getTeam():setFormation({
						fid = self.formation,
						front = self.targets[1]:getEntity():getID(),
					},setEnd)
				end,
			})
		end
	end)
end

--[[
	地图上 
	role	设置阵形的角色
]]
function EightDiagrams:executeInMap(onComplete)
	self:setInMap(onComplete,function (onComplete_,extvars)
		self.role:getTeam():setFormation({
			fid = self.formation,
			front = self.targets[1]:getID(),
		},function ()
			uiMgr:openUI("message",{
				texts = gameMgr:getStrings("SET_FORMATION",extvars),
				onComplete = function ()
					if onComplete_ then onComplete_(true) end
				end
			})
		end)
	end)
end

return EightDiagrams
