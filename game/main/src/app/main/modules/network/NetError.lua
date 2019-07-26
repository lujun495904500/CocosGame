--[[
	网络错误
]]

local NetError = {
	SHAKE_PACK_FLAG 		= 1,		-- 握手包标识
	PROTOCOL_VERSION		= 2,		-- 协议版本号
	RSA_ENCRYPT				= 3,		-- rsa加密
	RSA_DECRYPT				= 4,		-- rsa解密
	DATA_SEND				= 5,		-- 数据发送
	UNK_DATA_ENCRYPT		= 6,		-- 未知数据加密算法
	UNK_DATA_DECRYPT		= 7,		-- 未知数据解密算法
	NOT_DATA_ENCKEY			= 8,		-- 无数据加密密钥
	NOT_DATA_DECKEY			= 9,		-- 无数据解密密钥
	AES_ENCRYPT				= 10,		-- aes加密
	AES_DECRYPT				= 11,		-- aes解密
	SHAKE_ENCRYPT_FLAG		= 12,		-- 握手加密标识
	SHAKE_ENCRYPT_METHOD	= 13,		-- 握手加密方式
	HEART_TIMEOUT			= 14,		-- 心跳超时
	SHAKE_TIMEOUT			= 15,		-- 握手超时
	DATA_COMPRESS			= 16,		-- 数据压缩
	DATA_UNCOMPRESS			= 17,		-- 数据解压
	DATA_RECIVE				= 18,		-- 数据接收
	PACK_TYPE				= 19,		-- 包类型
}

return NetError
