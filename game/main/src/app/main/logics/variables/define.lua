--[[
	初始化变量
]]
local THIS_MODULE = ...

-- 名字
local function var_name(type,...)
	if type == "MAJOR" then
		local index,alive = ...
		index = tonumber(index)
		if alive == "ALIVE" then
			return majorTeam:getAlive(index):getName()
		else
			return majorTeam:getRole(index):getName()
		end
	end
end

return {
	name = var_name,
}
