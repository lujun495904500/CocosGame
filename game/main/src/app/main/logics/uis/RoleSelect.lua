--[[
	角色选择
]]
local THIS_MODULE = ...

local RoleSelect = class("RoleSelect", require("app.main.modules.ui.FrameBase"), 
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
function RoleSelect:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function RoleSelect:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function RoleSelect:reinitWidgets()
	self.wg_rolelist:setVisible(false)
end

--[[
	打开窗口
	config
		autoclose	自动关闭
		team		选择队伍
		onComplete	完成回调
]]
function RoleSelect:OnOpen(config)
	self:reinitWidgets()
	
	local roles = config.team:getRoles()
	local adviser = config.team:getAdviser()
	local roleitems = {}
	for i,role in ipairs(roles) do
		roleitems[i] = {
			name = role:isDead() and (":" .. role:getName()) or role:getName(),
			adviser = (adviser==role),
			onTrigger = function()
				if config.autoclose then self:closeFrame() end
				if config.onComplete then 
					config.onComplete(true,role) 
				end
			end
		}
	end
	self.wg_rolelist:sizeToRows(#roleitems)
	self.wg_rolelist:updateParams({
		items = roleitems,
		listener = {
			cancel = function()
				if config.autoclose then self:closeFrame() end
				if config.onComplete then 
					config.onComplete(false) 
				end
			end
		}
	})
	self:setFocusWidget(self.wg_rolelist)
end

-- 关闭窗口
function RoleSelect:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function RoleSelect:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function RoleSelect:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function RoleSelect:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return RoleSelect
