local C_LOGTAG = "main"

-------------------------------------------------------------------------
--							  全局变量定义
-------------------------------------------------------------------------
-- 标志
FLAG = FLAG or {}
FLAG.JIT = pcall(function() require("jit") end)	-- JIT环境
FLAG.DEVELOPMENT 		= true					-- 开发
FLAG.ENABLENETWORK	 	= true					-- 网络

-- 目录
DIRECTORY = DIRECTORY or {}
DIRECTORY.ARCHIVE = "saves"		-- 存档

-- 包
PACK = PACK or {}
PACK.FORMAT = PACK.FORMAT or ".pack"	-- 包格式
PACK.BASES = PACK.BASES or { "main" }	-- 基础包
PACK.BOOT = PACK.BOOT or {}				-- 启动包
PACK.LOADED = PACK.LOADED or {}			-- 加载包

-- 错误
ERROR = ERROR or {}
ERROR.INDEX_ENV_CONFLICT = true		-- 索引环境冲突
ERROR.INDEX_PATH_CONFLICT = true	-- 索引路径冲突
ERROR.DB_TABLE_KEY_CONFLICT = true	-- 数据表键值冲突

-- 路径
PATH = PATH or {}
PATH.SOURCE = "src"			-- 源码目录
PATH.RESOURCE = "res"		-- 资源目录

-- 键盘配置
KEYBOARD = KEYBOARD or {}
KEYBOARD.PRI = 1				-- 键盘优先级

-- 控制器配置
CONTROLLER = CONTROLLER or {}
CONTROLLER.PRI = 1				-- 控制器优先级

-------------------------------------------------------------------------
-- 禁止全局变量
if CC_DISABLE_GLOBAL then
    cc.enable_global(false)
end

logMgr:info(C_LOGTAG, "global variable define : %s", tostring(not CC_DISABLE_GLOBAL))

require("app.main.MyGame"):create():run()