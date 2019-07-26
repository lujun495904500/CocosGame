--[[
	变量管理器
--]]
local THIS_MODULE = ...

-- 数据库变量索引路径
local C_DBVAR_IPATH = "db/variables"

-- 程序变量索引路径
local C_SRCVAR_IPATH = "src/variables"

local VariableManager = class("VariableManager", require("app.main.modules.index.IndexListener"))

-- 获得单例对象
local instance = nil
function VariableManager:getInstance()
	if instance == nil then
		instance = VariableManager:create()
		indexMgr:addListener(instance, { C_DBVAR_IPATH, C_SRCVAR_IPATH })
	end
	return instance
end

-- 构造函数
function VariableManager:ctor()
	self._variables = {}		-- 变量
end

-------------------------IndexListener-------------------------
-- 清空索引
function VariableManager:onIndexesRemoved()
	self:releaseVariables()
	self:onIndexesLoaded(C_DBVAR_IPATH, indexMgr:getIndex(C_DBVAR_IPATH))
	self:onIndexesLoaded(C_SRCVAR_IPATH, indexMgr:getIndex(C_SRCVAR_IPATH))
end

-- 加载索引路径
function VariableManager:onIndexesLoaded(ipath, ivalue)
	if ivalue then
		if ipath == C_DBVAR_IPATH then
			for _,dbfile in pairs(ivalue) do
				for name,var in pairs(indexMgr:readJson(dbfile)) do
					if var.type == "formula" then
						self:registerVariable(name, formulaMgr:getFormula(var.value))
					else
						self:registerVariable(name, var.value)
					end
				end
			end
		elseif ipath == C_SRCVAR_IPATH then
			for _,srclua in pairs(ivalue) do
				for name,value in pairs(require(srclua)) do
					self:registerVariable(name, value)
				end
			end
		end
	end
end
-------------------------IndexListener-------------------------

-- 注册变量
function VariableManager:registerVariable(name,value)
	self._variables[name] = value
end

-- 释放变量
function VariableManager:releaseVariables()
	self._variables = {}
end

-- 获得变量
function VariableManager:getVariable(name)
	return self._variables[name]
end

-- 返回 替换字符串中的变量
function VariableManager:replace(str, extvars)
	return string.gsub(str, "%$%([%w:,]+%)", function (varname)
			local params = string.split(varname:sub(3,-2),":")
			local value = extvars and extvars[params[1]] 
			value = value or self:getVariable(params[1])
			if value then
				return (type(value) ~= "function") and value or 
					value(unpack(string.split(params[2] or "",",")))
			end
		end)
end

-- 输出管理器当前状态
function VariableManager:dump()
	dump(self._variables, "VariableManager", 3)
end

return VariableManager
