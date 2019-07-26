--[[
	队伍属性
--]]
local THIS_MODULE = ...

-- 头像资源索引
local C_HEAD_IPATH = "res/files/heads"

local S_CLOSEKEYS = bit.bor(ctrlMgr.KEY_SELECT,ctrlMgr.KEY_A,ctrlMgr.KEY_B)
local S_LASTKEYS = bit.bor(ctrlMgr.KEY_UP,ctrlMgr.KEY_LEFT)
local S_NEXTKEYS = bit.bor(ctrlMgr.KEY_DOWN,ctrlMgr.KEY_RIGHT)

local TeamAttribute = class("TeamAttribute", require("app.main.modules.ui.FrameBase"))

--[[
	构造函数
	config
		params		额外参数
		name		名称
		csb			csb文件
		widgets		组件表
		bindings	绑定表
]]
function TeamAttribute:ctor(config)
	self:setup(config)
	self:retain()
end

-- 析构函数
function TeamAttribute:dtor()
	self:delete()
	self:release()
end

-- 打开窗口
function TeamAttribute:OnOpen(team) 
	self._team = team
	if team and team:getRoleCount() > 0 then
		self:showTeam()
	else
		self:closeFrame()
	end
end

-- 关闭窗口
function TeamAttribute:OnClose()
	self._team = nil
end

-- 显示当前团队
function TeamAttribute:showTeam()
	local role1 = self._team:getRole(1)
	self:setRoleHead(role1:getHead())
	self.lb_rolename:setString(role1:getName())

	local adviser = self._team:getAdviser()
	self.lb_adviser:setString(adviser and adviser:getName() or "")
	self.lb_sp:setString(tostring(self._team:getSP()))
	self.lb_msp:setString(tostring(self._team:getMSP()))
	self.lb_level:setString(string.format("%02d", self._team:getLevel()))
	self.lb_gold:setString(tostring(self._team:getGolds()))
	self.lb_exp:setString(tostring(self._team:getExps()))

	self.page = 1
	self:updateRoles()
end

-- 更新角色
function TeamAttribute:updateRoles()
	local adviser = self._team:getAdviser()
	local roles = self._team:getRoles()
	local pageroles = self.wg_rolelist:getItemRows()
	
	-- 设置光标
	self:setLastPage(self.page > 1)
	self:setNextPage(self.page * pageroles < #roles)

	-- 更新角色
	local roleitems = {}
	for i = 1, pageroles do
		local role = roles[(self.page - 1) * pageroles + i]
		if role then
			roleitems[#roleitems + 1] = {
				adviser = (role == adviser),
				name = role:getName(),
				soldiers = {
					value = role:getSoldiers(),
					max = role:getSoldierMax(),
				}
			}
		end
	end
	self.wg_rolelist:updateParams({
		items = roleitems
	})
end

-- 设置可否向上翻页
function TeamAttribute:setLastPage(enable)
	self.lastpage = enable
	self.sp_last:stopAllActions()
	self.sp_last:setVisible(enable)
	if enable then
		self.sp_last:runAction(cc.Sequence:create(
			cc.Show:create(),cc.DelayTime:create(self.cursordelay),
			cc.CallFunc:create(function() 
				self.sp_last:runAction(cc.RepeatForever:create(cc.Blink:create(1,self.cursorrate)))
			end)))
	end
end

-- 设置可否向下翻页
function TeamAttribute:setNextPage(enable)
	self.nextpage = enable
	self.sp_next:stopAllActions()
	self.sp_next:setVisible(enable)
	if enable then
		self.sp_next:runAction(cc.Sequence:create(
			cc.Show:create(),cc.DelayTime:create(self.cursordelay),
			cc.CallFunc:create(function() 
				self.sp_next:runAction(cc.RepeatForever:create(cc.Blink:create(1,self.cursorrate)))
			end)))
	end
end

-- 设置角色头像
function TeamAttribute:setRoleHead(headimg,flipx)
	if not headimg then
		self.sp_rolehead:setVisible(false)
	else
		self.sp_rolehead:setFlippedX(flipx)
		self.sp_rolehead:setTexture(indexMgr:getIndex(C_HEAD_IPATH .. "/" .. headimg))
		self.sp_rolehead:setVisible(true)
	end
end

-- 输入处理
function TeamAttribute:onControlKey(keycode)
	if bit.band(keycode,S_CLOSEKEYS) ~= 0 then
		self:closeFrame()
	elseif bit.band(keycode,S_LASTKEYS) ~= 0 then
		if self.lastpage then
			self.page = self.page - 1
			self:updateRoles()
		end
	elseif bit.band(keycode,S_NEXTKEYS) ~= 0 then
		if self.nextpage then
			self.page = self.page + 1
			self:updateRoles()
		end
	end
end

return TeamAttribute
