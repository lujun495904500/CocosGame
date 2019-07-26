--[[
	数据库管理器
--]]
local THIS_MODULE = ...
local C_LOGTAG = "DatabaseManager"

-- 数据库索引路径
local C_DB_IPATH = "db"

-- 数据表仓库
local DB_TABLES = {}

local DatabaseManager = class("DatabaseManager", DB_TABLES, require("app.main.modules.index.IndexListener"))

-- 获得单例对象
local instance = nil
function DatabaseManager:getInstance()
	if instance == nil then
		instance = DatabaseManager:create()
		indexMgr:addListener(instance, { C_DB_IPATH })
	end
	return instance
end

-------------------------IndexListener-------------------------
-- 清空索引
function DatabaseManager:onIndexesRemoved()
	self:clearDatabase()
	self:onIndexesLoaded(C_DB_IPATH, indexMgr:getIndex(C_DB_IPATH))
end

-- 加载索引路径
function DatabaseManager:onIndexesLoaded(ipath, ivalue)
	if ivalue then
		if ipath == C_DB_IPATH then
			for tbname,tbfiles in pairs(ivalue) do
				for _,tbfile in ipairs(tbfiles) do
					local tbdata = indexMgr:readJson(tbfile)
					if not tbdata then
						error(string.format("database file %s read fail !!!", tbfile))
					else
						self:registerTable(tbname, tbdata, tbfile)
					end
				end
			end
		end
	end
end
-------------------------IndexListener-------------------------

-- 注册数据库
function DatabaseManager:registerTable(tbname, newtable, tbfile)
	local dbtable = DB_TABLES[tbname]
	if not dbtable then
		dbtable = {}
		DB_TABLES[tbname] = dbtable
	end
	for tbkey,tbvalue in pairs(newtable) do 
		if dbtable[tbkey] then
			local msg = string.format("db table %s key %s conflict : %s", tbname, tbkey, tbfile or "[unknown]")
			if ERROR.DB_TABLE_KEY_CONFLICT then
				error(msg)
			else
				logMgr:warn(C_LOGTAG, msg)
			end
		end
		dbtable[tbkey] = tbvalue
	end
end

-- 清除数据库
function DatabaseManager:clearDatabase()
	for _,key in ipairs(table.keys(DB_TABLES)) do
		DB_TABLES[key] = nil
	end
end

return DatabaseManager
