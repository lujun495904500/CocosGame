--[[
	测试场景
--]]
local THIS_MODULE = ...

local TestScene = class("TestScene", require("app.main.modules.scene.SceneBase"))

-- 构造场景
function TestScene:ctor(onComplete)
	self._onInitialized = onComplete
	self:setup()

	self:addChild(self:createGridCoordinate())
	--self:addChild(self:createTestMap())
	--self:addChild(self:createTestModel())
	--self:addChild(self:createTestEffect())
	--self:addChild(self:createTestFont())
	self:addChild(self:createTestAudio())
	--self:addChild(self:createTestUI())
	--uiMgr:attach(self)
	--uiMgr:openOnly("message", {
	--	texts = { "关关雎鸠，在河之洲。窈窕淑女，君子好逑。" ,"参差荇菜，左右流之。窈窕淑女，寤寐求之。" },
	--	autoclose = true,
   -- })
	
	-- 完成初始化回调
	if self._onInitialized then 
		self._onInitialized(self)
	end
end

-- 析构场景
function TestScene:dtor(onComplete)
	self._onDestroyed = onComplete
	self:delete()
	if self._onDestroyed then
		self._onDestroyed(self)
	end
end

-- 创建网格坐标系
function TestScene:createGridCoordinate()
	local color = cc.c4f(1,1,0,1)
	local drawpanel = cc.DrawNode:create()  
	drawpanel:setLineWidth(1)
	drawpanel:drawLine(display.left_center,display.right_center,color)
	drawpanel:drawLine(display.top_center,display.top_bottom,color)

	local visible = true
	local function onKeyboard(keycode,event)
		local keydesc = cc.KeyCodeKey[keycode + 1]
		if keydesc == "KEY_C" then
		   visible = not visible
		   drawpanel:setVisible(visible)
		end
	end
	local KBlistener = cc.EventListenerKeyboard:create()
	KBlistener:registerScriptHandler(onKeyboard,cc.Handler.EVENT_KEYBOARD_PRESSED)
	drawpanel:getEventDispatcher():addEventListenerWithSceneGraphPriority(KBlistener,drawpanel)

	return drawpanel
end

-- 创建测试特效图层
function TestScene:createTestEffect()
	local effectlayer = cc.Layer:create()
	local label = cc.LabelTTF:create("", "Arial", 18)  
	label:setPosition(cc.p(display.cx,display.cy*1.9))  
	label:setColor(cc.c3b(255,0,0))
	label:enableShadow(cc.c3b(0,0,0), cc.size(0,-2), 1)  --阴影
	effectlayer:addChild(label)  

	local effnames = effectMgr:getAllEffects()
	local eindex = 1
	if effnames[eindex] then
		label:setString("[" .. effnames[eindex] .. "]")
	end

	local enemyeffect = false
	local function onKeyboard(keycode,event)
		local keydesc = cc.KeyCodeKey[keycode + 1]
		if keydesc == "KEY_SHIFT" or keydesc == "KEY_RIGHT_SHIFT" then
			enemyeffect = not enemyeffect
			printInfo("From Enemy : " .. tostring(enemyeffect))
		elseif keydesc == "KEY_LEFT_ARROW" then
			if eindex <= 1 then
				eindex = #effnames
			else
				eindex = eindex - 1
			end
			if effnames[eindex] then
				label:setString("[" .. effnames[eindex] .. "]")
			end
		elseif keydesc == "KEY_RIGHT_ARROW" then
			if eindex >= #effnames then
				eindex = 1
			else
				eindex = eindex + 1
			end
			if effnames[eindex] then
				label:setString("[" .. effnames[eindex] .. "]")
			end
		elseif keydesc == "KEY_ENTER" then
			if effnames[eindex] then
				local effect = effectMgr:createObject(effnames[eindex],{fromenemy=enemyeffect})
				effect:setPosition(display.center)
				effectlayer:addChild(effect)
			end
		end
	end
	local KBlistener = cc.EventListenerKeyboard:create()
	KBlistener:registerScriptHandler(onKeyboard,cc.Handler.EVENT_KEYBOARD_PRESSED)
	effectlayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(KBlistener,effectlayer)

	return effectlayer
end

-- 创建测试模型图层
function TestScene:createTestModel()
	local modellayer = cc.Layer:create()
	local label = cc.LabelTTF:create("", "Arial", 18)  
	label:setPosition(cc.p(display.cx,display.cy*1.9))  
	label:setColor(cc.c3b(255,0,0))
	label:enableShadow(cc.c3b(0,0,0), cc.size(0,-2), 1)  --阴影
	modellayer:addChild(label,100)  

	local modnames = modelMgr:getAllModels()
	
	local model = nil
	local mindex = 1
	if modnames[mindex] then
		label:setString("[" .. modnames[mindex] .. "]")
		model = modelMgr:createObject(modnames[mindex])
		modellayer:addChild(model)
		model:setPosition(display.center)
		model:mapWalk("DOWN")
	end

	local function onKeyboard(keycode,event)
		local keydesc = cc.KeyCodeKey[keycode + 1]
		if keydesc == "KEY_LEFT_ARROW" then
			if mindex <= 1 then
				mindex = #modnames
			else
				mindex = mindex - 1
			end
			if modnames[mindex] then
				label:setString("[" .. modnames[mindex] .. "]")
				if model then
					model:removeFromParent(true)
				end
				model = modelMgr:createObject(modnames[mindex])
				modellayer:addChild(model)
				model:setPosition(display.center)
				model:mapWalk("DOWN")
			end
		elseif keydesc == "KEY_RIGHT_ARROW" then
			if mindex >= #modnames then
				mindex = 1
			else
				mindex = mindex + 1
			end
			if modnames[mindex] then
				label:setString("[" .. modnames[mindex] .. "]")
				if model then
					model:removeFromParent(true)
				end
				model = modelMgr:createObject(modnames[mindex])
				modellayer:addChild(model)
				model:setPosition(display.center)
				model:mapWalk("DOWN")
			end
		else
			if model then
				if keydesc == "KEY_SHIFT" or keydesc == "KEY_RIGHT_SHIFT" then
					model:setEnemy(not model:isEnemy())
					printInfo("is Enemy : " .. tostring(model:isEnemy()))
				else
					if  keydesc == "KEY_W" then
						model:mapWalk("UP")
					elseif keydesc == "KEY_S" then
						model:mapWalk("DOWN")
					elseif keydesc == "KEY_A" then
						model:mapWalk("LEFT")
					elseif keydesc == "KEY_D" then
						model:mapWalk("RIGHT")
					elseif keydesc == "KEY_J" then
						model:battleAttack()
					elseif keydesc == "KEY_K" then
						model:battleDeath()
					elseif keydesc == "KEY_L" then
						model:battleStand()
					elseif keydesc == "KEY_P" then
						model:battleHurt()
					end
				end
			end
		end
	end
	local KBlistener = cc.EventListenerKeyboard:create()
	KBlistener:registerScriptHandler(onKeyboard,cc.Handler.EVENT_KEYBOARD_PRESSED)
	modellayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(KBlistener,modellayer)

	return modellayer
end

-- 创建测试地图图层
function TestScene:createTestMap()
	local maplayer = cc.Layer:create()
	local label = cc.LabelTTF:create("", "Arial", 18)  
	label:setPosition(cc.p(display.cx,display.cy*1.9))  
	label:setColor(cc.c3b(255,0,0))
	label:enableShadow(cc.c3b(0,0,0), cc.size(0,-2), 1)  --阴影
	maplayer:addChild(label,100)
	
	local mapnames = mapMgr:getAllMaps()
	local mapnode = nil
	local mindex = 1
	if mapnames[mindex] then
		label:setString("[" .. mapnames[mindex] .. "]")
		mapnode = mapMgr:createObject(mapnames[mindex])
		maplayer:addChild(mapnode)
		local mapsize = mapnode:getSize()
		mapnode:setPosition(cc.p(display.cx - mapsize.width/2, display.cy - mapsize.height/2))
	end

	local function onKeyboard(keycode,event)
		local keydesc = cc.KeyCodeKey[keycode + 1]
		if keydesc == "KEY_LEFT_ARROW" then
			if mindex <= 1 then
				mindex = #mapnames
			else
				mindex = mindex - 1
			end
			if mapnames[mindex] then
				label:setString("[" .. mapnames[mindex] .. "]")
				if mapnode then
					mapnode:removeFromParent(true)
				end
				mapnode = mapMgr:createObject(mapnames[mindex])
				maplayer:addChild(mapnode)
				local mapsize = mapnode:getSize()
				mapnode:setPosition(cc.p(display.cx - mapsize.width/2, display.cy - mapsize.height/2))
			end
		elseif keydesc == "KEY_RIGHT_ARROW" then
			if mindex >= #mapnames then
				mindex = 1
			else
				mindex = mindex + 1
			end
			if mapnames[mindex] then
				label:setString("[" .. mapnames[mindex] .. "]")
				if mapnode then
					mapnode:removeFromParent(true)
				end
				mapnode = mapMgr:createObject(mapnames[mindex])
				maplayer:addChild(mapnode)
				local mapsize = mapnode:getSize()
				mapnode:setPosition(cc.p(display.cx - mapsize.width/2, display.cy - mapsize.height/2))
			end
		end

		if mapnode then
			if keydesc == "KEY_W" then
				mapnode:moveBy({x=0,y=-100,time=0.3})
			elseif keydesc == "KEY_S" then
				mapnode:moveBy({x=0,y=100,time=0.3})
			elseif keydesc == "KEY_A" then
				mapnode:moveBy({x=100,y=0,time=0.3})
			elseif keydesc == "KEY_D" then
				mapnode:moveBy({x=-100,y=0,time=0.3})
			end
		end
	end
	local KBlistener = cc.EventListenerKeyboard:create()
	KBlistener:registerScriptHandler(onKeyboard,cc.Handler.EVENT_KEYBOARD_PRESSED)
	maplayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(KBlistener,maplayer)

	return maplayer
end

-- 创建测试UI图层
function TestScene:createTestUI()
	local uilayer = cc.Layer:create()
	uilayer:addChild(uiMgr)
	local label = cc.LabelTTF:create("", "Arial", 18)  
	label:setPosition(cc.p(display.cx,display.cy*1.9))  
	label:setColor(cc.c3b(255,0,0))
	label:enableShadow(cc.c3b(0,0,0), cc.size(0,-2), 1)  --阴影
	uilayer:addChild(label)  

	local uinames = uiMgr:getAllUIs()
	local uindex = 1
	if uinames[uindex] then
		label:setString("[" .. uinames[uindex] .. "]")
		uiMgr:openOnly(uinames[uindex])
	end

	local function onKeyboard(keycode,event)
		local keydesc = cc.KeyCodeKey[keycode + 1]
		if keydesc == "KEY_LEFT_ARROW" then
			if uindex <= 1 then
				uindex = #uinames
			else
				uindex = uindex - 1
			end
			if uinames[uindex] then
				label:setString("[" .. uinames[uindex] .. "]")
				uiMgr:openOnly(uinames[uindex])
			end
		elseif keydesc == "KEY_RIGHT_ARROW" then
			if uindex >= #uinames then
				uindex = 1
			else
				uindex = uindex + 1
			end
			if uinames[uindex] then
				label:setString("[" .. uinames[uindex] .. "]")
				uiMgr:openOnly(uinames[uindex])
			end
		end
	end
	local KBlistener = cc.EventListenerKeyboard:create()
	KBlistener:registerScriptHandler(onKeyboard,cc.Handler.EVENT_KEYBOARD_PRESSED)
	uilayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(KBlistener,uilayer)

	return uilayer
end

-- 创建测试字体图层
function TestScene:createTestFont()
	local fontlayer = cc.Layer:create()
	local label = cc.LabelTTF:create("", "Arial", 18)  
	label:setPosition(cc.p(display.cx,display.cy*1.9))  
	label:setColor(cc.c3b(255,0,0))
	label:enableShadow(cc.c3b(0,0,0), cc.size(0,-2), 1)  --阴影
	fontlayer:addChild(label)  

	local testtext = "0123456789 经验水平:(兵)(金)"
	local fontnames = fontMgr:getAllFonts()
	local fontlabel = nil
	local mindex = 1
	if fontnames[mindex] then
		label:setString("[" .. fontnames[mindex] .. "]")
		fontlabel = fontMgr:createLabel(fontnames[mindex],testtext)
		fontlayer:addChild(fontlabel)
		fontlabel:setPosition(display.center)
	end

	local function onKeyboard(keycode,event)
		local keydesc = cc.KeyCodeKey[keycode + 1]
		if keydesc == "KEY_LEFT_ARROW" then
			if mindex <= 1 then
				mindex = #fontnames
			else
				mindex = mindex - 1
			end
			if fontnames[mindex] then
				label:setString("[" .. fontnames[mindex] .. "]")
				if fontlabel then
					fontlabel:removeFromParent()
				end
				fontlabel = fontMgr:createLabel(fontnames[mindex],testtext)
				fontlayer:addChild(fontlabel)
				fontlabel:setPosition(display.center)
			end
		elseif keydesc == "KEY_RIGHT_ARROW" then
			if mindex >= #fontnames then
				mindex = 1
			else
				mindex = mindex + 1
			end
			if fontnames[mindex] then
				label:setString("[" .. fontnames[mindex] .. "]")
				if fontlabel then
					fontlabel:removeFromParent()
				end
				fontlabel = fontMgr:createLabel(fontnames[mindex],testtext)
				fontlayer:addChild(fontlabel)
				fontlabel:setPosition(display.center)
			end
		end
	end
	local KBlistener = cc.EventListenerKeyboard:create()
	KBlistener:registerScriptHandler(onKeyboard,cc.Handler.EVENT_KEYBOARD_PRESSED)
	fontlayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(KBlistener,fontlayer)

	return fontlayer
end

-- 创建音频测试图层
function TestScene:createTestAudio()
	local audiolayer = cc.Layer:create()
	audiolayer:setPosition(display.center)

	local bgmlabel = cc.LabelTTF:create("BGM[左,右,回车]:", "Arial", 25)  
	bgmlabel:setPosition(cc.p(0,display.cy*1/2))  
	audiolayer:addChild(bgmlabel)  
	local bgmname = cc.LabelTTF:create("", "Arial", 25)  
	bgmname:setPosition(cc.p(0,display.cy*1/2-30))  
	bgmname:setColor(cc.c3b(255,0,0))
	audiolayer:addChild(bgmname) 
	
	local bgmnames = audioMgr:getAllAudios()
	local bgmindex = 1
	if bgmnames[bgmindex] then
		bgmname:setString("[" .. bgmnames[bgmindex] .. "]")
	end
	
	local function onKeyboard(keycode,event)
		local keydesc = cc.KeyCodeKey[keycode + 1]
		if keydesc == "KEY_LEFT_ARROW" then
			if bgmindex <= 1 then
				bgmindex = #bgmnames
			else
				bgmindex = bgmindex - 1
			end
			if bgmnames[bgmindex] then
				bgmname:setString("[" .. bgmnames[bgmindex] .. "]")
			end
		elseif keydesc == "KEY_RIGHT_ARROW" then
			if bgmindex >= #bgmnames then
				bgmindex = 1
			else
				bgmindex = bgmindex + 1
			end
			if bgmnames[bgmindex] then
				bgmname:setString("[" .. bgmnames[bgmindex] .. "]")
			end
		
		elseif keydesc == "KEY_ENTER" then
			if bgmnames[bgmindex] then
				printInfo("play:%s",bgmnames[bgmindex])
				audioMgr:playBGM(bgmnames[bgmindex])
			end
		end
	end
	local KBlistener = cc.EventListenerKeyboard:create()
	KBlistener:registerScriptHandler(onKeyboard,cc.Handler.EVENT_KEYBOARD_PRESSED)
	audiolayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(KBlistener,audiolayer)

	return audiolayer
end

return TestScene
