--[[
	目标选择
]]
local THIS_MODULE = ...

local TargetSelect = class("TargetSelect", require("app.main.modules.ui.FrameBase"), 
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
function TargetSelect:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function TargetSelect:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function TargetSelect:reinitWidgets()
	self.wg_targetlist:setVisible(false)
end

--[[
	打开窗口
	onComplete	  完成回调
	config
		autoclose		自动关闭
		team			选择队伍
		role_dead		选择死亡角色
		role_normal		选择正常角色(默认)
		multisel		多选
]]
function TargetSelect:OnOpen(onComplete,config)
	self:reinitWidgets()
	
	local roles = config.team:getRoles()
	local adviser = config.team:getAdviser()

	-- 筛选候选角色
	local selectroles = {}
	for _,role in ipairs(roles) do 
		if role:isDead() then
			if config.role_dead then
				table.insert(selectroles,role)
			end
		else	-- normal
			if config.role_normal ~= false then
				table.insert(selectroles,role)
			end
		end
	end
	if #selectroles <= 0 then
		return onComplete(false)
	end

	-- 生成选择项
	local selectitems = {}
	for _,role in ipairs(selectroles) do
		table.insert(selectitems,{
			name = role:isDead() and (":" .. role:getName()) or role:getName(),
			adviser = (adviser==role),
			onTrigger = function()
				if config.autoclose then self:closeFrame() end
				onComplete(true, { role })
			end,
		})
	end
	-- 全选
	if config.multisel and #selectroles > 1 then
		table.insert(selectitems,{
			name = "[全选]",
			onTrigger = (function ()
				if config.autoclose then self:closeFrame() end
				onComplete(true, selectroles)
			end)
		})
	end

	self.wg_targetlist:sizeToRows(#selectitems)
	self.wg_targetlist:updateParams({
		items = selectitems,
		listener = {
			cancel = function()
				if config.autoclose then self:closeFrame() end
				onComplete(false)
			end
		}
	})
	self:pushFocusWidget(self.wg_targetlist)
end

-- 关闭窗口
function TargetSelect:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function TargetSelect:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function TargetSelect:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function TargetSelect:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return TargetSelect
