--[[
	元数据管理器
--]]
local THIS_MODULE = ...

local MetaManager = class("MetaManager", require("app.main.modules.index.IndexListener"))

-- 获得单例对象
local instance = nil
function MetaManager:getInstance()
	if instance == nil then
		instance = MetaManager:create()
		indexMgr:addListener(instance)
	end
	return instance
end

-- 构造函数
function MetaManager:ctor()
	self._modules = {}   -- 元数据模块表
end

--[[
	注册元数据模块
	modname	 模块名
	metaipath		元数据索引路径
	classipath   	类索引路径
	objectipath  	对象索引路径
]]
function MetaManager:registerModule(modname, metaipath, classipath, objectipath)
	assert(not self._modules[modname],"meta module [" .. modname .. "] already exist!!!")
	if metaipath and (metaipath:byte(#metaipath) ~= 47) then -- /
		metaipath = metaipath .. "/"
	end
	if classipath and (classipath:byte(#classipath) ~= 47) then -- /
		classipath = classipath .. "/"
	end
	if objectipath and (objectipath:byte(#objectipath) ~= 47) then -- /
		objectipath = objectipath .. "/"
	end
	self._modules[modname] = {
		metaipath = metaipath,
		classipath = classipath,
		objectipath = objectipath,
		metas = {},		 	-- 元数据
		classes = {},	   	-- 类
		objects = {},	   	-- 对象
	}
end

--[[
	注销指定模块
	modname	 模块名
]]
function MetaManager:unRegisterModule(modname)
	if self._modules[modname] then
		self:releaseObjects(modname)
		self:releaseClasses(modname)
		self:releaseMetas(modname)
		self._modules[modname] = nil
	end
end

-------------------------IndexListener-------------------------
-- 清空索引
function MetaManager:onIndexesRemoved()
	self:releaseAllObjects(true)
	self:releaseAllClasses(true)
	self:releaseAllMetas()
end
-------------------------IndexListener-------------------------

--[[
	获得指定的元数据
	modname	 	模块名
	metatype	元数据类型
]]
function MetaManager:getMeta(modname, metatype)
	local module = self._modules[modname]
	if module then
		local meta = module.metas[metatype]
		if not meta then
			local metalua = indexMgr:getIndex(module.metaipath .. metatype)
			if metalua then
				meta = require(metalua)
				meta:setMetaType(metatype)
				module.metas[metatype] = meta
			end
		end
		return meta
	end
end

--[[
	获得模块所有元数据
	modname	 	模块名
]]
function MetaManager:getMetas(modname)
	local module = self._modules[modname]
	if module then
		for _,mtype in ipairs(table.keys(module.metaipath)) do
			self:getMeta(modname, mtype)
		end
		return module.metas
	end
end

--[[
	释放模块的元数据
	modname	 模块名
]]
function MetaManager:releaseMetas(modname)
	self._modules[modname].metas = {}
end

-- 释放所有元数据
function MetaManager:releaseAllMetas()
	for _,modname in ipairs(table.keys(self._modules)) do
		self:releaseMetas(modname)
	end
end

--[[
	获得指定的类
	modname	 模块名
	clsname	 类名
]]
function MetaManager:getClass(modname, clsname)
	local module = self._modules[modname]
	if module then
		local classobj = module.classes[clsname]
		if not classobj and module.classipath then
			local clsconf = indexMgr:readJsonConfig(indexMgr:getIndex(module.classipath .. clsname))
			if clsconf then
				local clsmeta = self:getMeta(modname, clsconf.meta)
				if clsmeta then
					classobj = class(clsname .. ":" .. clsmeta:getMetaType(), clsmeta)
					clsconf.clsname = clsname
					classobj:clsctor(clsconf)
					module.classes[clsname] = classobj
				end
			end
		end
		return classobj
	end
end

--[[
	释放模块的类
	modname	 模块名
	preload	 是否释放预加载类
]] 
function MetaManager:releaseClasses(modname, preload)
	local module = self._modules[modname]
	if module then
		for clsname,classobj in pairs(module.classes) do 
			if not classobj._preload or preload then
				classobj:clsdtor()	   	-- 类析构
				module.classes[clsname] = nil
			end
		end
	end
end

--[[
	释放所有的类
	preload	 是否释放预加载类
]] 
function MetaManager:releaseAllClasses(preload)
	for _,modname in ipairs(table.keys(self._modules)) do
		self:releaseClasses(modname, preload)
	end
end

--[[
	获得指定的对象
	modname	 模块名
	objname	 对象名
]]
function MetaManager:getObject(modname, objname)
	local module = self._modules[modname]
	if module then
		local object = module.objects[objname]
		if not object and module.objectipath then
			local objconf = indexMgr:readJsonConfig(indexMgr:getIndex(module.objectipath .. objname))
			if objconf then
				local objmeta = self:getMeta(modname, objconf.meta)
				if objmeta then
					objconf.name = objname
					object = objmeta:create(objconf)
					module.objects[objname] = object
				end
			end
		end
		return object
	end
end

--[[
	释放模块的对象
	modname	 模块名
	preload	 是否释放预加载对象
]] 
function MetaManager:releaseObjects(modname, preload)
	local module = self._modules[modname]
	if module then
		for objname,object in pairs(module.objects) do 
			if not object._preload or preload then
				object:dtor()		   -- 对象析构
				module.objects[objname] = nil
			end
		end
	end
end

--[[
	释放所有的对象
	preload	 是否释放预加载对象
]] 
function MetaManager:releaseAllObjects(preload)
	for _,modname in ipairs(table.keys(self._modules)) do
		self:releaseObjects(modname, preload)
	end
end

--[[
	创建指定类的对象
	modname	 	模块名
	metaorcls   元数据类型/类名
	...		 	创建对象的参数
]] 
function MetaManager:createObject(modname, metaorcls, ...)
	local module = self._modules[modname]
	if module then
		if module.classipath then
			local classobj = self:getClass(modname, metaorcls)
			if classobj then
				return classobj:create(...)
			end
		else
			local metaobj = self:getMeta(modname, metaorcls)
			if metaobj then
				return metaobj:create(...)
			end
		end
	end
end

--[[
	预加载指定的类 
	modname	 模块名
	clsname	 类名
]] 
function MetaManager:preloadClass(modname, clsname)
	self:getClass(modname, clsname)._preload = true
end

--[[
	获取模块所有类名
	modname	 模块名
]] 
function MetaManager:getAllClasses(modname)
	local module = self._modules[modname]
	if module then
		return table.keys(indexMgr:getIndex(module.classipath)) 
	end
end

--[[
	加载模块所有类
	modname	 模块名
]] 
function MetaManager:loadAllClasses(modname)
	for _,clsname in ipairs(self:getAllClasses(modname)) do 
		self:getClass(modname,clsname)
	end
end

--[[
	预加载指定的对象
	modname	 模块名
	objname	 对象名
]] 
function MetaManager:preloadObject(modname,objname)
	self:getObject(modname,objname)._preload = true
end

--[[
	获取模块所有对象名
	modname	 模块名
]] 
function MetaManager:getAllObjects(modname)
	local module = self._modules[modname]
	if module then
		return table.keys(indexMgr:getIndex(module.objectipath)) 
	end
end

--[[
	加载模块所有对象
	modname	 模块名
]] 
function MetaManager:loadAllObjects(modname)
	for _,objname in ipairs(self:getAllObjects(modname)) do 
		self:getObject(modname, objname)
	end
end

-- 输出指定模块状态
function MetaManager:dumpModule(modname, data)
	local module = self._modules[modname]
	if module then
		dump({
			module = module,
			data = data or {}
		}, modname, 3)
	end
end

-- 输出所有模块状态
function MetaManager:dump()
	dump(self._modules, "MetaManager", 3)
end

return MetaManager
