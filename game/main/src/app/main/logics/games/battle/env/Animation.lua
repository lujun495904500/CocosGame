--[[
	动画战场背景
--]]
local THIS_MODULE = ...

local Animation = class("Animation", cc.Sprite, require("app.main.modules.meta.MetaBase"))

--[[
	类构造函数
	config
		images		图片文件路径
		delay		动画延时时间
]]
function Animation:clsctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 构造函数
function Animation:ctor()
	local frames = {}
	for i,image in ipairs(self.images) do
		local texture = display.loadImage(image)
		local tsize = texture:getContentSize()
		frames[i] = cc.SpriteFrame:createWithTexture(texture,cc.rect(0,0,tsize.width,tsize.height))
	end
	local animation = display.newAnimation(frames,self.delay)
	self:playAnimationForever(animation)
end

return Animation
