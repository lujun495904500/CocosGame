--[[
	复活特效
--]]
local THIS_MODULE = ...

local ReviveEffect = class("ReviveEffect", cc.Node, require("app.main.modules.effect.EffectBase"))

-- 类构造函数
function ReviveEffect:clsctor(econfig)
	self:setup(econfig)
	self:setupEffect()
end

-- 类析构函数
function ReviveEffect:clsdtor()
	self:deleteEffect()
	self:delete()
end

-- 设置特效
function ReviveEffect:setupEffect()
	
end

-- 删除特效
function ReviveEffect:deleteEffect()
	
end

-- 创建特效对象
function ReviveEffect:ctor(params)
	
	local sprites = {}
	local pangle = math.rad(360 / self.count)
	for i = 1,self.count do
		local sprite = cc.Sprite:createWithSpriteFrame(self.fstar)
		sprite:setFlippedX(params.fromenemy)
		local angle = pangle * (i-1)
		sprite:setPosition(cc.p(self.offest[1] + self.radius*math.cos(angle),self.offest[2] + self.radius*math.sin(angle)))
		self:addChild(sprite)
		sprites[#sprites + 1] = {
			sprite = sprite,
			angle = angle
		}
	end

	local direct = params.fromenemy and -1 or 1
	local iangle = math.rad(self.rotatespeed)
	self:runAction(cc.Sequence:create(
		cc.Repeat:create(cc.Sequence:create(
			cc.CallFunc:create(function() 
				for _,star in ipairs(sprites) do
					star.angle = star.angle + direct * iangle
					star.sprite:setPosition(cc.p(self.offest[1] + self.radius*math.cos(star.angle),self.offest[2] + self.radius*math.sin(star.angle)))
				end
			end),
			cc.DelayTime:create(self.delay)
		),self.rotatetimes),
		
		cc.RemoveSelf:create(),
		cc.CallFunc:create(function() 
			if params.onComplete then
				params.onComplete()
			end
		end)
	))
end

return ReviveEffect
