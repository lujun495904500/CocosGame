--[[
	落木特效
--]]
local THIS_MODULE = ...

local FallwoodEffect = class("FallwoodEffect", cc.Node, require("app.main.modules.effect.EffectBase"))

-- 类构造函数
function FallwoodEffect:clsctor(econfig)
	self:setup(econfig)
	self:setupEffect()
end

-- 类析构函数
function FallwoodEffect:clsdtor()
	self:deleteEffect()
	self:delete()
end

-- 设置特效
function FallwoodEffect:setupEffect()
   
end

-- 删除特效
function FallwoodEffect:deleteEffect()
	
end

-- 创建特效对象
function FallwoodEffect:ctor(params)
	
	local smoke = cc.Sprite:create()
	local wood1 = cc.Sprite:create()
	local wood2 = cc.Sprite:create()
	local dust = cc.Sprite:create()
	dust:setAnchorPoint(cc.p(0.5,0))
	local direct = -1
	if params.fromenemy then 
		smoke:setFlippedX(true)
		wood1:setFlippedX(true)
		wood2:setFlippedX(true)
		dust:setFlippedX(true)
		direct = 1
	end
	self:addChild(smoke)
	self:addChild(wood1)
	self:addChild(wood2)
	self:addChild(dust)

	local index = 1
	self:runAction(cc.Sequence:create(
		cc.CallFunc:create(function() 
			smoke:setSpriteFrame(self.fsmoke)
			wood1:setSpriteFrame(self.fwood1)
			wood2:setSpriteFrame(self.fwood2)
		end),

		cc.Repeat:create(cc.Sequence:create(
			cc.CallFunc:create(function() 
				local act = self.action1.sequence[index]
				smoke:setRotation(act.fsr)
				smoke:setPosition(cc.p(direct*act.fsp[1],act.fsp[2]))
				wood1:setPosition(cc.p(direct*act.fw1p[1],act.fw1p[2]))
				wood2:setPosition(cc.p(direct*act.fw2p[1],act.fw2p[2]))
				index = index + 1
			end),
			cc.DelayTime:create(self.action1.delay)
		),#self.action1.sequence),

		cc.Sequence:create(
			cc.CallFunc:create(function() 
				smoke:setVisible(false)
				wood1:setVisible(false)
				wood2:setVisible(false)
				dust:setSpriteFrame(self.fdust1)
			end),
			cc.Repeat:create(cc.Sequence:create(
				cc.CallFunc:create(function() 
					dust:setFlippedX(not params.fromenemy)
				end),
				cc.DelayTime:create(self.action2.delay),
				cc.CallFunc:create(function() 
					dust:setFlippedX(params.fromenemy)
				end),
				cc.DelayTime:create(self.action2.delay)
			),self.action2.turns),
			
			cc.CallFunc:create(function()
				dust:setSpriteFrame(self.fdust2)
			end),
			cc.Repeat:create(cc.Sequence:create(
				cc.CallFunc:create(function() 
					dust:setFlippedX(not params.fromenemy)
				end),
				cc.DelayTime:create(self.action3.delay),
				cc.CallFunc:create(function() 
					dust:setFlippedX(params.fromenemy)
				end),
				cc.DelayTime:create(self.action3.delay)
			),self.action3.turns),
			cc.CallFunc:create(function() 
				dust:setVisible(false)
			end)
		),
		
		cc.RemoveSelf:create(),
		cc.CallFunc:create(function() 
			if params.onComplete then
				params.onComplete()
			end
		end)
	))
end

return FallwoodEffect
