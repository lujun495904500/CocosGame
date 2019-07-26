--[[
	战场 功能
]]
local THIS_MODULE = ...
local C_LOGTAG = "BattleFunction"

-- 显示延时
local C_SHOW_DELAY = 0.5

-- 公式 战斗撤退
local C_BATTLE_RETREAT = "BATTLE_RETREAT"

local BattleFunction = class("BattleFunction", require("app.main.modules.ui.FrameBase"), 
	require("app.main.modules.uiwidget.UIWidgetFocusable"))

--[[
	构造函数
	config
		params		额外参数
		name		名称
		csb			csb文件
		widgets		组件表
		bindings	绑定表
]]
function BattleFunction:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function BattleFunction:dtor()
	self:delete()
	self:release()
end

-- 打开窗口
function BattleFunction:OnOpen(battle)
	local ourteam = battle:getOurTeam()
	local enemyteam = battle:getEnemyTeam()
	local ctrlroles = ourteam:getControlableRoles()
	local ctrlindex = 0
	local spval = ourteam:getEntity():getSP()
	local lastspval = spval
	local spbacks = {}
	local lastOperation = nil
	local nextOperation = nil
	
	-- SP栈操作
	local function pushSP()
		table.insert(spbacks, lastspval)
		lastspval = spval
	end
	local function popSP()
		lastspval = table.remove(spbacks)
		spval = lastspval
	end

	-- 显示指定角色操作
	local function showOperation(role,first) 
		local functions = first and self.wg_functions_f or self.wg_functions

		functions:setListener({
			trigger = function(item_,pindex,index)
				local itype = item_.type
				if itype == "A" then
					enemyteam:selectRoles(function(success,targets)
						if success then
							local atkscript = scriptMgr:createObject(role:getAttackScript(),{
								scene = "BATTLE",
								role = role,
								targets = targets,
							})
							if atkscript then 
								role:setRoundAction(atkscript)
							else
								logMgr:warn(C_LOGTAG, "not found attack effect")
							end
							nextOperation()
						end
					end)
				elseif itype == "G" then
					role:selectForward(false,function ()
						uiMgr:closeAll()
						battle:hideBattleHead()
						battle:openGeneralAttack(function (result,victeam)
							if result then
								battle:onBattleResult(victeam)
							else
								battle:selectAction()
							end
						end)
					end)
				elseif itype == "D" then
					local defscript = scriptMgr:createObject(role:getDefenseScript(),{
						scene = "BATTLE",
						role = role,
					})
					if defscript then
						role:setRoundAction(defscript)
						role:setRoundSpeed(gameMgr:getDefenseSpeed())
					else
						logMgr:warn(C_LOGTAG, "not found defense effect")
					end
					nextOperation()
				elseif itype == "S" then
					if ourteam:getEntity():getAdviser() then
						uiMgr:openUI("battlestrategy",{
							role = role,
							sp = spval,
							onComplete = function (success,usesp)
								uiMgr:closeAll(self:getName())
								if success then
									spval = spval - usesp
									nextOperation()
								end
							end
						})
					else
						uiMgr:openUI("ourmessage",{
							autoclose = true,
							texts = gameMgr:getStrings("NO_ADVISER"),
						})
					end
				elseif itype == "M" then
					enemyteam:selectRoles(function(success,targets)
						if success then
							uiMgr:openUI("roleattribute",targets[1]:getEntity())
						end
					end)
				elseif itype == "I" then
					uiMgr:openUI("battleitemuse",{
						role = role,
						onComplete = function (success)
							uiMgr:closeAll(self:getName())
							if success then
								nextOperation()
							end
						end
					})
				else -- T
					role:selectForward(false,function ()
						uiMgr:closeAll()
						battle:hideBattleHead()

						local showconfig = {
							usecursor	   = false, 
							usesound		= false,
							quickshow	   = true,
							linefeed		= true,
							ctrl_quick	  = false,
							ctrl_complete   = false,
						}
						local retreat = formulaMgr:calculate(C_BATTLE_RETREAT,{

						},{

						},{

						})
						local msgwin = uiMgr:openUI("ourmessage")
						msgwin:showMessage({
							texts = gameMgr:getStrings("TEAM_RETREAT",{ team = ourteam:getEntity():getName() }),
							showconfig = showconfig,
							onComplete = function ()
								if retreat then
									battle:retreatSuccess()
								else
									performWithDelay(msgwin,function ()
										msgwin:appendMessage({
											texts = gameMgr:getStrings("RETREAT_HUNT"),
											showconfig = showconfig,
											onComplete = function ()
												performWithDelay(msgwin,function ()
													uiMgr:closeUI("ourmessage")
													battle:openRetreatHunt(enemyteam,function (result,victeam)
														if result then
															battle:onBattleResult(victeam)
														else
															battle:selectAction()
														end
													end)
												end,C_SHOW_DELAY)
											end
										})
									end,C_SHOW_DELAY)
								end
							end
						})
					end)
				end
			end,
			cancel = function()
				if not lastOperation() then
					role:selectForward(false,function ()
						uiMgr:closeAll()
						battle:hideBattleHead()
						battle:onCancelAction()
					end)
				end
			end
		})
		functions:changeSelect(1)
		self:setFocusWidget(functions)

		battle:showBattleHead(role)
	end

	-- 选择上一个角色操作
	lastOperation = function()
		self.wg_functions_f:setVisible(false)
		self.wg_functions:setVisible(false)
		self:setFocusWidget(nil)
		if ctrlindex - 1 > 0 then
			popSP()
			if ctrlindex >= 1 then
				battle:hideBattleHead()
				ctrlroles[ctrlindex]:selectForward(false)
			end
			ctrlindex = ctrlindex - 1
			ctrlroles[ctrlindex]:selectForward(true,function ()
				ctrlroles[ctrlindex]:clearRoundData()
				showOperation(ctrlroles[ctrlindex],ctrlindex == 1)
			end)
			return true
		end
		return false
	end

	-- 选择下一个角色操作
	nextOperation = function()
		self.wg_functions_f:setVisible(false)
		self.wg_functions:setVisible(false)
		self:setFocusWidget(nil)
		if ctrlindex + 1 <= #ctrlroles then
			pushSP()
			if ctrlindex >= 1 then
				battle:hideBattleHead()
				ctrlroles[ctrlindex]:selectForward(false)
			end
			ctrlindex = ctrlindex + 1
			ctrlroles[ctrlindex]:selectForward(true,function ()
				showOperation(ctrlroles[ctrlindex],ctrlindex == 1)
			end)
		else
			ctrlroles[ctrlindex]:selectForward(false,function ()
				uiMgr:closeAll()
				battle:hideBattleHead()
				battle:openAttack({
					onComplete = function (result,victeam)
						if result then
							battle:onBattleResult(victeam)
						else
							battle:selectAction()
						end
					end
				})
			end)
		end
	end

	nextOperation()
end

-- 关闭窗口
function BattleFunction:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function BattleFunction:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function BattleFunction:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function BattleFunction:onControlKey(keycode)
	if ctrlMgr:testPressed(ctrlMgr.KEY_START) then
		if ctrlMgr:testPressed(ctrlMgr.KEY_SELECT) then
			uiMgr:openUI("gamemenu")
			return ctrlMgr:clearPressed()
		end
		
		-- 开发调试
		if FLAG.DEVELOPMENT then	
			
		end
	end

	if keycode == ctrlMgr.KEY_EXIT then
		gameMgr:ensureExitGame()
	else
		self:onWidgetControlKey(keycode)
	end
end

return BattleFunction
