--[[
	火焰2特效
--]]
local THIS_MODULE = ...

local Fire2Effect = class("Fire2Effect", cc.Node, require("app.main.modules.effect.EffectBase"))

-- 类构造函数
function Fire2Effect:clsctor(econfig)
	self:setup(econfig)
	self:setupEffect()
end

-- 类析构函数
function Fire2Effect:clsdtor()
	self:deleteEffect()
	self:delete()
end

-- 设置特效
function Fire2Effect:setupEffect()
	self.fireanime = cc.Animation:createWithSpriteFrames(
		{self.fanime1,self.fanime2,self.fanime3},self.action3.delay)
	self.fireanime:retain()
	self.fireend = cc.Animation:createWithSpriteFrames(
		{self.fend1,self.fend2,self.fend3},self.action4.delay)
	self.fireend:retain()
end

-- 删除特效
function Fire2Effect:deleteEffect()
	self.fireanime:release()
	self.fireend:release()
end

-- 创建特效对象
function Fire2Effect:ctor(params)
	
	local sp = cc.Sprite:createWithSpriteFrame(self.fsmall)
	sp:setAnchorPoint(cc.p(0.5,0))
	sp:setFlippedX(params.fromenemy)
	self:addChild(sp)
	
	sp:runAction(cc.Sequence:create(
		cc.Repeat:create(cc.Sequence:create(
			cc.FlipX:create(not params.fromenemy),
			cc.DelayTime:create(self.action1.delay),
			cc.FlipX:create(params.fromenemy),
			cc.DelayTime:create(self.action1.delay)
		),self.action1.turns),

		cc.CallFunc:create(function() 
			sp:setSpriteFrame(self.fmedi)
		end),
		cc.DelayTime:create(self.action2.delay),

		cc.Repeat:create(
			cc.Animate:create(self.fireanime)
		,self.action3.times),
		cc.Animate:create(self.fireend),
		cc.DelayTime:create(self.action4.delay),

		cc.CallFunc:create(function() 
			sp:setSpriteFrame(self.fmoveup)
			sp:setPosition(cc.p(0,self.action5.offestY))
		end),
		cc.MoveBy:create(self.action5.duration,cc.p(0,self.action5.moveY)),
		
		cc.CallFunc:create(function() 
			self:removeFromParent(true)
			if params.onComplete then
				params.onComplete()
			end
		end)
	))
end

return Fire2Effect
