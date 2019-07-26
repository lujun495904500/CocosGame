--[[
	帧特效
--]]
local THIS_MODULE = ...

local FrameEffect = class("FrameEffect", cc.Node, require("app.main.modules.effect.EffectBase"))

-- 类构造函数
function FrameEffect:clsctor(econfig)
	self:setup(econfig)
	self:setupEffect()
end

-- 类析构函数
function FrameEffect:clsdtor()
	self:deleteEffect()
	self:delete()
end

-- 设置特效
function FrameEffect:setupEffect()
	local frames = {}
	for i,fname in ipairs(self.sequence) do
		frames[i] = self[fname]
	end
	self.animation = cc.Animation:createWithSpriteFrames(frames,self.delay)
	self.animation:retain()
end

-- 删除特效
function FrameEffect:deleteEffect()
	self.animation:release()
end

-- 创建特效对象
function FrameEffect:ctor(params)
	
	local sp = cc.Sprite:create()
	sp:setAnchorPoint(cc.p(0.5,0))
	sp:setFlippedX(params.fromenemy)
	self:addChild(sp)

	sp:runAction(cc.Sequence:create(
		cc.Animate:create(self.animation),
		cc.CallFunc:create(function() 
			self:removeFromParent(true)
			if params.onComplete then
				params.onComplete()
			end
		end)
	))
end

return FrameEffect
