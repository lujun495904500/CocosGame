--[[
	阵形基类
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

-- 显示配置
local C_SHOW_CONFIG = {
	usecursor		= false, 
	usesound		= false,
	quickshow		= true,
	linefeed		= true,
	ctrl_quick		= false,
	ctrl_complete	= false,
}

local _FormationBase = class("_FormationBase", require("app.main.modules.script.ScriptBase"))

-- 战场动作
function _FormationBase:doActionInBattle(onComplete,isgatking,doAction)
	local function _beforeAction(onComplete_)
		if isgatking then
			onComplete_()
		else
			self.role:selectForward(true,onComplete_)
		end
	end

	local function _doAction(onComplete_)
		if not doAction then
			onComplete_()
		else
			doAction(onComplete_,isgatking)
		end
	end

	local function _afterAction(onComplete_)
		if isgatking then
			onComplete_()
		else
			self.role:selectForward(false,onComplete_)
		end
	end

	if self.role:isDead() then
		if onComplete then onComplete() end
	else
		_beforeAction(function ()
			_doAction(function ()
				_afterAction(function ()
					if onComplete then onComplete() end
				end)
			end)
		end)
	end
end

-- 战场上设置
function _FormationBase:setInBattle(onComplete,fnSet)
	self:doActionInBattle(onComplete,self.role:getScene():isGeneralAttack(),
		function (onComplete_,isgatking)
			local msgui = self.role:isEnemy() and "message" or "ourmessage"
			local extvars = {
				formation = formationMgr:getName(self.formation),
				role = self.role:getEntity():getName()
			}
			if #self.role:getTeam():getAliveRoles() < formationMgr:getSetRoles(self.formation) then
				if isgatking then
					if onComplete_ then onComplete_(false) end
				else
					local msgwin = uiMgr:openUI(msgui)
					msgwin:showMessage({
						texts = gameMgr:getStrings("NOTSET_FORMATION", extvars),
						showconfig = C_SHOW_CONFIG,
						onComplete = function ()
							performWithDelay(msgwin,function ()
								uiMgr:closeUI(msgui)
								if onComplete_ then onComplete_(false) end
							end, C_SHOW_DELAY)
						end
					})
				end
			else
				if self.role:getEntity():getTeam():tryConsumeSP(self.sp) then
					fnSet(onComplete_,isgatking,msgui,extvars,C_SHOW_CONFIG)
				else
					if isgatking then
						if onComplete_ then onComplete_(false) end
					else
						local msgwin = uiMgr:openUI(msgui)
						local msg = self.role:getEntity():getTeam():getAdviser() and "LACK_SP" or "NO_ADVISER"
						msgwin:showMessage({
							texts = gameMgr:getStrings(msg),
							showconfig = C_SHOW_CONFIG,
							onComplete = function ()
								performWithDelay(msgwin,function ()
									uiMgr:closeUI(msgui)
									if onComplete_ then onComplete_(false) end
								end,C_SHOW_DELAY)
							end
						})
					end
				end
			end
		end)
end

-- 地图上设置
function _FormationBase:setInMap(onComplete,fnSet)
	local extvars = {
		formation = formationMgr:getName(self.formation),
		role = self.role:getName()
	}
	if table.nums(self.role:getTeam():getRoles(),function (v) return not v:isDead() end) < 
		formationMgr:getSetRoles(self.formation) then
		uiMgr:openUI("message",{
			texts = gameMgr:getStrings("NOTSET_FORMATION",extvars),
			onComplete = function ()
				if onComplete then onComplete(false) end
			end
		})
	else
		local fsp = formationMgr:getSP(self.formation)
		if self.role:getTeam():tryConsumeSP(fsp) then
			fnSet(onComplete,extvars)
		else
			uiMgr:openUI("message",{
				texts = gameMgr:getStrings("LACK_SP"),
				onComplete = function ()
					if onComplete then onComplete(false) end
				end
			})
		end
	end
end

return _FormationBase
