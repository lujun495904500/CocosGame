--[[
	控制管理器
--]]
local THIS_MODULE = ...
local C_LOGTAG = "ControlManager"

-- 键码表
local KEYCODE = {
	KEY_UP 		= bit.lshift(1,0),
	KEY_DOWN 	= bit.lshift(1,1),
	KEY_LEFT 	= bit.lshift(1,2),
	KEY_RIGHT 	= bit.lshift(1,3),
	KEY_A 		= bit.lshift(1,4),
	KEY_B 		= bit.lshift(1,5),
	KEY_SELECT 	= bit.lshift(1,6),
	KEY_START 	= bit.lshift(1,7),
	KEY_EXIT 	= bit.lshift(1,8),
}

local GamePad = require("app.main.modules.control.GamePad")
local ControlManager = class("ControlManager", KEYCODE)

-- 键盘默认码表
local KEYBOARD_DEFAULT = {
	KEY_W 			= KEYCODE.KEY_UP,
	KEY_S 			= KEYCODE.KEY_DOWN,
	KEY_A 			= KEYCODE.KEY_LEFT,
	KEY_D 			= KEYCODE.KEY_RIGHT,
	KEY_J 			= KEYCODE.KEY_A,
	KEY_K 			= KEYCODE.KEY_B,
	KEY_F 			= KEYCODE.KEY_SELECT,
	KEY_H 			= KEYCODE.KEY_START,
	KEY_ESCAPE 		= KEYCODE.KEY_EXIT,
	KEY_BACKSPACE 	= KEYCODE.KEY_EXIT,
}

-- 控制器默认码表
local CONTROLLER_DEFAULT = {
	[cc.ControllerKey.BUTTON_A] 			= KEYCODE.KEY_A, 
	[cc.ControllerKey.BUTTON_B] 			= KEYCODE.KEY_B, 
	[cc.ControllerKey.BUTTON_SELECT] 		= KEYCODE.KEY_SELECT, 
	[cc.ControllerKey.BUTTON_START] 		= KEYCODE.KEY_START, 
	[cc.ControllerKey.BUTTON_DPAD_UP] 		= KEYCODE.KEY_UP,
	[cc.ControllerKey.BUTTON_DPAD_DOWN]		= KEYCODE.KEY_DOWN,
	[cc.ControllerKey.BUTTON_DPAD_LEFT] 	= KEYCODE.KEY_LEFT, 
	[cc.ControllerKey.BUTTON_DPAD_RIGHT] 	= KEYCODE.KEY_RIGHT, 
}

-- 获得单例对象
local instance = nil
function ControlManager:getInstance()
	if instance == nil then
		instance = ControlManager:create()
	end
	return instance
end

-- 构造函数
function ControlManager:ctor()
	self:clearTargets()
	self:clearPressed()

	self._keyboardmap = {}
	for key,code in pairs(KEYBOARD_DEFAULT) do 
		self._keyboardmap[key] = code
	end

	self._controllermap = {}
	for key,code in pairs(CONTROLLER_DEFAULT) do 
		self._controllermap[key] = code
	end

	self:setupKeyboard()
end

-- 清除按下状态
function ControlManager:clearPressed()
	self._keyboardpressed = {}
	self._touchpressed = {}
	self._ctrlrpressed = {}
end

-- 测试键码是否被按下
function ControlManager:testPressed(code)
	return self._keyboardpressed[code] or self._touchpressed[code] or self._ctrlrpressed[code]
end

-- 设置触摸屏按下状态
function ControlManager:setTouchPress(code,press)
	self._touchpressed[code] = press
	if press then
		self:onControlKey(code)
	end
end

-- 设置键盘按下状态
function ControlManager:setKeyBoardPress(code,press)
	self._keyboardpressed[code] = press
	if press then
		self:onControlKey(code)
	end
end

-- 设置控制器按下状态
function ControlManager:setControllerPress(code,press)
	self._ctrlrpressed[code] = press
	if press then
		self:onControlKey(code)
	end
end

---------------------键盘---------------------

-- 安装键盘事件
function ControlManager:setupKeyboard()
	local function onKeyPressed(keycode,event)
		local code = self._keyboardmap[cc.KeyCodeKey[keycode + 1]]
		if code then
			self:setKeyBoardPress(code,true)
		end
	end
	local function onKeyReleased(keycode,event)
		local code = self._keyboardmap[cc.KeyCodeKey[keycode + 1]]
		if code then
			self:setKeyBoardPress(code,false)
		end
	end
	self._kblistener = cc.EventListenerKeyboard:create()
	self._kblistener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
	self._kblistener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
	director:getEventDispatcher():addEventListenerWithFixedPriority(self._kblistener, KEYBOARD.PRI)

	logMgr:info(C_LOGTAG, "enable keyboard input")
end

-- 删除键盘事件
function ControlManager:deleteKeyboard()
	if self._kblistener then
		director:getEventDispatcher():removeEventListener(self._kblistener)
		self._kblistener = nil

		logMgr:info(C_LOGTAG, "disable keyboard input")
	end
end

----------------------------------------------

--------------------控制器--------------------

-- 安装控制器事件
function ControlManager:setupController()

	local function onConnectController(controller, event)
		if controller then
			self._controller = controller
		end
	end

	local function onDisconnectedController(controller, event)
		if self._controller == controller then
			self._controller = nil
		end
	end

	local function onKeyDown(controller, keyCode, event)
		if self._controller == controller then
			local code = self._controllermap[keyCode]
			if code then
				self:setControllerPress(code,true)
			end
		end
	end

	local function onKeyUp(controller, keyCode, event)
		if self._controller == controller then
			local code = self._controllermap[keyCode]
			if code then
				self:setControllerPress(code,false)
			end
		end
	end

	self._ctrllistener = cc.EventListenerController:create()
	self._ctrllistener:registerScriptHandler(onConnectController, cc.Handler.EVENT_CONTROLLER_CONNECTED)
	self._ctrllistener:registerScriptHandler(onDisconnectedController, cc.Handler.EVENT_CONTROLLER_DISCONNECTED)
	self._ctrllistener:registerScriptHandler(onKeyDown, cc.Handler.EVENT_CONTROLLER_KEYDOWN)
	self._ctrllistener:registerScriptHandler(onKeyUp, cc.Handler.EVENT_CONTROLLER_KEYUP)
	--self._ctrllistener:registerScriptHandler(onAxisEvent, cc.Handler.EVENT_CONTROLLER_AXIS)

	director:getEventDispatcher():addEventListenerWithFixedPriority(self._ctrllistener, CONTROLLER.PRI)

	cc.Controller:startDiscoveryController()
end

-- 删除控制器事件
function ControlManager:deleteController()
	if self._ctrllistener then
		cc.Controller:stopDiscoveryController()

		director:getEventDispatcher():removeEventListener(self._ctrllistener)
		self._ctrllistener = nil
		self._controller = nil

		logMgr:info(C_LOGTAG, "disable controller input")
	end
end

----------------------------------------------
-- 创建游戏控制器
function ControlManager:attachGamePad(scene,order)
	scene:addChild(GamePad:create(),order or 0)
end

-- 按键控制操作
function ControlManager:onControlKey(keycode)
	if self._target then
		self._target:onControlKey(keycode)
	end
end

-- 设置控制目标
function ControlManager:setTarget(target)
	if self._target ~= target then
		if self._target then
			self._target:onLostFocus()
		end
		if target then
			target:onGetFocus()
		end
		self._target = target
	end
end

-- 获得控制目标
function ControlManager:getTarget()
	return self._target
end

-- 把当前目录压栈
function ControlManager:pushTarget(target)
	if self._target then
		table.insert(self._targets, self._target)
	end
	self:setTarget(target)
end

-- 弹出栈中的目标
function ControlManager:popTarget()
	self:setTarget(nil)
	if #self._targets > 0 then
		self:setTarget(table.remove(self._targets))
	end
end

-- 清空所有目标
function ControlManager:clearTargets()
	self._target = nil
	self._targets = {}
end

return ControlManager
