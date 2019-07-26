--[[
	基础模型
]]

-- 速度动作
local C_SPEED_ACTION = 1234

local _BasicalModel = class("_BasicalModel", 
	require("app.main.modules.model.ModelBase"), 
	require("app.main.modules.common.PlistLoadable"))

-- 安装模型
function _BasicalModel:setup(config)
	self._name = config.name
	self._modelsize = cc.size(config.modelsize[1],config.modelsize[2])
	self._anchor = cc.p(config.anchor[1],config.anchor[2])
	if config.params then
		table.merge(self,config.params)
	end
	self:loadPlist(config.source, config.frames, true)
	self:setupActions()
end

-- 删除模型
function _BasicalModel:delete()
	self:deleteActions()
	self:releasePlist()
end

-- 安装动作
function _BasicalModel:setupActions()
	for _,action in pairs(self.actions) do
		if action.type == "frame" then
			action.frame = self[action.frame]
			action.frame:retain()
		else -- animation
			local frames = {}
			for i,fname in ipairs(action.sequeue) do
				frames[i] = self[fname]
			end
			action.animation = cc.Animation:createWithSpriteFrames(frames,action.time)
			action.animation:retain()
			action.sequeue = nil
			action.time = nil
		end
	end
end

-- 删除动作
function _BasicalModel:deleteActions()
	for _,action in pairs(self.actions) do
		if action.type == "frame" then
			action.frame:release()
		else -- animation
			action.animation:release()
		end
	end
end

-- 构造函数
function _BasicalModel:ctor()
	self._modelspeed = 1
	self._caction = nil		 -- 当前动作

	self._sprite = cc.Sprite:create()
	self._sprite:setAnchorPoint(self._anchor)
	self:addChild(self._sprite)
end

-- 模型速度
function _BasicalModel:setModelSpeed(speed)
	self._modelspeed = speed
	local saction = self._sprite:getActionByTag(C_SPEED_ACTION)
	if saction then
		saction:setSpeed(speed)
	end
end
function _BasicalModel:getModelSpeed()
	return self._modelspeed
end

--[[
	执行动作
	nofore		非强制更新
	flip		XY翻转
	anchor		动作锚点
	once		单次动画
]] 
function _BasicalModel:doAction(aname,onComplete)
	local action = self.actions[aname]
	assert(action,"not found action :" .. aname)

	if not action.nofore or self._caction ~= action then

		-- 清除前一个动作设置
		if self._caction then
			self._sprite:stopAllActions()
			if self._caction.flip then
				self._sprite:setFlippedX(false)
				self._sprite:setFlippedY(false)
			end
			if self._caction.anchor then
				self._sprite:setAnchorPoint(self._anchor)
			end
		end
		self._caction = action

		-- 设置当前动作
		if action.flip then
			self._sprite:setFlippedX(action.flip[1])
			self._sprite:setFlippedY(action.flip[2])
		end
		if action.anchor then
			self._sprite:setAnchorPoint(cc.p(action.anchor[1],action.anchor[2]))
		end
		
		-- 动作执行
		if action.type == "frame" then
			self._sprite:setSpriteFrame(action.frame)
			if onComplete then onComplete() end
		else -- animation
			if action.once then
				local saction = cc.Speed:create(cc.Sequence:create(cc.Animate:create(action.animation),
					cc.CallFunc:create(function ()
						if onComplete then onComplete() end
					end)),self._modelspeed)
				saction:setTag(C_SPEED_ACTION)
				self._sprite:runAction(saction)
			else
				local saction = cc.Speed:create(cc.RepeatForever:create(cc.Animate:create(action.animation)),self._modelspeed)
				saction:setTag(C_SPEED_ACTION)
				self._sprite:runAction(saction)
				if onComplete then onComplete() end
			end
		end
	else
		if onComplete then onComplete() end
	end
end

-- 获得指定动作
function _BasicalModel:getAction(aname)
	return self.actions[aname]
end

-- 获得模型名
function _BasicalModel:getName()
	return self._name
end

-- 获得模型的大小
function _BasicalModel:getModelSize()
	return self._modelsize
end

return _BasicalModel
