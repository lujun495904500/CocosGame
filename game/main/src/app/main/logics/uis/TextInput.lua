--[[
	文本输入
]]
local THIS_MODULE = ...

-- 输入表
local C_INPUTS = {
	L = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"},
	U = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"},
	N = {"0","1","2","3","4","5","6","7","8","9"},
	S = {"@","#","$","%","&","*","(",")","-","+","[","]","{","}","?","<",">","/","\"","'"},
}

local utf8 = cc.safe_require("utf8")
local TextInput = class("TextInput", require("app.main.modules.ui.FrameBase"), 
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
function TextInput:ctor(config)
	self:setup(config)
	self:retain()
	self:initFrame()
end

-- 析构函数
function TextInput:dtor()
	self:delete()
	self:release()
end

-- 初始化
function TextInput:initFrame()
	self.wg_select:markSelect(false)
	self.wg_functions:markSelect(false)
	self.wg_words:markSelect(false)
	
	local iboxsize = self.eb_wrect:getContentSize()
	self.eb_texts = ccui.EditBox:create(iboxsize, "")
	self.eb_texts:setPosition(cc.p(iboxsize.width/2, iboxsize.height/2))
	self.eb_wrect:addChild(self.eb_texts)
	self.eb_texts:setFontSize(16)
	self.eb_texts:setTextHorizontalAlignment(1)
	self.eb_texts:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	self.eb_texts:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.eb_texts:setMaxLength(11)

	self.wg_words:setListener({
		trigger = function(item_,pindex,index)
			local word = item_.label
			if word and word ~= "" then
				self.eb_texts:setText(self.eb_texts:getText() .. word)
			end
		end,
		overright = function ()
			self.wg_functions:changeSelect(1)
			self:setFocusWidget(self.wg_functions)
		end,
		cancel = function ()
			self.wg_functions:changeSelect(1)
			self:setFocusWidget(self.wg_functions)
		end
	})
	self.wg_functions:setListener({
		trigger = function(item_,pindex,index)
			local itype = item_.type
			if itype == "D" then
				local words = self.eb_texts:getText()
				if #words > 0 then
					local cps = { utf8.codepoint(words,1,#words) }
					cps[#cps] = nil
					self.eb_texts:setText(utf8.char(unpack(cps)))
				end
			elseif itype == "L" then
				self:updateInputs("L")
			elseif itype == "U" then
				self:updateInputs("U")
			elseif itype == "N" then
				self:updateInputs("N")
			else	-- S
				self:updateInputs("S")
			end
		end,
		overdown = function ()
			self.wg_select:changeSelect(1)
			self:setFocusWidget(self.wg_select)
		end,
		overleft = function ()
			self.wg_words:changeSelect(1)
			self:setFocusWidget(self.wg_words)
		end,
		cancel = function ()
			self.wg_select:changeSelect(1)
			self:setFocusWidget(self.wg_select)
		end
	})
	self.wg_select:setListener({
		trigger = function(item_,pindex,index)
			if self._autoclose then self:closeFrame() end
			if self._onComplete then
				if item_.type == "R" then
					self._onComplete(false)
				else	-- E
					self._onComplete(true,self.eb_texts:getText())
				end
			end
		end,
		overup = function ()
			self.wg_functions:changeSelect(self.wg_functions:getItemRows())
			self:setFocusWidget(self.wg_functions)
		end,
		overleft = function ()
			self.wg_words:changeSelect(1)
			self:setFocusWidget(self.wg_words)
		end,
		cancel = function ()
			self.wg_words:changeSelect(1)
			self:setFocusWidget(self.wg_words)
		end
	})
	self:updateInputs("L")
end

--[[
	打开窗口
	config
		autoclose	自动关闭
		messages	显示消息
		text		预置文本
		onComplete	完成回调
]]
function TextInput:OnOpen(config)
	self._autoclose = config.autoclose
	self._onComplete = config.onComplete

	self.lb_message:setString(config.messages or "")
	self.eb_texts:setText(config.text or "")
	
	self.wg_select:changeSelect(1)
	self:setFocusWidget(self.wg_select)
end

-- 更新输入表
function TextInput:updateInputs(key)
	local inputs = C_INPUTS[key]
	if inputs then
		local initems = {}
		for i,word in ipairs(inputs) do
			initems[#initems + 1] = { label = word }
		end
		self.wg_words:updateParams({
			items = initems
		})
	end
end

-- 获得焦点回调
function TextInput:onGetFocus()
	self:OnWidgetGetFocus()
end

-- 失去焦点回调
function TextInput:onLostFocus()
	self:OnWidgetLostFocus()
end

-- 输入处理
function TextInput:onControlKey(keycode)
	self:onWidgetControlKey(keycode)
end

return TextInput
