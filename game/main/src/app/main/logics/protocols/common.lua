--[[
	common protocol file
]]

local effil = cc.safe_require("effil")
local protMgr = require("app.main.modules.network.ProtocolManager"):getInstance()

local common = {}

function common.pack_int64(writer,data)
	data = data or {}
	protMgr:packData(writer,"ll",data.low or 0,data.high or 0)
end

function common.unpack_int64(reader)
	local data = effil.table()
	data.low,data.high=protMgr:unpackData(reader,"ll")
	return data
end

return {
	{
		name = "int64",
		pack = common.pack_int64,
		unpack = common.unpack_int64
	},
}
