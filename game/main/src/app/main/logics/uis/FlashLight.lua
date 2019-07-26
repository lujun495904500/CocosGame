--[[
	闪光
]]
local THIS_MODULE = ...

local FlashLight = class("FlashLight", require("app.main.modules.ui.FrameBase"))

--[[
	构造函数
	config
		params		额外参数
		name		名称
		csb			csb文件
		widgets		组件表
		bindings	绑定表
]]
function FlashLight:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function FlashLight:dtor()
	self:delete()
	self:release()
end

--[[
	打开窗口
	config
		opacity		透明度
		duration	持续时间
		blinks		闪烁次数
		onComplete	完成回调
]]
function FlashLight:OnOpen(config)
	self.pl_flash:setOpacity(config.opacity or 255)
	self.pl_flash:runAction(cc.Sequence:create(cc.Hide:create(),
		cc.Blink:create(config.duration or 1, config.blinks or 1),
		cc.Hide:create(),cc.CallFunc:create(function() 
			self:closeFrame()
			if config.onComplete then config.onComplete() end
		end)))
end

return FlashLight
