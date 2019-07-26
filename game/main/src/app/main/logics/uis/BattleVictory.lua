--[[
	战斗胜利
]]
local THIS_MODULE = ...

-- 显示延时
local C_SHOW_DELAY = 0.5

local BattleVictory = class("BattleVictory", require("app.main.modules.ui.FrameBase"), 
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
function BattleVictory:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function BattleVictory:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function BattleVictory:reinitWidgets()
	self.wg_message:setVisible(false)
	self.wg_teaminfo:setVisible(false)
end

--[[
	打开窗口
	config
		ourteam			我方队伍
		enemyteam		敌方队伍
		golds			金币
		exps			经验
		continue		继续消息
		onComplete		完成回调
]]
function BattleVictory:OnOpen(config)
	self:reinitWidgets()
	self.wg_message:clearText()
	self:setFocusWidget(self.wg_message)

	self.team_golds:setString(config.ourteam:getGolds())
	self.team_exps:setString(config.ourteam:getExps())

	local function balanceBattle()
		performWithDelay(self,function ()
			self.wg_message:showTexts(gameMgr:getStrings("BATTLE_BALANCE",{
				exps = config.exps,
				golds = config.golds,
			}),{
				usecursor = true,
				hidecsrlast = not config.continue,
				ctrl_complete = config.continue,
				appendEnd = function ()
					self.wg_teaminfo:setVisible(true)
				end,
				onComplete = config.onComplete
			})
		end,C_SHOW_DELAY)
	end

	self.wg_message:showTexts(gameMgr:getStrings("BATTLE_VICTORY",{
		our = config.ourteam:getName(),
		enemy = config.enemyteam:getName(),
	}),{
		ctrl_complete = false,
		onComplete = balanceBattle
	})
end

-- 关闭窗口
function BattleVictory:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function BattleVictory:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function BattleVictory:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function BattleVictory:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return BattleVictory
