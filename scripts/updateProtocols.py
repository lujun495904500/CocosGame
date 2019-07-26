# -*- coding: utf-8 -*-

import xlrd,os,shutil,re,getopt,sys
from toolkits import tools

CURPATH = os.path.split(os.path.realpath(__file__))[0]

# 正则替换
RE_REPS = (
	("/\*{1,2}[\s\S]*?\*/",""),
	("//[\s\S]*?\n",""),
	("[\s]+"," ")
)

# 类型格式
TYPE_FMT = {
	"int8"		:("b","0"),
	"uint8"		:("B","0"),
	"int16"		:("h","0"),
	"uint16"	:("H","0"),
	"int32"		:("l","0"),
	"uint32"	:("L","0"),
	"float"		:("f","0"),
	"double"	:("d","0")
}

# 协议文件模板
TEMPLATE_PROTFILE = '''--[[
	%s protocol file
]]

local effil = cc.safe_require("effil")
local protMgr = require("app.main.modules.network.ProtocolManager"):getInstance()

local %s = {}
%s
return {
	%s
}
'''

# 打包函数模板
TEMPLATE_PACKFUN = '''
function %s.pack_%s(writer,data)
	data = data or {}
\t%s
end
'''

# 解包函数模板
TEMPLATE_UNPACKFUN='''
function %s.unpack_%s(reader)
	local data = effil.table()
\t%s
	return data
end
'''

# 配置项模板
TEMPLATE_CONFITEM = '''{
		name = "%s",
		cmd = %d,
		pack = %s,
		unpack = %s
	},'''
	
# 配置项模板(无命令)
TEMPLATE_CONFITEM_NOCMD = '''{
		name = "%s",
		pack = %s,
		unpack = %s
	},'''

'''协议更新器'''
class ProtocolUpdater:
	def __init__(self, config, nodename = "main"):
		self.config = config
		self.updateconf = config["update"]
		self.nodename = nodename
		self.nodepath = CURPATH + "/" + config["path"]["game"] + "/" + nodename
		if not os.path.isdir(self.nodepath):
			raise Exception("无法识别的节点: " + nodename + " !!!")
		
		self.protpath = self.nodepath + "/origins/protocols"
		self.protrespath = self.nodepath + "/src/app/" + nodename + "/logics/protocols/"
		self.residxpath = self.nodepath + "/res/" + nodename + "/indexes"
		self.residxconf = self.nodepath + "/res/" + nodename + "/indexes.json"
		
	def update(self):
		if os.path.isdir(self.protpath):
			if not os.path.isdir(self.protrespath):
				os.makedirs(self.protrespath)
			tools.clear_dir(self.protrespath)
			
			# 构建协议文件
			self.protindexes = []
			for file in os.listdir(self.protpath):
				if file.endswith(".prot"):
					self.parseProtFile(self.protpath + "/" + file)
			
			# 构建协议索引
			if not os.path.isdir(self.residxpath):
				os.makedirs(self.residxpath)
			tools.write_utf8json({ "prot":self.protindexes }, self.residxpath + "/prot_auto.json", self.config["debug"])
			
			# 更新资源索引表
			idxconfpath,_ = os.path.split(self.residxconf)
			if not os.path.isdir(idxconfpath):
				os.makedirs(idxconfpath)
			if os.path.isfile(self.residxconf):
				idxconf = tools.read_json(self.residxconf)
			else:
				idxconf = {}
			idxconf["prot_auto"] = "$(respath)/" + self.nodename + "/indexes/prot_auto.json"
			tools.write_utf8json(idxconf, self.residxconf, self.config["debug"])
	
	# 获得类型格式
	def getTypeFormat(self,ptype):
		for p,f in TYPE_FMT.items():
			if ptype == p:
				return f
		return None
			
	def parseProtFile(self, protpath):
		_,protfile = os.path.split(protpath)
		filename,_ = os.path.splitext(protfile)
		
		content = tools.read_file(protpath)
		for (restr,repstr) in RE_REPS:
			content = re.sub(restr,repstr,content)
			
		protocol = True		# 开启协议
		command  = 1		# 当前命令
		funclist = []		# 函数表
		protconf = []		# 协议配置
		for stmt in re.findall(r'#.*?;|struct .*?};',content):
			stmt = stmt.rstrip(';')
			if stmt.startswith("#"):
				items = stmt.split(" ")
				if items[0] == "#command":
					command = int(items[1])
				elif items[0] == "#open":
					if items[1] == "protocol":
						protocol = True
				elif items[0] == "#close":
					if items[1] == "protocol":
						protocol = False
			elif stmt.startswith("struct"):
				groups = re.search("struct[\s]+([\w]+)[\s]*{(.*)}",stmt)
				packlist = []
				unpacklist = []
				fieldcache = []
				def buildFieldCache(fieldcache):
					if len(fieldcache) > 0:
						fmtlist = []
						rvarlist = []
						wvarlist = []
						for field in fieldcache:
							fmtlist.append(field["fmt"][0])
							rvarlist.append("data.%s" % field["var"])
							wvarlist.append("data.%s or %s" % (field["var"], field["fmt"][1]))
						packlist.append(r'protMgr:packData(writer,"%s",%s)' % ("".join(fmtlist), ",".join(wvarlist)))
						unpacklist.append(r'%s=protMgr:unpackData(reader,"%s")' % (",".join(rvarlist), "".join(fmtlist)))
						del fieldcache[:]
				for field in re.findall(r'[\w].*?;',groups[2]):
					items = field.rstrip(';').split(" ")
					if len(items) == 2:
						ffmt = self.getTypeFormat(items[0])
						if self.updateconf["proto_opt"] and ffmt:
							fieldcache.append({ "fmt":ffmt, "type":items[0], "var": items[1]})
							continue
						buildFieldCache(fieldcache)
						packlist.append(r'protMgr:getPacker("%s")(writer,data.%s)' % (items[0], items[1]))
						unpacklist.append(r'data.%s=protMgr:getUnpacker("%s")(reader)' % (items[1], items[0]))
					elif len(items) == 3 and items[1] == "[]":
						buildFieldCache(fieldcache)
						packlist.append(r'protMgr:getPacker("[]")(writer,data.%s,"%s")' % (items[2], items[0]))
						unpacklist.append(r'data.%s=protMgr:getUnpacker("[]")(reader,"%s")' % (items[2], items[0]))
				buildFieldCache(fieldcache)
				funclist.append(TEMPLATE_PACKFUN % (filename, groups[1], "\n\t".join(packlist)))
				funclist.append(TEMPLATE_UNPACKFUN % (filename, groups[1], "\n\t".join(unpacklist)))
				
				if protocol:
					protconf.append(TEMPLATE_CONFITEM % (groups[1], command, 
						r'%s.pack_%s' % (filename, groups[1]),
						r'%s.unpack_%s' % (filename, groups[1])))
					command = command + 1
				else:
					protconf.append(TEMPLATE_CONFITEM_NOCMD % (groups[1],
						r'%s.pack_%s' % (filename, groups[1]),
						r'%s.unpack_%s' % (filename, groups[1])))
				print("生成协议:%s" % (groups[1]))
		
		tools.write_file(TEMPLATE_PROTFILE % (filename, filename, "".join(funclist) ,"\n\t".join(protconf)), 
			self.protrespath + "/" + filename + ".lua")
		self.protindexes.append("app." + self.nodename +".logics.protocols." + filename)

def updateProtocols():
	config = tools.get_scriptconfig()
	dopacks = config['update']['dopacks']
	
	# 更新节点
	def updateNode(nodename):
		print(">>>>>>>>>>>>>>>>>>>[%s]协议>>>>>>>>>>>>>>>>>>" % nodename)
		try:
			ProtocolUpdater(config, nodename).update()
			print("<<<<<<<<<<<<<<<<<<更新完成<<<<<<<<<<<<<<<<<<<\n")
		except Exception as e:
			print(e)
			print("<<<<<<<<<<<<<<<<<<<更新失败!!!<<<<<<<<<<<<<<<<<<<\n")
	
	# 遍历所有包
	for nodename in os.listdir(CURPATH + "/" + config["path"]["game"]):
		if os.path.isdir(CURPATH + "/" + config["path"]["game"] + "/" + nodename) and tools.wildcard_matchs(dopacks,nodename):
			updateNode(nodename)
	
	
if __name__ == "__main__":
	updateProtocols()
	os.system("pause")
