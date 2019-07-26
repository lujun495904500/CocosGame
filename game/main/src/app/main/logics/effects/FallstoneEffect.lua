--[[
	落石特效
--]]
local THIS_MODULE = ...

local FallstoneEffect = class("FallstoneEffect", cc.Node, require("app.main.modules.effect.EffectBase"))

-- 类构造函数
function FallstoneEffect:clsctor(econfig)
	self:setup(econfig)
	self:setupEffect()
end

-- 类析构函数
function FallstoneEffect:clsdtor()
	self:deleteEffect()
	self:delete()
end

-- 设置特效
function FallstoneEffect:setupEffect()
	local frames = {}
	for i,fname in ipairs(self.sequence) do
		frames[i] = self[fname]
	end
	self.animation = cc.Animation:createWithSpriteFrames(frames,self.delay)
	self.animation:retain()
end

-- 删除特效
function FallstoneEffect:deleteEffect()
	self.animation:release()
end

-- 创建特效对象
function FallstoneEffect:ctor(params)
	
	local stone = cc.Sprite:create()
	local direct = -1
	if params.fromenemy then 
		stone:setFlippedX(true)
		direct = 1
	end
	stone:setPosition(cc.p(direct*self.begin[1],self.begin[2]))
	self:addChild(stone)

	local mactions = {}
	for _,path in ipairs(self.paths) do
		mactions[#mactions + 1] = cc.MoveTo:create(path.duration,
			cc.p(direct*path.pos[1],path.pos[2]))
	end
	
	stone:playAnimationForever(self.animation)
	stone:runAction(cc.Sequence:create(
		cc.Sequence:create(mactions),
		cc.CallFunc:create(function() 
			self:removeFromParent(true)
			if params.onComplete then
				params.onComplete()
			end
		end)
	))
end

return FallstoneEffect
