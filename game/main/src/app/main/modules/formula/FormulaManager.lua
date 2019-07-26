--[[
	公式管理器 (也算函数管理器)
--]]
local THIS_MODULE = ...
local C_LOGTAG = "FormulaManager"

-- 数据库公式索引路径
local C_DBFML_IPATH = "db/formulas"

-- 程序公式索引路径
local C_SRCFML_IPATH = "src/formulas"

local FormulaManager = class("FormulaManager", require("app.main.modules.index.IndexListener"))

-- 获得单例对象
local instance = nil
function FormulaManager:getInstance()
	if instance == nil then
		instance = FormulaManager:create()
		indexMgr:addListener(instance, { C_DBFML_IPATH, C_SRCFML_IPATH })
	end
	return instance
end

-- 构造函数
function FormulaManager:ctor()
	self._formulas = {}		 -- 公式
end

-------------------------IndexListener-------------------------
-- 清空索引
function FormulaManager:onIndexesRemoved()
	self:releaseVariables()
	self:onIndexesLoaded(C_DBFML_IPATH, indexMgr:getIndex(C_DBFML_IPATH))
	self:onIndexesLoaded(C_SRCFML_IPATH, indexMgr:getIndex(C_SRCFML_IPATH))
end

-- 加载索引路径
function FormulaManager:onIndexesLoaded(ipath, ivalue)
	if ivalue then
		if ipath == C_DBFML_IPATH then
			for _,dbfile in pairs(ivalue) do
				for name,fconf in pairs(indexMgr:readJson(dbfile)) do
					local formula, errmsg = load(string.format("%s \n%s \n%s",
						fconf.params and string.format( "local %s = ...",fconf.params) or "",
						fconf.statements and fconf.statements or "",
						fconf.calculate and ("return " .. fconf.calculate) or ""))
					assert(formula, string.format("formula [%s] error : %s", name, errmsg))
					self:registerFormula(name, formula)
				end
			end
		elseif ipath == C_SRCFML_IPATH then
			for _,srclua in pairs(ivalue) do
				for name,formula in pairs(require(srclua)) do
					self:registerFormula(name, formula)
				end
			end
		end
	end
end
-------------------------IndexListener-------------------------

-- 注册公式
function FormulaManager:registerFormula(name, formula)
	self._formulas[name] = formula
end

-- 释放公式
function FormulaManager:releaseFormulas()
	self._formulas = {}
end

-- 获得公式
function FormulaManager:getFormula(fname)
	return self._formulas[fname]
end

-- 计算指定公式
function FormulaManager:calculate(fname, ...)
	local formula = self:getFormula(fname)
	if formula then
		return formula(...)
	end
end

-- 输出管理器当前状态
function FormulaManager:dump()
	dump(self._formulas, "FormulaManager", 3)
end

return FormulaManager
