--[[
	特效对象
--]]

local EffectBase = class("EffectBase", 
	require("app.main.modules.meta.MetaBase"), 
	require("app.main.modules.common.PlistLoadable"))

-- 安装特效
function EffectBase:setup(config)
	self._name = config.name
	if config.params then
		table.merge(self,config.params)
	end
	self:loadPlist(config.source, config.frames, true)
end

-- 删除特效
function EffectBase:delete()
	self:releasePlist()
end

-- 获得特效名称
function EffectBase:getName()
	return self._name
end

return EffectBase
