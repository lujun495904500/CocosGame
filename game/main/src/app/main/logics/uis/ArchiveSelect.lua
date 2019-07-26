--[[
	存档选择
]]
local THIS_MODULE = ...

local ArchiveSelect = class("ArchiveSelect", require("app.main.modules.ui.FrameBase"), 
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
function ArchiveSelect:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function ArchiveSelect:dtor()
	self:delete()
	self:release()
end

-- 重新初始化所有组件
function ArchiveSelect:reinitWidgets()
	self.lb_title:setVisible(false)
	self.wg_archives:setVisible(false)
	self.wg_archselect:setVisible(false)
end

--[[
	打开窗口
	team		设置队伍
]]
function ArchiveSelect:OnOpen(team)
	self:reinitWidgets()
	
	self.lb_title:setVisible(true)
	self:setFocusWidget(self.wg_archives)
	self:updateArchives()
end

-- 刷新存档
function ArchiveSelect:updateArchives()
	local slots = {}
	local archives = archMgr:getArchives()
	
	local function newSlot()
		local slot = 1
		while true do
			if not slots[tostring(slot)] then
				return slot
			else
				slot = slot + 1
			end
		end
	end

	local architems = {}
	architems[#architems + 1] = { 
		new = true, 
		onTrigger = function ()
			self:selectNew(newSlot())
		end
	}
	for _,archive in ipairs(archives) do
		slots[archive.slot] = true
		architems[#architems + 1] = { 
			slot = archive.slot,
			name = archive.name,
			time = archive.time,
			version = archive.version,
			onTrigger = function ()
				self:selectArchive(archive.slot)
			end
		}
	end
	self.wg_archives:updateParams({
		items = architems,
		next = {
			next = true
		}
	})
end

-- 选择新存档
function ArchiveSelect:selectNew(newslot)
	uiMgr:openUI("textinput",{
		messages = gameMgr:getStrings("INPUT_ARCHNAME")[1],
		text = gameMgr:getStrings("NEW_ARCHIVE")[1],
		onComplete = function (result,text)
			if result then
				if text and text ~= "" then
					gameMgr:startNewGame(text,newslot)
				else
					uiMgr:openUI("message",{
						autoclose = true,
						texts = gameMgr:getStrings("ARCHNAME_NOEMPTY"),
					})
				end
			else
				uiMgr:closeUI("textinput")
			end
		end
	})
end

-- 选择存档
function ArchiveSelect:selectArchive(slot)
	self.wg_archselect:setListener({
		trigger = function(item_,pindex,index)
			if item_.type == "S" then
				gameMgr:startGame(slot)
			else -- D
				uiMgr:openUI("select",{
					autoclose = true,
					messages = gameMgr:getStrings("ARCHDELET_ENSURE"),
					selects = {
						{
							label = gameMgr:getStrings("CONFIRM")[1],
							type = "Y",
						},{
							label = gameMgr:getStrings("CANCEL")[1],
							type = "N",
						}
					},
					onComplete = function (result,item)
						if result and item.type == "Y" then
							archMgr:deleteArchive(slot)
							self.wg_archselect:setVisible(false)
							self:setFocusWidget(self.wg_archives)
							self:updateArchives()
						end
					end
				})
			end
		end,
		cancel = function ()
			self.wg_archselect:setVisible(false)
			self:setFocusWidget(self.wg_archives)
		end
	})
	self.wg_archselect:changeSelect(1)
	self:setFocusWidget(self.wg_archselect)
end

-- 关闭窗口
function ArchiveSelect:OnClose()
	self:clearFocusWidgets()
end

-- 获得焦点回调
function ArchiveSelect:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function ArchiveSelect:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function ArchiveSelect:onControlKey(keycode)
	if self._controller then
		self._controller(keycode)
	else
		self:onWidgetControlKey(keycode)
	end
end

return ArchiveSelect
