--[[
	升级
]]
local THIS_MODULE = ...

local LevelUp = class("LevelUp", require("app.main.modules.ui.FrameBase"), 
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
function LevelUp:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function LevelUp:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function LevelUp:reinitWidgets()
	self.wg_message:setVisible(false)
end

-- 打开窗口
function LevelUp:OnOpen(config)
	self:reinitWidgets()
	if config then
		self:openLevelUp(config)
	end
end

-- 关闭窗口
function LevelUp:OnClose()
	self:clearFocusWidgets()
end

--[[
	显示升级消息
	config 
		autoclose	自动关闭
		lvupmsgs	升级消息
		continue	继续消息
		onComplete	完成回调
]]
function LevelUp:openLevelUp(config)
	if config then
		local index = 1
		local operations = {}
		
		local function operateNext()
			if index <= #operations then
				operations[index]()
				index = index + 1
			else
				if config.autoclose then self:closeFrame() end
				if config.onComplete then config.onComplete() end
			end
		end
		
		-- 生成所有操作
		for i,lvupmsg in ipairs(config.lvupmsgs) do
			-- 等级提升
			table.insert(operations, function ()
				self.wg_message:ignoreControl(true)
				self.wg_message:showTexts(gameMgr:getStrings("LEVELUP_TEAM",
					{ 
						team = lvupmsg.team 
					}), 
					{
						usecursor = true, 
						onComplete = operateNext
					}
				)
				audioMgr:listenFinish(audioMgr:playSE(gameMgr:getLevelUpSE()),function()
					self.wg_message:ignoreControl(false)
				end)
			end)
			
			-- 兵力提升
			for j,role in ipairs(lvupmsg.roles) do
				table.insert(operations, function ()
					self.wg_message:showTexts(gameMgr:getStrings("LEVELUP_SOLDIERS", 
						{ 
							role = role.name, 
							soldier = role.soldiers 
						}),
						{
							usecursor = true, 
							onComplete = operateNext
						}
					)
				end)
			end
	
			-- 技能学习
			for j,role in ipairs(lvupmsg.roles) do
				for l,sid in ipairs(role.skills) do
					table.insert(operations, function ()
						self.wg_message:showTexts(gameMgr:getStrings("LEVELUP_LEARN", 
							{
								role = role.name, 
								learn = skillMgr:getName(sid)
							}), 
							{
								usecursor = true, 
								onComplete = operateNext
							}
						)
					end) 
				end
				for l,sid in ipairs(role.strategys) do
					table.insert(operations, function ()
						self.wg_message:showTexts(gameMgr:getStrings("LEVELUP_LEARN", 
							{
								role = role.name, 
								learn = strategyMgr:getName(sid)
							}), 
							{
								usecursor = true, 
								onComplete = operateNext
							}
						)
					end)
				end
				for l,fid in ipairs(role.formations) do
					table.insert(operations, function ()
						self.wg_message:showTexts(gameMgr:getStrings("LEVELUP_LEARN", 
							{
								role = role.name, 
								learn = formationMgr:getName(fid)
							}), 
							{
								usecursor = true, 
								onComplete = operateNext
							}
						)
					end)
				end
			end
	
			-- 谋略点
			table.insert(operations, function ()
				self.wg_message:showTexts(gameMgr:getStrings("LEVELUP_MSP", 
					{ 
						msp = lvupmsg.msp 
					}), 
					{
						usecursor = (i < #config.lvupmsgs) or config.continue, 
						onComplete = operateNext
					}
				)
			end)
		end
	
		self.wg_message:clearText()
		self:setFocusWidget(self.wg_message)
	
		operateNext()
	end
end

-- 获得焦点回调
function LevelUp:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function LevelUp:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function LevelUp:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return LevelUp
