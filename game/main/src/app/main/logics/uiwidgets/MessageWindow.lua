--[[
	消息窗口
--]]
local THIS_MODULE = ...

local S_INPUTKEYS = bit.bor(ctrlMgr.KEY_A,ctrlMgr.KEY_B)	 -- 输入键值

local utf8 = cc.safe_require("utf8")
local MessageWindow = class("MessageWindow", cc.Node, 
	require("app.main.modules.uiwidget.UIWidgetBase"),
	import("._TableItem"))

-- 类扩展构造
function MessageWindow:clsctor(config)
	table.merge(self,config)
end

-- 构造函数
function MessageWindow:ctor(size,anchor,config,params)
	if config then
		table.merge(self,config)
	end
	
	if self.background then
		local config = self.background
		local resnode = cc.CSLoader:createNode(config.csb)
		self:addChild(resnode)
		self:bindUI(resnode,config.widgets,config.bindings,true)
		if config.context then
			self._bgcontext = self[config.context]
		end
	end

	self:setContentSize(size)
	self._winsize = size
	if self._bgcontext then 
		self._bgcontext:setContentSize(size)
	end

	self._bounds = cc.rect(self.borders[1],self.borders[3],
		size.width-self.borders[1]-self.borders[2],
		size.height-self.borders[3]-self.borders[4])
	
	self._label = fontMgr:createLabel(self.font.name,"",self.font.params)
	self._fontheight = self._label:getFontHeight()
	local stencil = cc.DrawNode:create()
	stencil:drawSolidRect(cc.p(0,0),cc.p(self._bounds.width,self._bounds.height),cc.c4f(1,0,0,1))
	local textpanel = cc.ClippingNode:create(stencil)
	self._label:setAnchorPoint(cc.p(0,1))
	textpanel:addChild(self._label)
	textpanel:setPosition(self.borders[1],self.borders[3])
	self:addChild(textpanel)
	self._textpos = cc.p(0,0)

	-- 光标
	self._cursor = display.newSprite(self.cursorimg)
	self._cursize = self._cursor:getContentSize()
	self._cursor:setAnchorPoint(cc.p(0.5,0.5))
	textpanel:addChild(self._cursor)
	self._cursor:setVisible(false)

	self:updateParams(params)

	--[[
	-- 注册触摸事件
	local function onTouchBegan(touch, event)
		local target = event:getCurrentTarget()
		local locationInNode = target:convertToNodeSpace(touch:getPlace())
		local s = target:getContentSize()
		local rect = cc.rect(0, 0, s.width, s.height)
				
		if cc.rectContainsPoint(rect, locationInNode) then
			self:onControlKey(ctrlMgr.KEY_A)
			return true
		end
		return false
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
	--]]
end

-- 更新参数
function MessageWindow:updateParams(params)
	params = params or {}
	self:clearText(false,function ()
		self:appendText(params.text or "",{
			usecursor = false,
			usesound = false,
			quickshow = true,
			linefeed = true,
			ctrl_complete = false
		})
	end)
end

-- 清除文本
function MessageWindow:clearText(moveup,onComplete)
	local function clear_()
		self._label:setString("")
		self._label:setPosition(0,self._bounds.height)
		self._textpos.x = 0
		self._textpos.y = 0
		if onComplete then onComplete() end
	end
	if moveup and self._textpos.y > 0 then
		self:moveUpText(self._textpos.y,clear_)
	else
		clear_()
	end
end

-- 文本上移
function MessageWindow:moveUpText(height,onComplete)
	self._label:runAction(cc.Sequence:create(
		cc.MoveBy:create(self.moveuptime,cc.p(0,height)),
		cc.CallFunc:create(function() 
			self._textpos.y = self._textpos.y - height
			if onComplete then onComplete() end
		end)
	))
end

--[[
	向窗口中追加一个字
	word	为utf编码值
]]
function MessageWindow:_appendWord(word,onComplete)
	local wordW = self._label:getCharWidth(word)
	local doAppend = nil
	local tryAppend = nil

	doAppend = function(word_,onComplete_)
		local function appendToLabel()
			self._label:setString(self._label:getString() .. utf8.char(word_))
			if onComplete_ then onComplete_() end
		end

		if word_ == 0x0A then
			self._textpos.x = 0
			self._textpos.y = self._textpos.y + self._fontheight
		else
			self._textpos.x = self._textpos.x + wordW
		end
		if self._textpos.y > self._bounds.height then
			self:moveUpText(self._fontheight,appendToLabel)
		else
			appendToLabel()
		end
	end

	tryAppend = function()
		if word ~= 0x0A and (self._textpos.x + wordW > self._bounds.width) then
			doAppend(0x0A,tryAppend)
		else
			doAppend(word,onComplete)
		end
	end
	
	tryAppend()
end

--[[
	向窗口中追加文本
	text	文本
	config
		usecursor		使用光标
		usesound		使用声音
		quickshow		快速显示
		linefeed		追加换行
		ctrl_quick		加速控制
		ctrl_complete	完成控制
		onComplete		完成回调
		appendEnd		追加完成
]]
function MessageWindow:appendText(text,config)
	local next,istat,ictrl = utf8.codes(text)
	local nextWord = nil
	local appendEnd = nil
	local squick = config.quickshow
	local timer =nil
	
	appendEnd = function ()
		if config.appendEnd then config.appendEnd() end
		self._controller = nil
		if config.ctrl_complete == false then
			if config.onComplete then config.onComplete() end
		else
			if config.usecursor then
				self._usecursor = true
				self:enableCursor(true)
			end
			self._controller = function()
				self._controller = nil
				if config.usecursor then
					self._usecursor = false
					self:enableCursor(false)
				end
				if config.onComplete then config.onComplete() end
			end
		end
	end

	nextWord = function()
		local pos,word = next(istat,ictrl)
		ictrl = pos
		if pos == nil then
			if config.linefeed then
				self:_appendWord(0x0A,appendEnd)
			else
				appendEnd()
			end
		else
			self:_appendWord(word,function ()
				if config.usesound ~= false and word ~= 0x20 and word ~= 0x0A then
					audioMgr:playSE(self.printsound)
				end
				if squick then
					nextWord()
				else
					performWithDelay(self,nextWord,self.printspeed)
				end
			end)
		end
	end

	-- 加速控制
	if config.ctrl_quick then
		self._controller = function ()
			self._controller = nil
			squick = true
		end
	end

	nextWord()
end

--[[
	追加多个文本
	texts				文本数组
	config
		hidecsrlast		隐藏最后的光标
]]
function MessageWindow:appendTexts(texts,config,delay)
	local index = 1
	local onComplete = nil
	local appendEnd = nil
	local appendNext = nil
	
	appendNext = function ()
		if index <= #texts then
			if index == #texts then
				if config.usecursor and config.hidecsrlast then
					config.usecursor = false
				end
				config.appendEnd = appendEnd
			end
			local text = texts[index]
			index = index + 1
			self:appendText(text,config)
		else
			if onComplete then onComplete() end
		end
	end

	onComplete = config.onComplete
	config.onComplete = (function()
		if delay and delay > 0 then
			performWithDelay(self,appendNext,delay)
		else
			appendNext()
		end
	end)
	appendEnd = config.appendEnd
	config.appendEnd = nil

	appendNext()
end

-- 显示文本(参数查看 appendText)
function MessageWindow:showText(text,config)
	self:clearText(true,function ()
		self:appendText(text,config)
	end)
end

--[[
	显示多个文本
	texts				文本数组
	config
		hidecsrlast		隐藏最后的光标
]]
function MessageWindow:showTexts(texts,config,delay)
	local index = 1
	local onComplete = nil
	local appendEnd = nil
	local showNext = nil
	
	showNext = function ()
		if index <= #texts then
			if index == #texts then
				if config.usecursor and config.hidecsrlast then
					config.usecursor = false
				end
				config.appendEnd = appendEnd
			end
			local text = texts[index]
			index = index + 1
			self:showText(text,config)
		else
			if onComplete then onComplete() end
		end
	end

	onComplete = config.onComplete
	config.onComplete = (function()
		if delay and delay > 0 then
			performWithDelay(self,showNext,delay)
		else
			showNext()
		end
	end)
	appendEnd = config.appendEnd
	config.appendEnd = nil

	showNext()
end

-- 使能光标
function MessageWindow:enableCursor(enable)
	if enable then
		local textheight = self._textpos.y + self._fontheight
		local function show_()
			if self._controlable then
				self._showcursor = true
				self._cursor:setPosition(cc.p(self._bounds.width/2,
					self._bounds.height - textheight - self._fontheight/2))
				self._cursor:runAction(cc.Sequence:create(
					cc.Show:create(),cc.DelayTime:create(self.cursordelay),
					cc.CallFunc:create(function() 
						self._cursor:runAction(cc.RepeatForever:create(cc.Blink:create(1,self.cursorrate)))
					end)))
			end
		end
		if textheight + self._fontheight > self._bounds.height then
			self:moveUpText(self._fontheight,show_)
		else
			show_()
		end
	else
		self._showcursor = false
		self._cursor:stopAllActions()
		self._cursor:setVisible(false)
	end
end

-- 使能控制
function MessageWindow:enableControl(enable)
	self._controlable = enable
	if enable then
		if self._usecursor and not self._showcursor then
			self:enableCursor(true)
		end
	else
		if self._showcursor then
			self:enableCursor(false)
		end
	end
end

-- 忽略控制
function MessageWindow:ignoreControl(ignore)
	self._ignorectrl = ignore
end

-- 获得焦点回调
function MessageWindow:onGetFocus()
	self:enableControl(true)
end

-- 失去焦点回调
function MessageWindow:onLostFocus() 
	self:enableControl(false)
end

-- 当消息窗口输入键时
function MessageWindow:onControlKey(keycode)
	if self._controlable and not self._ignorectrl then
		if bit.band(keycode,S_INPUTKEYS) ~= 0 then
			if self._controller then
				self._controller(keycode)
			end
		end
	end
end

return MessageWindow
