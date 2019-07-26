--[[
	阵形 解散
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

local Disband = class("Disband", import("._FormationBase"))

-- 构造函数
function Disband:ctor(config)
	table.merge(self,config)
end

-- 执行函数
function Disband:execute(...) 
	if self.scene == "BATTLE" then
		self:executeInBattle(...)
	elseif self.scene == "MAP" then
		self:executeInMap(...)
	end
end

--[[
	战场上 
]]
function Disband:executeInBattle(onComplete)
	self:setInBattle(onComplete,function (onComplete_,isgatking,msgui,extvars,showconfig)
		local teamentity = self.role:getEntity():getTeam()
		if isgatking then
			local function setEnd()
				if onComplete_ then onComplete_(true) end
			end
			teamentity:setFormation(nil, function ()
				self.role:getTeam():showUnsetFormation(setEnd,true)
			end)
		else
			local msgwin = uiMgr:openUI(msgui)
			msgwin:clearMessage()

			local function setEnd()
				performWithDelay(msgwin,function ()
					uiMgr:closeUI(msgui)
					if onComplete_ then onComplete_(true) end
				end,C_SHOW_DELAY)
			end

			msgwin:appendMessage({
				texts = gameMgr:getStrings("SET_FORMATION",extvars),
				showconfig = showconfig,
				onComplete = function ()
					teamentity:setFormation(nil,function ()
						msgwin:appendMessage({
							texts = gameMgr:getStrings("UNSET_FORMATION",{
								team = teamentity:getName()
							}),
							showconfig = showconfig,
							onComplete = function ()
								self.role:getTeam():showUnsetFormation(setEnd,true)
							end
						})
					end)
				end,
			})
		end
	end)
end

--[[
	地图上 
	role	设置阵形的角色
]]
function Disband:executeInMap(onComplete)
	self:setInMap(onComplete,function (onComplete_,extvars)
		self.role:getTeam():setFormation(nil,function ()
			uiMgr:openUI("message",{
				texts = gameMgr:getStrings("SET_FORMATION",extvars),
				onComplete = function ()
					if onComplete_ then onComplete_(true) end
				end
			})
		end)
	end)
end

return Disband
