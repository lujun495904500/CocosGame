--[[
	水攻2特效
--]]
local THIS_MODULE = ...

local Water2Effect = class("Water2Effect", cc.Node, require("app.main.modules.effect.EffectBase"))

-- 类构造函数
function Water2Effect:clsctor(econfig)
	self:setup(econfig)
	self:setupEffect()
end

-- 类析构函数
function Water2Effect:clsdtor()
	self:deleteEffect()
	self:delete()
end

-- 设置特效
function Water2Effect:setupEffect()
	
end

-- 删除特效
function Water2Effect:deleteEffect()
	
end

-- 创建特效对象
function Water2Effect:ctor(params)
	
	local sprite1 = cc.Sprite:create()
	local sprite2 = cc.Sprite:create()
	local sprite3 = cc.Sprite:create()
	sprite1:setAnchorPoint(cc.p(0.5,0))
	sprite1:setPosition(cc.p(0,self.fheight))
	sprite2:setAnchorPoint(cc.p(0.5,1))
	sprite2:setPosition(cc.p(0,self.fheight))
	sprite3:setAnchorPoint(cc.p(0.5,0))
	sprite3:setPosition(cc.p(0,0))
	if params.fromenemy then 
		sprite1:setFlippedX(true)
		sprite2:setFlippedX(true)
		sprite3:setFlippedX(true)
	end
	self:addChild(sprite1)
	self:addChild(sprite2)
	self:addChild(sprite3)

	self:runAction(cc.Sequence:create(
		cc.CallFunc:create(function() 
			sprite1:setSpriteFrame(self.spoutH)
		end),
		cc.DelayTime:create(self.action1.delay),

		cc.CallFunc:create(function() 
			sprite1:setSpriteFrame(self.spoutT)
			sprite2:setSpriteFrame(self.spoutH)
		end),
		cc.DelayTime:create(self.action1.delay),
		
		cc.Repeat:create(cc.Sequence:create(
			cc.CallFunc:create(function() 
				sprite1:setSpriteFrame(self.spoutH)
				sprite2:setSpriteFrame(self.spoutT)
				sprite3:setSpriteFrame(self.spray1)
			end),
			cc.DelayTime:create(self.action2.delay),
			cc.CallFunc:create(function() 
				sprite1:setSpriteFrame(self.spoutT)
				sprite2:setSpriteFrame(self.spoutH)
				sprite3:setSpriteFrame(self.spray2)
			end),
			cc.DelayTime:create(self.action2.delay)
		),self.action2.times),

		cc.CallFunc:create(function() 
			sprite1:setVisible(false)
			sprite2:setSpriteFrame(self.spoutT)
			sprite3:setSpriteFrame(self.spray1)
		end),
		cc.DelayTime:create(self.action3.delay),
		cc.CallFunc:create(function() 
			sprite2:setVisible(false)
			sprite3:setSpriteFrame(self.spray2)
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

return Water2Effect
