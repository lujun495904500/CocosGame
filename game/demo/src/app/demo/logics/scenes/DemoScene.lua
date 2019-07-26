--[[
	战斗场景
]]
local THIS_MODULE = ...

-- 切换特效
local C_TRANSITION = {
	method = "FADE",
	time = 0.4,
}

local DemoScene = class("DemoScene", require("app.main.modules.scene.SceneBase"), 
	require("app.main.modules.common.ClassLayout"),
	require("app.main.modules.uiwidget.UIWidgetFocusable"))

--[[
	构造场景
	onComplete	  初始化完成回调
	config
		
]]
function DemoScene:ctor(onComplete,config)
	self._onInitialized = onComplete
	if config then
		table.merge(self,config)
	end
	self:setup()
	self:setupDemo()
end

-- 析构场景
function DemoScene:dtor(onComplete)
	self._onDestroyed = onComplete
	self:delete()
	self:deleteDemo()
end

-- 安装DEMO
function DemoScene:setupDemo()
	self:setupLayout()

	self.sp_1:setVisible(false)
	self.sp_2:setVisible(false)
	self.sp_2_e:setVisible(false)
	self.sp_3:setVisible(false)
	self.sp_3_e:setVisible(false)
	
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

-- 删除DEMO
function DemoScene:deleteDemo()
	-- 移除UI
	uiMgr:detach()

	if self._onDestroyed then 
		self._onDestroyed(self)
	end
end

-- 场景开始
function DemoScene:onBegin()
	self:setDemoStep(1)
end

-- 设置DEMO阶段
function DemoScene:setDemoStep(step)
	if step == 1 then
		audioMgr:playBGM(self.bgm)
		uiMgr:openUI("demomessage",{
			autoclose = true,
			texts = gameMgr:getStrings("DEMO_PLAY_1"),
			onComplete = function ()
				self:setDemoStep(2)
			end
		})
	elseif step == 2 then
		self.sp_1:setVisible(true)
		self.sp_1:setOpacity(0)
		self.sp_1:runAction(cc.Sequence:create(
			cc.FadeIn:create(self.fadetime),
			cc.CallFunc:create(function ()
				uiMgr:openUI("demomessage",{
					autoclose = true,
					texts = gameMgr:getStrings("DEMO_PLAY_2"),
					onComplete = function ()
						self:setDemoStep(3)
					end
				})
			end)
		))
	elseif step == 3 then
		self.sp_1:setVisible(false)
		self.sp_2:setVisible(true)
		self.sp_2:setOpacity(0)
		self.sp_2:runAction(cc.Sequence:create(
			cc.FadeIn:create(self.fadetime),
			cc.CallFunc:create(function ()
				self.sp_2_e:setVisible(true)
				uiMgr:openUI("demomessage",{
					autoclose = true,
					texts = gameMgr:getStrings("DEMO_PLAY_3"),
					onComplete = function ()
						self:setDemoStep(4)
					end
				})
			end)
		))
	elseif step == 4 then
		self.sp_2:setVisible(false)
		self.sp_2_e:setVisible(false)
		self.sp_3:setVisible(true)
		self.sp_3:setOpacity(0)
		self.sp_3:runAction(cc.Sequence:create(
			cc.FadeIn:create(self.fadetime),
			cc.CallFunc:create(function ()
				self.sp_3_e:setVisible(true)
				uiMgr:openUI("demomessage",{
					autoclose = true,
					texts = gameMgr:getStrings("DEMO_PLAY_4"),
					onComplete = function ()
						self:setDemoStep(5)
					end
				})
			end)
		))
	elseif step == 5 then
		self.sp_3:setVisible(false)
		self.sp_3_e:setVisible(false)
		uiMgr:openUI("demomessage",{
			autoclose = true,
			texts = gameMgr:getStrings("DEMO_PLAY_5"),
			onComplete = function ()
				self:enterInitMap()
			end
		})
	end
end

-- 进入初始化地图
function DemoScene:enterInitMap()
	-- 初始化主角队伍
	local role = nil
	majorTeam:setName("刘备军")

	role = tools:createRole("C1")
	majorTeam:joinRole(role)
	role:addLuggage(tools:createItem("I1"))
	role:addLuggage(tools:createItem("I46"))
	role:addLuggage(tools:createItem("I54"))
	role:addLuggage(tools:createItem("I61"))

	role = tools:createRole("C2")
	majorTeam:joinRole(role)
	role:addLuggage(tools:createItem("I37"))
	role:addLuggage(tools:createItem("I46"))
	role:addLuggage(tools:createItem("I54"))
	role:addLuggage(tools:createItem("I61"))

	role = tools:createRole("C3")
	majorTeam:joinRole(role)
	role:addLuggage(tools:createItem("I19"))
	role:addLuggage(tools:createItem("I46"))
	role:addLuggage(tools:createItem("I54"))
	role:addLuggage(tools:createItem("I61"))

	role = tools:createRole("C6")
	majorTeam:joinRole(role)
	role:addLuggage(tools:createItem("I1"))
	role:addLuggage(tools:createItem("I46"))
	role:addLuggage(tools:createItem("I54"))
	role:addLuggage(tools:createItem("I61"))

	role = tools:createRole("C12")
	majorTeam:joinRole(role)
	role:addLuggage(tools:createItem("I1"))
	role:addLuggage(tools:createItem("I46"))
	role:addLuggage(tools:createItem("I54"))
	role:addLuggage(tools:createItem("I61"))

	majorTeam:setAdviserID(role:getID())

	-- 初始化地图
	gameMgr:setMapEnv("region","region_xuzhou")
	gameMgr:setMapEnv("region_in","p_xuzhou")
	gameMgr:setMapEnv("town","town_xuzhou")
	gameMgr:setMapEnv("town_in","p_palace")
	gameMgr:setMapEnv("outtype",nil)
	gameMgr:setMapEnv("palacemap","build_palace")
	local initmap = {
		mapname = "build_palace",
		inpos = "p_revive",
		inmethod = "LINE",
		inface = "UP",
	}
	gameMgr:setMapEnv("archivemap",initmap)
	archMgr:setEventPoint(true,unpack(tools:parseEPoint("SHOW_PREFACE")))
	archMgr:saveArchive()   -- 保存存档
	
	sceneMgr:setTransition(C_TRANSITION)
	sceneMgr:switchScene("MapScene",initmap)
end

-- 当输入键值
function DemoScene:onControlKey(keycode)
	if self._controller then
		self._controller(keycode)
	end
end

return DemoScene
