--[[
	包列表
]]
local THIS_MODULE = ...

local S_CLOSEKEYS = bit.bor(ctrlMgr.KEY_A,ctrlMgr.KEY_B)
local S_LASTKEYS = bit.bor(ctrlMgr.KEY_UP,ctrlMgr.KEY_LEFT)
local S_NEXTKEYS = bit.bor(ctrlMgr.KEY_DOWN,ctrlMgr.KEY_RIGHT)

local PackList = class("PackList", require("app.main.modules.ui.FrameBase"))

--[[
	构造函数
	config
		params		额外参数
		name		名称
		csb			csb文件
		widgets		组件表
		bindings	绑定表
]]
function PackList:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function PackList:dtor()
	self:delete()
	self:release()
end

--[[
	打开窗口
	config
		text		显示的文本
		color		文本颜色
		percent		进度
]]
function PackList:OnOpen(config)
	self._page = 1
	self:buildPackItems()
	self:updatePacks()
end

-- 构建包项目
function PackList:buildPackItems()
	if self._packsid ~= packMgr:getIdentify() then
		self._packsid = packMgr:getIdentify()

		local bootpack = packMgr:getBootPack()
		self._packitems = {
			{
				type = self.text.bootpack,
				name = bootpack.name,
				version = bootpack.version,
				level = 0,
			}
		}
		for _,pack in pairs(packMgr:getPacks()) do
			local isbase = packMgr:isBasePack(pack.name)
			self._packitems[#self._packitems + 1] = {
				type = isbase and self.text.basepack or self.text.funpack,
				name = pack.name,
				version = pack.version,
				level = isbase and 1 or 2,
			}
		end

		--[[
		for i = 1,10 do
			self._packitems[#self._packitems + 1] = {
				type = self.text.funpack,
				name = "test" .. i,
				version = 1000000,
				level = 2 + i,
			}
		end
		--]]

		table.sort(self._packitems,function (a,b)
			return a.level < b.level
		end)
	end
end

-- 更新包列表
function PackList:updatePacks()
	local pagepacks = self.wg_packlist:getItemRows() - 1

	self:setLastPage(self._page > 1)
	self:setNextPage(self._page * pagepacks < #self._packitems)

	local items = { self.titleitem }
	for i = 1, pagepacks do
		local item = self._packitems[(self._page - 1) * pagepacks + i]
		if item then
			items[#items + 1] = item
		end
	end
	self.wg_packlist:updateParams({
		items = items
	})
end

-- 设置可否向上翻页
function PackList:setLastPage(enable)
	self._lastpage = enable
	self.sp_last:stopAllActions()
	self.sp_last:setVisible(enable)
	if enable then
		self.sp_last:runAction(cc.Sequence:create(
			cc.Show:create(),cc.DelayTime:create(self.cursordelay),
			cc.CallFunc:create(function() 
				self.sp_last:runAction(cc.RepeatForever:create(cc.Blink:create(1,self.cursorrate)))
			end)))
	end
end

-- 设置可否向下翻页
function PackList:setNextPage(enable)
	self._nextpage = enable
	self.sp_next:stopAllActions()
	self.sp_next:setVisible(enable)
	if enable then
		self.sp_next:runAction(cc.Sequence:create(
			cc.Show:create(),cc.DelayTime:create(self.cursordelay),
			cc.CallFunc:create(function() 
				self.sp_next:runAction(cc.RepeatForever:create(cc.Blink:create(1,self.cursorrate)))
			end)))
	end
end

-- 输入处理
function PackList:onControlKey(keycode)
	if bit.band(keycode,S_CLOSEKEYS) ~= 0 then
		self:closeFrame()
	elseif bit.band(keycode,S_LASTKEYS) ~= 0 then
		if self._lastpage then
			self._page = self._page - 1
			self:updatePacks()
		end
	elseif bit.band(keycode,S_NEXTKEYS) ~= 0 then
		if self._nextpage then
			self._page = self._page + 1
			self:updatePacks()
		end
	end
end

return PackList
