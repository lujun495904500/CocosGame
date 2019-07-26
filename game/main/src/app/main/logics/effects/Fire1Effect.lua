--[[
	火焰1特效
--]]
local THIS_MODULE = ...

local Fire1Effect = class("Fire1Effect", cc.Node, require("app.main.modules.effect.EffectBase"))

-- 类构造函数
function Fire1Effect:clsctor(econfig)
	self:setup(econfig)
	self:setupEffect()
end

-- 类析构函数
function Fire1Effect:clsdtor()
	self:deleteEffect()
	self:delete()
end

-- 设置特效
function Fire1Effect:setupEffect()
	
end

-- 删除特效
function Fire1Effect:deleteEffect()
	
end

-- 创建特效对象
function Fire1Effect:ctor(params)
	
	local sp = cc.Sprite:create()
	sp:setAnchorPoint(cc.p(0.5,0))
	sp:setFlippedX(params.fromenemy)
	self:addChild(sp)

	sp:runAction(cc.Sequence:create(
		cc.CallFunc:create(function() 
			sp:setSpriteFrame(self.fire1)
		end),
		cc.Repeat:create(cc.Sequence:create(
			cc.FlipX:create(params.fromenemy),
			cc.DelayTime:create(self.action1.delay),
			cc.FlipX:create(not params.fromenemy),
			cc.DelayTime:create(self.action1.delay)
		),self.action1.turns),

		cc.CallFunc:create(function() 
			sp:setSpriteFrame(self.fire2)
		end),
		cc.Repeat:create(cc.Sequence:create(
			cc.FlipX:create(params.fromenemy),
			cc.DelayTime:create(self.action2.delay),
			cc.FlipX:create(not params.fromenemy),
			cc.DelayTime:create(self.action2.delay)
		),self.action2.turns),

		cc.CallFunc:create(function() 
			sp:setSpriteFrame(self.smoke)
		end),
		cc.MoveBy:create(self.action3.duration,cc.p(0,self.action3.moveY)),
		
		cc.CallFunc:create(function() 
			self:removeFromParent(true)
			if params.onComplete then
				params.onComplete()
			end
		end)
	))
end

return Fire1Effect
