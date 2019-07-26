--[[
	军师设置
]]
local THIS_MODULE = ...

local AdviserSet = class("AdviserSet", require("app.main.modules.ui.FrameBase"), 
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
function AdviserSet:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function AdviserSet:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function AdviserSet:reinitWidgets()
	self.wg_rolelist:setVisible(false)
end

--[[
	打开窗口
	team		设置队伍
]]
function AdviserSet:OnOpen(team)
	self:reinitWidgets()
	local updateRoleList = nil 

	updateRoleList = function (option)
		local roles = team:getRoles()
		local adviser = team:getAdviser()
		local roleitems = {}
		for i,role in ipairs(roles) do
			roleitems[i] = {
				name = role:isDead() and (":" .. role:getName()) or role:getName(),
				adviser = (adviser==role),
				onTrigger = function()
					local extvars = {
						select = role:getName()
					}
					if adviser == role then
						team:setAdviserID("0")
						updateRoleList({ 
							pageindex = self.wg_rolelist:getPageIndex(),
							selindex = self.wg_rolelist:getSelectIndex(), 
						})
						uiMgr:openUI("message",{
							autoclose = true,
							texts = gameMgr:getStrings("RELIEVE_ADVISER", extvars),
							onComplete = function() self:closeFrame() end
						})
					elseif not role:isDead() and role:getIntellect() >= dbMgr.configs.advintmin then
						team:setAdviserID(role:getID())
						updateRoleList({ 
							pageindex = self.wg_rolelist:getPageIndex(),
							selindex = self.wg_rolelist:getSelectIndex(), 
						})
						uiMgr:openUI("message",{
							autoclose = true,
							texts = gameMgr:getStrings("APPOINT_ADVISER", extvars),
							onComplete = function() self:closeFrame() end
						})
					else
						uiMgr:openUI("message",{
							autoclose = true,
							texts = gameMgr:getStrings("NOT_APPOINT_ADVISER", extvars),
						})
					end
				end
			}
		end
		self.wg_rolelist:sizeToRows(#roleitems)
		self.wg_rolelist:updateParams(table.merge({
			items = roleitems,
			listener = {
				cancel = function()
					self:closeFrame()
				end
			}
		},option))
	end
	
	updateRoleList()
	self:setFocusWidget(self.wg_rolelist)
end

-- 关闭窗口
function AdviserSet:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function AdviserSet:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function AdviserSet:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function AdviserSet:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return AdviserSet
