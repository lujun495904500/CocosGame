--[[
	恢复特效
--]]
local THIS_MODULE = ...

local RecoveryEffect = class("RecoveryEffect", cc.Node, require("app.main.modules.effect.EffectBase"))

-- 类构造函数
function RecoveryEffect:clsctor(econfig)
	self:setup(econfig)
	self:setupEffect()
end

-- 类析构函数
function RecoveryEffect:clsdtor()
	self:deleteEffect()
	self:delete()
end

-- 设置特效
function RecoveryEffect:setupEffect()
	
end

-- 删除特效
function RecoveryEffect:deleteEffect()
	
end

-- 创建特效对象
function RecoveryEffect:ctor(params)
	
	local direct = 1
	if params.fromenemy then 
		direct = -1
	end

	local sprites = {}
	for i = 1,self.count do
		local sprite = cc.Sprite:create()
		sprite:setFlippedX(params.fromenemy)
		self:addChild(sprite)
		sprites[#sprites + 1] = sprite
	end

	local index = 1
	self:runAction(cc.Sequence:create(
		cc.Repeat:create(cc.Sequence:create(
			cc.CallFunc:create(function() 
				local particle = self.particles[index]
				for i,sprite in ipairs(sprites) do
					sprite:setSpriteFrame(self[particle[i].frame])
					sprite:setPosition(cc.p(direct * particle[i].pos[1],particle[i].pos[2]))
				end
				index = index + 1
			end),
			cc.DelayTime:create(self.delay)
		),#self.particles),
		
		cc.RemoveSelf:create(),
		cc.CallFunc:create(function() 
			if params.onComplete then
				params.onComplete()
			end
		end)
	))
end

return RecoveryEffect
