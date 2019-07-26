--[[
	选择目标
]]

local SelectTarget = class("SelectTarget", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function SelectTarget:ctor(config)
	table.merge(self,config)
end

-- 执行函数
function SelectTarget:execute(...) 
	if self.scene == "BATTLE" then
		self:executeInBattle(...)
	elseif self.scene == "MAP" then
		self:executeInMap(...)
	end
end

--[[
	战场上选择
	param			脚本参数
		message		显示消息
	role			使用角色
]]
function SelectTarget:executeInBattle(onComplete)
	local msgui = self.role:isEnemy() and "message" or "ourmessage"
	local selectteam = self.param.toenemy and 
		self.role:getTeam():getEnemyTeam() or self.role:getTeam()

	local function doSelect(onComplete_)
		selectteam:selectRoles(
			function (success,targets)
				if onComplete_ then
					if success then
						onComplete_(true,{ targets = targets })
					else
						if self.param.message then
							uiMgr:closeUI(msgui)
						end
						onComplete_(false)
					end
				end
			end,
			{
				role_normal = self.param.role_normal,
				role_dead = self.param.role_dead,
				multisel = self.param.multisel,
			}
		)
	end

	if self.param.message then
		uiMgr:openUI(msgui,{
			texts = gameMgr:getStrings(self.param.message),
			showconfig = {
				usecursor = true,	
				hidecsrlast = true,
				ctrl_complete = false
			},
			onComplete = function ()
				doSelect(function (...)
					if onComplete then onComplete(...) end
				end)
			end
		})
	else
		doSelect(onComplete)
	end
end

--[[
	地图上选择
	param			脚本参数
		message		显示消息
	role			使用角色
]]
function SelectTarget:executeInMap(onComplete)
	if self.param.toenemy then
		uiMgr:openUI("message",{
			autoclose = true,
			texts = gameMgr:getStrings("NOT_USE_HERE"),
			onComplete = function ()
				if onComplete then onComplete(false) end
			end
		})
	else
		local function doSelect(onComplete_)
			uiMgr:openUI("targetselect",function (success, targets)
				if onComplete_ then
					if success then
						onComplete_(true,{ targets = targets })
					else
						if self.param.message then
							uiMgr:closeUI("message")
						end
						uiMgr:closeUI("targetselect")
						onComplete_(false)
					end
				end
			end,{
				team = self.role:getTeam(),
				role_normal = self.param.role_normal,
				role_dead = self.param.role_dead,
				multisel = self.param.multisel,
			})
		end

		if self.param.message then
			uiMgr:openUI("message",{
				texts = gameMgr:getStrings(self.param.message),
				showconfig = {
					usecursor = true,	
					hidecsrlast = true,
					ctrl_complete = false
				},
				onComplete = function ()
					doSelect(function (...)
						if onComplete then onComplete(...) end
					end)
				end
			})
		else
			doSelect(onComplete)
		end
	end
end

return SelectTarget
