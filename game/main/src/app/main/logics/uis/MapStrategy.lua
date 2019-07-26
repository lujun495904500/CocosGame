--[[
	地图策略
]]
local THIS_MODULE = ...

local MapStrategy = class("MapStrategy", require("app.main.modules.ui.FrameBase"), 
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
function MapStrategy:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function MapStrategy:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function MapStrategy:reinitWidgets()
	self.wg_strategys:setVisible(false)
	self.wg_formations:setVisible(false)
end

--[[
	打开窗口
	team	使用的队伍
	type	S/F 策略或阵形
]]
function MapStrategy:OnOpen(team,type)
	self:reinitWidgets()
	
	local function useStrategy(config,effect)
		local usescript = effect and scriptMgr:createObject(
			effect.script,
			table.merge({
				scene = "MAP",
				role = team:getAdviser(),
				param = effect.param
			},config)) or nil
		if usescript then
			usescript:execute(function (success)
				if not success or config.skill then
					uiMgr:closeAll(self:getName())
				else
					uiMgr:closeAll()
				end
			end)
		else
			dump(table.merge({
				effect = effect
			},config),"not found strategy effect",2)
		end
	end

	local function selectStrategy(config,effect,action)
		if config.sp > team:getSP() then
			uiMgr:openUI("message",{
				autoclose = true,
				texts = gameMgr:getStrings("LACK_SP"),
				onComplete = function()
					uiMgr:closeAll()
				end
			})
		else
			if action and action.script then
				scriptMgr:createObject(
					action.script,
					table.merge({
						scene = "MAP",
						role = team:getAdviser(),
						param = action.param,
					},config)
				):execute(function (success,actconf)
					if success then
						useStrategy(table.merge(actconf,config),effect)
					end
				end)
			else
				useStrategy(config,effect)
			end
		end
	end

	if type == "S" then
		local styitems = {}

		-- 技能
		local skills = team:getSkills()
		for _,k in ipairs({"F","W","S","H"}) do
			local skill = skills[k]
			if skill then
				if skillMgr:isMapUsable(skill) then
					table.insert(styitems,{
						label = skillMgr:getName(skill),
						onTrigger = (function(_item,pindex,index)
							selectStrategy(
								{ 
									skill = skill,
									sp = skillMgr:getSP(skill),
								},{
									script = skillMgr:getScript(skill,"effect"),
									param = skillMgr:getParam(skill,"effect"),
								},{
									script = skillMgr:getScript(skill,"action"),
									param = skillMgr:getParam(skill,"action"),
								}
							)
						end)
					})
				end
			end
		end

		-- 策略
		local strategys = team:getStrategys()
		for _,sid in ipairs(strategys) do
			if strategyMgr:isMapUsable(sid) then
				table.insert(styitems,{
					label = strategyMgr:getName(sid),
					onTrigger = (function(_item,pindex,index)
						selectStrategy(
							{ 
								strategy = sid,
								sp = strategyMgr:getSP(sid),
							},{
								script = strategyMgr:getScript(sid,"effect"),
								param = strategyMgr:getParam(sid,"effect"),
							},{
								script = strategyMgr:getScript(sid,"action"),
								param = strategyMgr:getParam(sid,"action"),
							}
						)
					end)
				})
			end
		end

		if #styitems > self.wg_strategys:getItemRows() then
			self.wg_strategys:sizeToRows(#styitems)
		end
		self.wg_strategys:updateParams({
			items = styitems,
			listener = {
				cancel = function()
					self:closeFrame()
				end
			}
		})
		self:setFocusWidget(self.wg_strategys)
	else	-- F
		local fmtitems = {}

		local formations = team:getFormations()
		for _,fid in ipairs(formations) do
			if formationMgr:isMapUsable(fid) then
				table.insert(fmtitems,{
					label = formationMgr:getName(fid),
					onTrigger = (function(_item,pindex,index)
						selectStrategy(
							{ 
								formation = fid,
								sp = formationMgr:getSP(fid),
							},{
								script = formationMgr:getScript(fid,"effect"),
								param = formationMgr:getParam(fid,"effect"),
							},{
								script = formationMgr:getScript(fid,"action"),
								param = formationMgr:getParam(fid,"action"),
							}
						)
					end)
				})
			end
		end

		if #fmtitems > self.wg_formations:getItemRows() then
			self.wg_formations:sizeToRows(#fmtitems)
		end
		self.wg_formations:updateParams({
			items = fmtitems,
			listener = {
				cancel = function()
					self:closeFrame()
				end
			}
		})
		self:setFocusWidget(self.wg_formations)
	end
end

-- 关闭窗口
function MapStrategy:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function MapStrategy:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function MapStrategy:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function MapStrategy:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return MapStrategy
