--[[
	图片战场背景
--]]
local THIS_MODULE = ...

local Image = class("Image", cc.Sprite, require("app.main.modules.meta.MetaBase"))

--[[
	类构造函数
	config
		image		图片文件路径
]]
function Image:clsctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 构造函数
function Image:ctor()
	self:setTexture(self.image)
end

return Image
