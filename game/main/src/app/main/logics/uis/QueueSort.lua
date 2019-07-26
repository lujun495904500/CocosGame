--[[
	队列排序
]]
local THIS_MODULE = ...

local Stack = require("app.main.modules.common.Stack")
local QueueSort = class("QueueSort", require("app.main.modules.ui.FrameBase"), 
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
function QueueSort:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function QueueSort:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function QueueSort:reinitWidgets()
	self.wg_rolelist:setVisible(false)
	self.wg_sortlist:setVisible(false)
end

--[[
	打开窗口
	team		排序队伍
]]
function QueueSort:OnOpen(team)
	self:reinitWidgets()
	local updateLists = nil

	local roles = team:getRoles()
	local adviser = team:getAdviser()
	self.wg_rolelist:sizeToRows(#roles)
	self.wg_sortlist:sizeToRows(#roles)
	local queueStack = Stack:create()
	local roleview = {}
	local sortview = {}
	if #roles > 0  then
		for i,role in ipairs(roles) do 
			roleview[i] = {
				name = role:isDead() and (":" .. role:getName()) or role:getName(),
				adviser = (adviser == role),
				id = role:getID(),
			}
		end
		roleview.select = 1
	end

	updateLists = function ()
		local roleitems = {}
		local sortitems = {}
		for i,roleinfo in ipairs(roleview) do 
			roleitems[i] = {
				name = roleinfo.name,
				adviser = roleinfo.adviser,
				onTrigger = function(item,pindex,index)
					roleview.select = index
					queueStack:push(clone(roleview))
					sortview[#sortview + 1] = roleview[index]
					table.remove(roleview,index)
					roleview.select = #roleview > 0 and 1 or 0
					updateLists()
					if #roleview == 0 then
						local roleids = {}
						for _,sortinfo in ipairs(sortview) do 
							roleids[#roleids + 1] = sortinfo.id
						end
						team:sortRoles(roleids)
					end
				end
			}
		end
		for i,sortinfo in ipairs(sortview) do 
			sortitems[i] = {
				name = sortinfo.name,
				adviser = sortinfo.adviser
			}
		end
		self.wg_rolelist:updateParams({
			items = roleitems,
			listener = {
				cancel = function()
					if #roleview == #roles or #roleview == 0 then
						self:closeFrame()
					else
						roleview = queueStack:top()
						queueStack:pop()
						sortview[#sortview] = nil
						updateLists()
					end
				end
			}
		})
		if roleview.select > 0 then
			self.wg_rolelist:changeSelect(roleview.select)
		end
		self.wg_sortlist:updateParams({
			items = sortitems
		})
	end

	updateLists()
	self.wg_sortlist:setVisible(true)
	self:setFocusWidget(self.wg_rolelist)
end

-- 关闭窗口
function QueueSort:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function QueueSort:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function QueueSort:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function QueueSort:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return QueueSort
