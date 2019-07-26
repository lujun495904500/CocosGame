--[[
	战斗 攻击
]]

-- 显示延时
local C_SHOW_DELAY = 0.5

-- 公式 攻击命中
local C_ATTACK_HIT = "ATTACK_HIT"

-- 公式 攻击奋战
local C_ATTACK_EXCITED = "ATTACK_EXCITED"

-- 公式 攻击伤害
local C_ATTACK_DAMAGE = "ATTACK_DAMAGE"

-- 攻击波动
local C_ATTACK_SWING = 0.1

local Attack = class("Attack", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Attack:ctor(config)
	table.merge(self,config)
end

-- 执行脚本 
function Attack:execute(onComplete)
	self._isgatking = self.role:getScene():isGeneralAttack()	-- 总攻
	self._extexcited = self.extexcited or 0					 -- 额外兴奋值

	self._weapon = self.role:getEntity():getAvailableWeapon()
	self._attackse = self._weapon and self._weapon:getWeaponSE("attack") or nil
	self._hitse = self._weapon and self._weapon:getWeaponSE("hit") or gameMgr:getDefaultHitSE()
	self._hiteffect = self._weapon and self._weapon:getWeaponEffect("hit") or gameMgr:getDefaultHitEffect()
	self._atktimes = self.role:getEntity():getAttackTimes()

	local function _beforeAttack(onComplete_)
		if self._isgatking then
			onComplete_()
		else
			self.role:selectForward(true,onComplete_)
		end
	end

	local function _doAttack(onComplete_)
		if self.role:getTeam():isNoAttack() then
			onComplete_()
		else
			self:doAttack(onComplete_)
		end
	end

	local function _afterAttack(onComplete_)
		if self._isgatking then
			onComplete_()
		else
			self.role:selectForward(false,onComplete_)
		end
	end

	_beforeAttack(function ()
		_doAttack(function ()
			_afterAttack(function ()
				if onComplete then onComplete() end
			end)
		end)
	end)
end

-- 执行攻击动作
function Attack:doAttack(onComplete)
	local target = self.targets[1]

	table.asyn_walk_sequence(onComplete,table.range(self._atktimes),function (onComplete_,i)
		if self.role:isDead() or self.role:getTeam():isNoAttack() then
			if onComplete then onComplete() end
		else
			if target:isDead() then
				target = self.role:getTeam():getEnemyTeam():getAliveRole(target:getPlace()) -- 搜索下一个存活的目标
			end
			
			if not target then
				if onComplete then onComplete() end
			else
				if target:isAttackNo() then
					onComplete_(false)
				elseif target:isAttackBack() then
					self:attackTarget(self.role,onComplete_)
				else
					self:attackTarget(target,onComplete_)
				end
			end
		end
	end)
end

-- 攻击指定目标
function Attack:attackTarget(target,onComplete)
	if target:isDead() then
		if onComplete then onComplete(true) end
	else
		local excited = formulaMgr:calculate(C_ATTACK_EXCITED,{
			extexcited = self._extexcited,
		})
		self._extexcited = 0
		local hitse = excited and gameMgr:getExcitedHitSE() or self._hitse
		local hiteffect = excited and gameMgr:getExcitedtHitEffect() or self._hiteffect
		local ishit = nil
		local damages = 0

		ishit = formulaMgr:calculate(C_ATTACK_HIT,{
			excited = excited,
			defensing = target:isRoundDefending(),
			attrmax = gameMgr:getAttributeMax(),
		},{
			force = self.role:getEntity():getForce(),
			speed = self.role:getSpeed(),
			dodge = self.role:getDodge(),
		},{
			force = target:getEntity():getForce(),
			speed = target:getSpeed(),
			dodge = target:getDodge(),
		})
		if ishit then
			damages = math.floor(formulaMgr:calculate(C_ATTACK_DAMAGE,{
				excited = excited,
				defensing = target:isRoundDefending(),
				attrmax = gameMgr:getAttributeMax(),
			},{
				soldiers = self.role:getEntity():getSoldiers(),
				force = self.role:getEntity():getForce(),
				attack = self.role:getAttack(),
				defense = self.role:getDefense(),
			},{
				soldiers = target:getEntity():getSoldiers(),
				force = target:getEntity():getForce(),
				attack = target:getAttack(),
				defense = target:getDefense(),
			}))
			damages = damages > 0 and damages or 1
		end
		
		-- 统计
		local function doStatistics(losses,isdead)
			self.role:doStatistics("damage",losses)
			self.role:doStatistics("p_damage",losses)
			target:doStatistics("hurt",losses)
			target:doStatistics("p_hurt",losses)
			target:doStatistics("hatred",self.role)
			if isdead then
				self.role:doStatistics("kill")
				target:doStatistics("dead")
			end
		end

		if self._isgatking then
			local function attackEnd()
				if onComplete then onComplete(true) end
			end
			local function balanceAttack()
				target:getEntity():lostSoldiers(tools:getSwingRand(damages,C_ATTACK_SWING),function (losses,isdead)
					doStatistics(losses,isdead)
					attackEnd()
				end)
			end
			local function onAttacked()
				audioMgr:playSE(hitse)
				target:onAttacked(hiteffect,balanceAttack)
			end 
			if ishit then
				onAttacked()
			else
				attackEnd()
			end
		else
			local extvars = {
				role = self.role:getEntity():getName(),
				target = target:getEntity():getName(),
			}
			local showconfig = {
				usecursor		= false, 
				usesound		= false,
				quickshow		= true,
				linefeed		= true,
				ctrl_quick		= false,
				ctrl_complete	= false,
			}
		
			local msgui =  self.role:isEnemy() and "message" or "ourmessage" 
			local msgwin = uiMgr:openUI(msgui)
			msgwin:clearMessage()

			local function attackEnd()
				performWithDelay(msgwin,function ()
					uiMgr:closeUI(msgui)
					if onComplete then onComplete(true) end
				end,C_SHOW_DELAY)
			end

			local function balanceAttack()
				target:getEntity():lostSoldiers(tools:getSwingRand(damages,C_ATTACK_SWING),function (losses,isdead)
					doStatistics(losses,isdead)
					extvars.losses = losses
					msgwin:appendMessage({
						texts = gameMgr:getStrings("TARGET_LOSSES",extvars),
						showconfig = showconfig,
						onComplete = function ()
							if isdead then
								performWithDelay(msgwin,function ()
									msgwin:showMessage({
										texts = gameMgr:getStrings("TARGET_BEATED",extvars),
										showconfig = showconfig,
										onComplete = attackEnd,
									})
								end,C_SHOW_DELAY)
							else
								attackEnd()
							end
						end,
					})
				end)
			end

			local function onAttacked()
				if excited then
					msgwin:appendMessage({
						texts = gameMgr:getStrings("ROLE_ATTACK_EXCITED",extvars),
						showconfig = showconfig,
						onComplete = function ()
							audioMgr:playSE(hitse)
							target:onAttacked(hiteffect,balanceAttack)
						end,
					})
				else
					audioMgr:playSE(hitse)
					target:onAttacked(hiteffect,balanceAttack)
				end
			end 
			
			msgwin:appendMessage({
				texts = gameMgr:getStrings("ROLE_ATTACK",extvars),
				showconfig = showconfig,
				onComplete = function ()
					local function attackMiss()
						performWithDelay(msgwin,function ()
							msgwin:appendMessage({
								texts = gameMgr:getStrings("ATTACK_FAILURE",extvars),
								showconfig = showconfig,
								onComplete = attackEnd,
							})
						end,C_SHOW_DELAY)
					end
					if ishit then
						if self._weapon then
							audioMgr:playSE(self._attackse)
							self.role:doAttack(onAttacked)
						else
							onAttacked()
						end
					else
						if self._weapon then
							self.role:doAttack(attackMiss)
						else
							attackMiss()
						end
					end
				end
			})
		end
	end
end

return Attack
