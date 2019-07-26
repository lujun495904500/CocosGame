--[[
	水攻1特效
--]]
local THIS_MODULE = ...

local Water1Effect = class("Water1Effect", cc.Node, require("app.main.modules.effect.EffectBase"))

-- 类构造函数
function Water1Effect:clsctor(econfig)
	self:setup(econfig)
	self:setupEffect()
end

-- 类析构函数
function Water1Effect:clsdtor()
	self:deleteEffect()
	self:delete()
end

-- 设置特效
function Water1Effect:setupEffect()
	
end

-- 删除特效
function Water1Effect:deleteEffect()
	
end

-- 创建特效对象
function Water1Effect:ctor(params)
	
	local sprite1 = cc.Sprite:create()
	local sprite2 = cc.Sprite:create()
	if params.fromenemy then 
		sprite1:setFlippedX(true)
		sprite2:setFlippedX(true)
		sprite2:setAnchorPoint(cc.p(1,0))
		sprite2:setPosition(cc.p(self.offestX,0))
		sprite1:setAnchorPoint(cc.p(0,0))
		sprite1:setPosition(cc.p(self.offestX,0))
	else
		sprite2:setAnchorPoint(cc.p(0,0))
		sprite2:setPosition(cc.p(-self.offestX,0))
		sprite1:setAnchorPoint(cc.p(1,0))
		sprite1:setPosition(cc.p(-self.offestX,0))
	end
	self:addChild(sprite1)
	self:addChild(sprite2)

	self:runAction(cc.Sequence:create(
		cc.CallFunc:create(function() 
			sprite1:setSpriteFrame(self.spoutT)
		end),
		cc.DelayTime:create(self.action1.delay),

		cc.CallFunc:create(function() 
			sprite1:setSpriteFrame(self.spoutH)
			sprite2:setSpriteFrame(self.spoutT)
		end),
		cc.DelayTime:create(self.action1.delay),
		
		cc.CallFunc:create(function() 
			sprite1:setSpriteFrame(self.spoutT)
			sprite2:setSpriteFrame(self.spout)
		end),
		cc.DelayTime:create(self.action1.delay),

		cc.Repeat:create(cc.Sequence:create(
			cc.CallFunc:create(function() 
				sprite1:setSpriteFrame(self.spoutH)
				sprite2:setSpriteFrame(self.spray1)
			end),
			cc.DelayTime:create(self.action2.delay),
			cc.CallFunc:create(function() 
				sprite1:setSpriteFrame(self.spoutT)
				sprite2:setSpriteFrame(self.spray2)
			end),
			cc.DelayTime:create(self.action2.delay)
		),self.action2.times),

		cc.CallFunc:create(function() 
			sprite1:setVisible(false)
		end),
		cc.DelayTime:create(self.action3.delay),

		cc.RemoveSelf:create(),
		cc.CallFunc:create(function() 
			if params.onComplete then
				params.onComplete()
			end
		end)
	))
end

return Water1Effect
