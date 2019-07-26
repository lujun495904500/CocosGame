--[[
	战场策略
]]
local THIS_MODULE = ...

local BattleStrategy = class("BattleStrategy", require("app.main.modules.ui.FrameBase"), 
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
function BattleStrategy:ctor(config)
	self:setup(config)
	self:retain()
	self:initFrame()
end

-- 析构函数
function BattleStrategy:dtor()
	self:delete()
	self:release()
end

-- 初始化窗口
function BattleStrategy:initFrame()
	self:setFocusWidget(self.wg_strategys)
end

--[[
	打开窗口
	config 
		role		使用角色
		sp			SP值
		onComplete	完成回调
]]
function BattleStrategy:OnOpen(config)
	local team = config.role:getEntity():getTeam()
	local skills = team:getSkills()
	local formations = team:getFormations()
	local strategys = team:getStrategys()
	local showSkills = nil
	local showFormations = nil
	local showStrategys = nil

	local function useStrategy(config_,effect)
		local usescript = effect and scriptMgr:createObject(
			effect.script,
			table.merge({ 
				scene = "BATTLE",
				role = config.role,
				param = effect.param 
			},config_)) or nil
		if usescript then
			config.role:setRoundAction(usescript)
			self:closeFrame()
			if config.onComplete then 
				config.onComplete(true,config_.sp) 
			end
		else
			dump(config_,"not found strategy effect",2)
			self:closeFrame()
			if config.onComplete then 
				config.onComplete(false) 
			end
		end
	end

	local function selectStrategy(config_,effect,action)
		if config_.sp > config.sp then
			uiMgr:openUI("ourmessage",{
				autoclose = true,
				texts = gameMgr:getStrings("LACK_SP"),
			})
		else
			if action and action.script then
				scriptMgr:createObject(
					action.script,
					table.merge({ 
						scene = "BATTLE",
						role = config.role,
						param = action.param 
					},config_)
				):execute(function (success,actconf)
					if success then
						useStrategy(table.merge(actconf,config_),effect)
					end
				end)
			else
				useStrategy(config_,effect)
			end
		end
	end
	
	-- 显示技能
	showSkills = function()
		local skillitems = {}
		-- 火攻
		if not skills.F then
			table.insert(skillitems,{ label = "" })
		else
			table.insert(skillitems,{
				label = skillMgr:getName(skills.F),
				onTrigger = (function(item,pindex,index)
					selectStrategy(
						{ 
							skill = skills.F,
							sp = skillMgr:getSP(skills.F),
						},
						{
							script = skillMgr:getScript(skills.F,"effect"),
							param = skillMgr:getParam(skills.F,"effect"),
						},
						{
							script = skillMgr:getScript(skills.F,"action"),
							param = skillMgr:getParam(skills.F,"action"),
						}
					)
				end)
			})
		end
		-- 水攻
		if not skills.W then
			table.insert(skillitems,{ label = "" })
		else
			table.insert(skillitems,{
				label = skillMgr:getName(skills.W),
				onTrigger = (function(item,pindex,index)
					selectStrategy(
						{ 
							skill = skills.W,
							sp = skillMgr:getSP(skills.W),
						},
						{
							script = skillMgr:getScript(skills.W,"effect"),
							param = skillMgr:getParam(skills.W,"effect"),
						},
						{
							script = skillMgr:getScript(skills.W,"action"),
							param = skillMgr:getParam(skills.W,"action"),
						}
					)
				end)
			})
		end
		-- 落石
		if not skills.S then
			table.insert(skillitems,{ label = "" })
		else
			table.insert(skillitems,{
				label = skillMgr:getName(skills.S),
				onTrigger = (function(item,pindex,index)
					selectStrategy(
						{ 
							skill = skills.S,
							sp = skillMgr:getSP(skills.S),
						},
						{
							script = skillMgr:getScript(skills.S,"effect"),
							param = skillMgr:getParam(skills.S,"effect"),
						},
						{
							script = skillMgr:getScript(skills.S,"action"),
							param = skillMgr:getParam(skills.S,"action"),
						}
					)
				end)
			})
		end
		-- 恢复
		if not skills.H then
			table.insert(skillitems,{ label = "" })
		else
			table.insert(skillitems,{
				label = skillMgr:getName(skills.H),
				onTrigger = (function(item,pindex,index)
					selectStrategy(
						{ 
							skill = skills.H,
							sp = skillMgr:getSP(skills.H),
						},
						{
							script = skillMgr:getScript(skills.H,"effect"),
							param = skillMgr:getParam(skills.H,"effect"),
						},
						{
							script = skillMgr:getScript(skills.H,"action"),
							param = skillMgr:getParam(skills.H,"action"),
						}
					)
				end)
			})
		end
		-- 阵形
		table.insert(skillitems,{
			label="阵形",
			onTrigger = (function(item,pindex,index)
				showFormations()
			end)
		})
		-- 谋略
		table.insert(skillitems,{
			label="谋略",
			onTrigger = (function(item,pindex,index)
				showStrategys()
			end)
		})

		self.wg_strategys.lb_spval:setString(tostring(config.sp))
		self.wg_strategys:updateParams({
			items = skillitems,
			listener = {
				cancel = function()
					self:closeFrame()
					if config.onComplete then 
						config.onComplete(false) 
					end
				end
			}
		})
	end
	
	-- 显示阵形
	showFormations = function()
		local formationitems = {}
		for _,fid in ipairs(formations) do
			if formationMgr:isBattleUsable(fid) then
				table.insert(formationitems,{
					label= formationMgr:getName(fid),
					onTrigger = (function(item,pindex,index)
						if #config.role:getTeam():getAliveRoles() < formationMgr:getSetRoles(fid) then
							uiMgr:openUI("ourmessage",{
								autoclose = true,
								texts = gameMgr:getStrings("NOTSET_FORMATION",{
									role = config.role:getEntity():getName()
								}),
							})
						else
							selectStrategy(
								{ 
									formation = fid,
									sp = formationMgr:getSP(fid),
								},
								{
									script = formationMgr:getScript(fid,"effect"),
									param = formationMgr:getParam(fid,"effect"),
								},
								{
									script = formationMgr:getScript(fid,"action"),
									param = formationMgr:getParam(fid,"action"),
								}
							)
						end
					end)
				})
			end
		end

		self.wg_strategys.lb_spval:setString(tostring(config.sp))
		self.wg_strategys:updateParams({
			items = formationitems,
			next = { label = "..." },
			listener = {
				cancel = function()
					showSkills()
				end
			}
		})
	end

	-- 显示策略
	showStrategys = function()
		local strategyitems = {}
		for _,sid in ipairs(strategys) do
			if strategyMgr:isBattleUsable(sid) then
				table.insert(strategyitems,{
					label= strategyMgr:getName(sid),
					onTrigger = (function(item,pindex,index)
						selectStrategy(
							{ 
								strategy = sid,
								sp = strategyMgr:getSP(sid),
							},
							{
								script = strategyMgr:getScript(sid,"effect"),
								param = strategyMgr:getParam(sid,"effect"),
							},
							{
								script = strategyMgr:getScript(sid,"action"),
								param = strategyMgr:getParam(sid,"action"),
							}
						)
					end)
				})
			end
		end

		self.wg_strategys.lb_spval:setString(tostring(config.sp))
		self.wg_strategys:updateParams({
			items = strategyitems,
			next = { label = "..." },
			listener = {
				cancel = function()
					showSkills()
				end
			}
		})
	end

	showSkills()
end

-- 获得焦点回调
function BattleStrategy:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function BattleStrategy:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function BattleStrategy:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return BattleStrategy
