--[[
	主角队伍
--]]
local THIS_MODULE = ...

local MajorTeam = class("MajorTeam", require("app.main.logics.games.Team"))

-- 获得单例对象
local instance = nil
function MajorTeam:getInstance()
	if instance == nil then
		instance = MajorTeam:create()
	end
	return instance
end

-- 构造函数
function MajorTeam:ctor()
	self.super.ctor(self,"EMPTY")
	archMgr:addListener(handler(self,MajorTeam.archiveListener))
end

-- 存档监听器
function MajorTeam:archiveListener(type,data,info)
	if type == "LOAD" then
		if data.majorteam then
			self:loadSerialize(data.majorteam)
		end
	elseif type == "SAVE" then 
		data.majorteam = self:saveSerialize()
	elseif type == "NEW" then
		self:initNew()
	end
end

-- 提升主角队伍等级
function MajorTeam:upgradeMajorLevel()
	local msgs = {}
	self:upgradeLevel(msgs)
	if #msgs > 0 then
		uiMgr:openUI("levelup",{
			lvupmsgs = msgs,
			autoclose = true,
		})
	end
end

-- 增加主角队伍经验
function MajorTeam:addMajorExps(aexps)
	local msgs = {}
	self:addExps(aexps,msgs)
	if #msgs > 0 then
		uiMgr:openUI("levelup",{
			lvupmsgs = msgs,
			autoclose = true,
		})
	end
end

return MajorTeam
