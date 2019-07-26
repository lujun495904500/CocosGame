--[[
	地图功能
]]
local THIS_MODULE = ...

local MapFunction = class("MapFunction", require("app.main.modules.ui.FrameBase"), 
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
function MapFunction:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function MapFunction:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function MapFunction:reinitWidgets()
	self.wg_functions:setVisible(false)
end

-- 打开窗口
function MapFunction:OnOpen(map)
	self:reinitWidgets()
	
	self.wg_functions:setListener({
		trigger = function(item_,pindex,index)
			local itype = item_.type
			if itype == "T" then
				self:closeFrame()
				map:getMajorTeam():tryTalk(false,majorTeam:getAlive(1))
			elseif itype == "R" then
				self:closeFrame()
				map:getMajorTeam():tryResearch(false)
			elseif itype == "Q" then
				self:closeFrame()
				uiMgr:openUI("queueoption",{
					autoclose = true,
					onComplete = function(result,item_,pindex,index)
						if result then
							if item_.type == "Q" then
								uiMgr:openUI("queuesort",majorTeam)
							else	-- A
								uiMgr:openUI("adviserset",majorTeam)
							end
						end
					end
				})
			elseif itype == "M" then
				self:closeFrame()
				uiMgr:openUI("roleselect",{
					autoclose = true,
					team = majorTeam,
					onComplete = function(result,role)
						if result then
							uiMgr:openUI("roleattribute",role)
						end
					end
				})
			elseif itype == "I" then
				self:closeFrame()
				uiMgr:openUI("itemoperate",map,map:getMajorTeam())
			else	-- S
				self:closeFrame()
				if not majorTeam:getAdviser() then
					uiMgr:openUI("message",{
						autoclose = true,
						texts = gameMgr:getStrings("NO_ADVISER"),
					})
				else
					uiMgr:openUI("strategyoption",{
						autoclose = true,
						onComplete = function(result,item_,pindex,index)
							if result then
								if item_.type == "S" then
									uiMgr:openUI("mapstrategy",majorTeam,"S")
								else	-- F
									uiMgr:openUI("mapstrategy",majorTeam,"F")
								end
							end
						end
					})
				end
			end
		end,
		cancel = function()
			self:closeFrame()
		end
	})
	self.wg_functions:changeSelect(1)
	self:setFocusWidget(self.wg_functions)
end

-- 关闭窗口
function MapFunction:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function MapFunction:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function MapFunction:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function MapFunction:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return MapFunction
