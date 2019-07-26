--[[
	启动 场景
]]
local THIS_MODULE = ...

-- 描述显示延迟
local C_DESC_SHOWDELAY = 2

-- 页面显示延迟
local C_PAGE_SHOWDELAY = 4

-- 头像资源索引
local C_HEAD_IPATH = "res/files/heads"

local BootScene = class("BootScene", require("app.main.modules.scene.SceneBase"),
	require("app.main.modules.common.ClassLayout"))

--[[
	构造场景
	onComplete		初始化完成回调
	config
]]
function BootScene:ctor(onComplete,config)
	self._onInitialized = onComplete
	if config then
		table.merge(self,config)
	end
	self:setup()
	self:setupBoot()
end

-- 析构场景
function BootScene:dtor(onComplete)
	self._onDestroyed = onComplete
	self:deleteBoot()
	self:delete()
end

-- 安装场景
function BootScene:setupBoot()
	self:setupLayout()

	-- 添加UI层
	uiMgr:attach(self)

	-- 添加控制层
	if not device.IS_WINDOWS then
		ctrlMgr:attachGamePad(self)
	end

	if self._onInitialized then 
		self._onInitialized(self)
	end
end

-- 删除场景
function BootScene:deleteBoot()
	-- 停止音乐
	audioMgr:stopBGM()

	-- 移除UI
	uiMgr:detach()
	
	if self._onDestroyed then 
		self._onDestroyed(self)
	end
end

-- 场景开始
function BootScene:onBegin()
	self:setBootStep(1)
end

-- 开始游戏简介
function BootScene:startBriefs()
	self.pl_boot:setVisible(false)
	self.pl_brief:setVisible(true)
	local stop = false	-- 结束

	-- 简介结束
	local function briefEnd()
		self._controller = nil
		audioMgr:stopBGM()
		self:setBootStep(1)
	end

	-- 控制监听
	self._controller = function (keycode)
		if keycode == ctrlMgr.KEY_START then
			self._controller = nil
			stop = true
		end
	end

	table.asyn_walk_sequence(briefEnd, table.range(math.ceil(#self.roles / 3)), function (onComplete,page)
		local bgindex = (page - 1) * 3 + 1
		table.asyn_walk_together(function ()
			if stop then return briefEnd() end
			performWithDelay(self,function ()
				table.asyn_walk_sequence(function ()
					if stop then return briefEnd() end
					performWithDelay(self,onComplete,C_PAGE_SHOWDELAY)
				end,table.range(bgindex, 3),function (_onComplete,index,i)
					local role = self.roles[index]
					if not role then
						_onComplete()
					else
						if stop then return briefEnd() end
						local desc = self["wg_desc" .. i]
						desc:setString(gameMgr:getStrings(role.desc)[1])
						performWithDelay(self,_onComplete,C_DESC_SHOWDELAY)
					end
				end)
			end,C_DESC_SHOWDELAY)
		end,table.range(bgindex, 3),function (_onComplete,index,i)
			local role = self.roles[index]
			if not role then
				self["pl_role" .. i]:setVisible(false)
				_onComplete()
			else
				self["pl_role" .. i]:setVisible(true)
				self["wg_desc" .. i]:setString("")
				local head = self["sp_head" .. i]
				head:setTexture(indexMgr:getIndex(C_HEAD_IPATH .. "/" .. gameMgr:getRoleHead(role.id)))
				head:setFlippedX((i % 2) == 0)
				local lastpos = cc.p(head:getPosition())
				local orgposx = (i % 2) == 0 and display.left or display.right
				head:runAction(cc.Sequence:create(
					cc.Place:create(cc.p(orgposx, lastpos.y)),
					cc.MoveTo:create(self.headtime,lastpos),
					cc.CallFunc:create(_onComplete)
				))
			end
		end)
	end)
end

-- 设置启动阶段
function BootScene:setBootStep(step)
	if step == 1 then
		self.pl_boot:setVisible(true)
		self.pl_brief:setVisible(false)

		self.sp_panel1:setVisible(false)
		self.sp_panel2:setVisible(false)
		self.sp_title:setVisible(true)
		self.sp_title:setOpacity(0)
		self.sp_title:runAction(cc.Sequence:create(
			cc.FadeIn:create(self.s1fade),
			cc.CallFunc:create(function ()
				self._controller = function (keycode)
					if keycode == ctrlMgr.KEY_START then
						self._controller = nil
						self:setBootStep(3)
					end
				end
			end),
			cc.DelayTime:create(self.s1delay),
			cc.FadeOut:create(self.s1fade),
			cc.CallFunc:create(function ()
				self._controller = nil
				self:setBootStep(2)
			end)
		))
	elseif step == 2 then
		self.sp_title:stopAllActions()
		self.sp_title:setVisible(false)
		self.sp_panel1:setVisible(true)
		local p1x,p1y = self.sp_panel1:getPosition()
		local p1size = self.sp_panel1:getContentSize()
		self.sp_panel1:runAction(cc.Sequence:create(
			cc.Place:create(cc.p(display.right + p1size.width/2, p1y)),
			cc.MoveTo:create(self.s2time1,cc.p(0,p1y)),
			cc.EaseBackOut:create(cc.MoveTo:create(self.s2time2,cc.p(p1x,p1y))),
			cc.CallFunc:create(function ()
				self:setBootStep(3)
			end)
		))
	elseif step == 3 then
		self.sp_title:stopAllActions()
		self.sp_title:setVisible(false)
		self.sp_panel1:stopAllActions()
		self.sp_panel1:setVisible(true)
		self.sp_panel2:setVisible(true)
		audioMgr:listenFinish(audioMgr:playBGM(self.s3bgm1,false),function ()
			audioMgr:playBGM(self.bootbgm)
			local function deleteTimer()
				if self._timer then
					scheduler:unscheduleScriptEntry(self._timer)
					self._timer = nil
				end
			end
			local function createTimer()
				if not self._timer then
					self._timer = scheduler:scheduleScriptFunc(function ()
						deleteTimer()
						self:startBriefs()
					end,self.briefdelay,false)
				end
			end
			createTimer()
			self._controller = function (keycode)
				if keycode == ctrlMgr.KEY_START then
					self._controller = nil
					self.sp_panel1:setVisible(false)
					self.sp_panel2:setVisible(false)
					deleteTimer()
					self:selectArchive()
				end
			end
		end)
	end
end

-- 选择存档
function BootScene:selectArchive()
	audioMgr:playBGM(self.archbgm)
	uiMgr:openUI("archiveselect")
end

-- 当输入键值
function BootScene:onControlKey(keycode)
	if self._controller then
		self._controller(keycode)
	end
end

return BootScene
