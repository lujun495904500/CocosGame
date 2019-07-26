--[[
	剧情对话
]]
local THIS_MODULE = ...

local Dialogue = class("Dialogue", require("app.main.modules.ui.FrameBase"), 
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
function Dialogue:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function Dialogue:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function Dialogue:reinitWidgets()
	self.wg_message:setVisible(false)
	self.wg_select:setVisible(false)
end

-- 打开窗口
function Dialogue:OnOpen(config)
	self:reinitWidgets()
	if config then
		self:openTalk(config)
	end
end

-- 关闭窗口
function Dialogue:OnClose()
	self:clearFocusWidgets()
end

--[[
	打开指定对话
	config 
		autoclose	自动关闭
		talks		对话
		epoints		事件点
		scripts		脚本对象
		onComplete	完成回调
]]
function Dialogue:openTalk(config)
	if config then
		local showtext = false
		local runcommand = false
		local runselect = false
		local runscript = false
		local nextTalk = nil
		local index = 0
	
		nextTalk = function()
			if not showtext and not runselect and not runcommand and not runscript then
				if index + 1 <= #config.talks then
					index = index + 1
					local talk = config.talks[index]
					if talk.msg then
						showtext = true
						local talkmsgs = nil
						if talk.msg:byte(1) == 0x23 then
							talkmsgs = gameMgr:getStrings(talk.msg:sub(2))
						else
							local msg = gameMgr:parseString(talk.msg)
							talkmsgs = { msg }
						end
						self.wg_message:showTexts(talkmsgs, {
							usecursor = true, 
							hidecsrlast = not talk.cursor,
							ctrl_complete = not talk.noctrl,
							onComplete = function()
								showtext = false
								nextTalk()
							end,
						})
					end
					if talk.cmds then
						runcommand = true
						for _,cmd in ipairs(talk.cmds) do 
							if cmd.type == "SELECT" then
								runselect = true
								local selitems = {}
								for i,select in ipairs(cmd.selects) do 
									selitems[i] = {
										label = select.label,
										onTrigger = (function()
											config.talks = dbMgr.talks[select.id]
											index = 0
											self.wg_select:setVisible(false)
											self:popFocusWidget()
											runselect = false
											nextTalk()
										end)
									}
								end
								self.wg_select:sizeToRows(#selitems)
								self.wg_select:updateParams({ 
									items = selitems,
									listener = {
										cancel = function ()
											if cmd.cancel then
												config.talks = dbMgr.talks[cmd.cancel]
												index = 0
												self.wg_select:setVisible(false)
												self:popFocusWidget()
												runselect = false
												nextTalk()
											end
										end
									}
								})
								self:pushFocusWidget(self.wg_select)
							elseif cmd.type == "TALK" then
								config.talks = dbMgr.talks[cmd.id]
								index = 0
							elseif cmd.type == "EPOINT" then
								archMgr:setEventPoint(cmd.value,unpack(config.epoints[cmd.index]))
							elseif cmd.type == "SCRIPT" then
								runscript = true
								local function scriptEnd()
									runscript = false
									nextTalk()
								end
								local sconf = config.scripts[cmd.index]
								local script = scriptMgr:createObject(sconf.script,sconf.config)
								if script then
									script:execute(scriptEnd,unpack(cmd.param or {}))
								else
									scriptEnd()
								end
							end
						end
						runcommand = false
						nextTalk()
					end
				else
					if config.autoclose then self:closeFrame() end
					if config.onComplete then config.onComplete() end
				end
			end
		end

		self.wg_message:clearText()
		self:pushFocusWidget(self.wg_message)
		nextTalk()
	end
end

-- 获得焦点回调
function Dialogue:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function Dialogue:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function Dialogue:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return Dialogue
