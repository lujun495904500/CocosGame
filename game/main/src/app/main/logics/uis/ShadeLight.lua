--[[
	暗明交替
]]
local THIS_MODULE = ...

local ShadeLight = class("ShadeLight", require("app.main.modules.ui.FrameBase"))

--[[
	构造函数
	config
		params		额外参数
		name		名称
		csb			csb文件
		widgets		组件表
		bindings	绑定表
]]
function ShadeLight:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function ShadeLight:dtor()
	self:delete()
	self:release()
end

--[[
	打开窗口
	config
		shadetime	变暗时间
		lighttime	变亮时间
		reverse		反转
		switch		切换监听器
		onComplete	完成回调
]]
function ShadeLight:OnOpen(config)
	local steps = config.reverse and {
		function (onComplete) self:doLight(config.shadetime or 1,onComplete) end,
		function (onComplete) self:doShade(config.shadetime or 1,onComplete) end,
	} or {
		function (onComplete) self:doShade(config.shadetime or 1,onComplete) end,
		function (onComplete) self:doLight(config.shadetime or 1,onComplete) end,
	}
	local nextStep = nil
	local step = 0

	nextStep = function ()
		if step + 1 <= #steps then
			step = step + 1
			steps[step](function ()
				if step == 1 and config.switch then
					config.switch(nextStep)
				else
					nextStep()
				end
			end)
		else
			self:closeFrame()
			if config.onComplete then config.onComplete() end
		end
	end

	nextStep()
end

-- 变暗
function ShadeLight:doShade(time,onComplete)
	self.pl_shade:stopAllActions()
	self.pl_shade:setOpacity(0)
	self.pl_shade:runAction(cc.Sequence:create(
		cc.FadeIn:create(time),
		cc.CallFunc:create(function ()
			self.pl_shade:setOpacity(255)
			onComplete()
		end)
	))
end

-- 变亮
function ShadeLight:doLight(time,onComplete)
	self.pl_shade:stopAllActions()
	self.pl_shade:setOpacity(255)
	self.pl_shade:runAction(cc.Sequence:create(
		cc.FadeOut:create(time),
		cc.CallFunc:create(function ()
			self.pl_shade:setOpacity(0)
			onComplete()
		end)
	))
end

return ShadeLight
