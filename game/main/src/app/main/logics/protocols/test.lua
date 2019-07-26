--[[
	test protocol file
]]

local effil = cc.safe_require("effil")
local protMgr = require("app.main.modules.network.ProtocolManager"):getInstance()

local test = {}

function test.pack_test(writer,data)
	data = data or {}
	protMgr:packData(writer,"bBhHlLfd",data.arg1 or 0,data.arg2 or 0,data.arg3 or 0,data.arg4 or 0,data.arg5 or 0,data.arg6 or 0,data.arg7 or 0,data.arg8 or 0)
	protMgr:getPacker("string")(writer,data.arg9)
	protMgr:getPacker("[]")(writer,data.arg10,"int8")
	protMgr:getPacker("int64")(writer,data.arg11)
end

function test.unpack_test(reader)
	local data = effil.table()
	data.arg1,data.arg2,data.arg3,data.arg4,data.arg5,data.arg6,data.arg7,data.arg8=protMgr:unpackData(reader,"bBhHlLfd")
	data.arg9=protMgr:getUnpacker("string")(reader)
	data.arg10=protMgr:getUnpacker("[]")(reader,"int8")
	data.arg11=protMgr:getUnpacker("int64")(reader)
	return data
end

function test.pack_test_welcome(writer,data)
	data = data or {}
	protMgr:getPacker("string")(writer,data.text)
end

function test.unpack_test_welcome(reader)
	local data = effil.table()
	data.text=protMgr:getUnpacker("string")(reader)
	return data
end

return {
	{
		name = "test",
		cmd = 10000,
		pack = test.pack_test,
		unpack = test.unpack_test
	},
	{
		name = "test_welcome",
		cmd = 10001,
		pack = test.pack_test_welcome,
		unpack = test.unpack_test_welcome
	},
}
