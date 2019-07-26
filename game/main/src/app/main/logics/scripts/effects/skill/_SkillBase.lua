--[[
	技能基类
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

local _SkillBase = class("_SkillBase", require("app.main.modules.script.ScriptBase"))

-- 地图目标使用效果
function _SkillBase:effectTargetsInMap(onComplete,targets,fnEffect)
	if #targets <= 0 then
		if onComplete then onComplete(true) end
	else
		local extvars = {
			role = self.role:getName(),
			skill = skillMgr:getName(self.skill),
		}

		if self.role:getTeam():tryConsumeSP(self.sp) then
			table.asyn_walk_sequence(function ()
				if onComplete then onComplete(true) end
			end,targets,function (onComplete_,target)
				fnEffect(onComplete_,target,extvars)
			end)
		else
			uiMgr:openUI("message",{
				texts = gameMgr:getStrings("LACK_SP",extvars),
				onComplete = function ()
					if onComplete then onComplete(false) end
				end
			})
		end
	end
end

-- 战场动作
function _SkillBase:doActionInBattle(onComplete,isgatking,doAction)
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

-- 战场目标使用效果
function _SkillBase:effectTargetsInBattle(onComplete,targets,fnEffect)
	self:doActionInBattle(onComplete,self.role:getScene():isGeneralAttack(),function (onComplete_,isgatking)
		if #targets <= 0 or self.role:getTeam():isNoStrategy() then
			onComplete_()
		else
			local msgui = self.role:isEnemy() and "message" or "ourmessage"
			local extvars = {
				role = self.role:getEntity():getName(),
				skill = skillMgr:getName(self.skill),
			}
			if self.role:getEntity():getTeam():tryConsumeSP(self.sp) then
				table.asyn_walk_sequence(onComplete_,targets,function (onComplete__,target)
					if self.role:isDead() or self.role:getTeam():isNoStrategy() then
						onComplete_()
					else
						if target:isStrategyNo() then
							onComplete__(true)
						elseif target:isStrategyBack() and (target:isEnemy() ~= self.role:isEnemy()) then
							fnEffect(onComplete__,self.role,isgatking,msgui,extvars,C_SHOW_CONFIG)
						else
							fnEffect(onComplete__,target,isgatking,msgui,extvars,C_SHOW_CONFIG)
						end
					end
				end)
			else
				if isgatking then
					onComplete_()
				else
					local msgwin = uiMgr:openUI(msgui)
					local msg = self.role:getEntity():getTeam():getAdviser() and "LACK_SP" or "NO_ADVISER"
					msgwin:showMessage({
						texts = gameMgr:getStrings(msg),
						showconfig = C_SHOW_CONFIG,
						onComplete = function ()
							performWithDelay(msgwin,function ()
								uiMgr:closeUI(msgui)
								onComplete_()
							end,C_SHOW_DELAY)
						end
					})
				end
			end
		end
	end)
end

return _SkillBase
