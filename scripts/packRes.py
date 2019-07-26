# -*- coding: utf-8 -*-

import os,struct,getopt,sys,random,zlib,math,copy
from toolkits import tools

CURPATH = os.path.split(os.path.realpath(__file__))[0]

# 文件标志
FILEFLAG = {
	"CRYPTO"	:1,	# 加密
	"COMPRESS"	:2, # 压缩
}

# 版本号
BUILDVERSION	= 1

'''资源打包器'''
class ResourcePacker:
	def __init__(self,config,options = {}):
		self.config = config
		self.options = options
		self.nodespath = CURPATH + "/" + config["path"]["game"]
		self.packspath = CURPATH + "/" + config["path"]["packs"]
		self.temppath = CURPATH + "/temp"
		self.latestpath = self.packspath + "/latest"
		self.compspath = self.packspath + "/installed/completes"
		
	def __del__(self):
		if self.logfile != None:
			self.logfile.close()
			self.logfile = None
	
	def pack(self):
		if os.path.isdir(self.nodespath):
			if not os.path.isdir(self.latestpath):
				os.makedirs(self.latestpath)
			if not os.path.isdir(self.compspath):
				os.makedirs(self.compspath)
			if not os.path.isdir(self.temppath):
				os.makedirs(self.temppath)
			self.logfile = open(self.packspath + "/pack_logs.txt","w")
			for nodename in os.listdir(self.nodespath):
				if os.path.isdir(self.nodespath + "/" + nodename):
					if "packs" in self.options:
						packnodes = self.options["packs"]
						if (nodename in packnodes and packnodes[nodename] == False) or \
							(not tools.wildcard_matchs(self.config['pack']['dopacks'], nodename)):
							continue
					self.packNode(nodename)
	
	def writeLog(self,log):
		if self.logfile != None:
			self.logfile.write(log)
		if self.config["printlog"]:
			print(log,end='')
	
	def packNode(self,nodename):
		if os.path.isfile(self.compspath + "/" + nodename + ".pack"):
			verscode = 0
			with open(self.compspath + "/" + nodename + ".pack","rb") as f:
				verscode = tools.getLongValue(f.read(4))
			addversion = 1
			if "versadds" in self.options:
				versadds = self.options["versadds"]
				if nodename in versadds:
					addversion = versadds[nodename]
			addvers = int(math.pow(1000,addversion-1))
			verscode -= verscode % addvers
			verscode += addvers
		else:
			verscode = self.config["pack"]["rootversion"]
			
		self.writeLog("---------------------------------PACK--------------------------------\n")
		self.writeLog("Node Name : %s\n" % nodename)
		self.writeLog("Node Version : %s\n" % tools.getVersionName(verscode))
		self.writeLog("Build Version : %d\n\n" % BUILDVERSION)
		
		packsize = 0
		filelist = self.buildFileList(self.nodespath + "/" + nodename,"")
		with open(self.latestpath + "/" + nodename + ".pack", 'wb') as pfile:
			packsize = self.writePackFile(pfile,nodename,verscode,filelist)
		
		self.writeLog("\nTotal Size : %s\n" % tools.format_filesize(packsize))
		self.writeLog("----------------------------------END--------------------------------\n\n")
		
	def getAESKey(self,kname):
		if self.config["pack"]["randaeskey"]:
			return random.randint(0,len(self.config["aes"]["keys"])-1)
		else:
			hash = self.config["pack"]["aeshash"]
			for c in kname:
				hash = hash*31 + ord(c)
			return hash % len(self.config["aes"]["keys"])
		
	def writePackFile(self,pfile,nodename,verscode,filelist):
		pfile.write(tools.getLongBlock(verscode))
		pfile.write(tools.getShortBlock(BUILDVERSION))
		
		headfile = self.temppath + "/" + nodename + ".head"
		with open(headfile, 'wb') as hfile:
			self.writeHeadFile(hfile,filelist)
		self.writeLog("build head %s\n" % headfile)
		
		aeskeys = self.config["aes"]["keys"]
		kidx = self.getAESKey("pack_head")
		crypfile = headfile + "_en"
		tools.encrypto_aes(aeskeys[kidx]["key"],aeskeys[kidx]["iv"],headfile,crypfile)
		self.writeLog("encrypto head %s\n" % crypfile)
		
		headsize = os.path.getsize(crypfile)
		pfile.write(tools.getLongBlock(headsize))
		pfile.write(tools.getByteBlock(kidx))
		with open(crypfile,"rb") as file:
			pfile.write(file.read())
		headsize += 11
		self.writeLog("Head Size : %s\n\n" % tools.format_filesize(headsize))
		
		contentsize = self.writeContentFile(pfile,nodename,filelist)
		self.writeLog("Content Size : %s\n" % tools.format_filesize(contentsize))
		
		return headsize + contentsize
		
	def writeHeadFile(self,hfile,filelist):
		# 处理文件
		extfiles = []
		for fconf in filelist:
			fpath = fconf["path"]
			if fconf["type"] == "FILE" and fpath.endswith(".lua") and self.config["pack"]["luacompile"] and \
				(self.config["pack"]["lua32"] or self.config["pack"]["lua64"]):
				fconf["wpath"] = fpath + "c"
				if self.config["pack"]["lua32"]:
					fconf["luacompile"] = "lua32"
				else:
					fconf["luacompile"] = "lua64"
					fconf["wpath"] = "/64bit" + fconf["wpath"]
				if self.config["pack"]["lua32"] and self.config["pack"]["lua64"]:
					extfile = copy.deepcopy(fconf)
					extfile["luacompile"] = "lua64"
					extfile["wpath"] = "/64bit" + extfile["wpath"]
					extfiles.append(extfile)
			else:
				fconf["wpath"] = fpath
		filelist.extend(extfiles)
		
		# 写入文件头
		hfile.write(tools.getLongBlock(len(filelist)))
		for fconf in filelist:
			hfile.write(tools.getStringBlock(fconf["wpath"]))
	
	def writeContentFile(self,cfile,nodename,filelist):
		contentsize = 0
		for fconf in filelist:
			fblock = self.buildFileConfig(nodename,fconf)
			cblock = self.buildFileContent(nodename,fconf)
			cfile.write(fblock)
			cfile.write(tools.getLongBlock(len(cblock)))
			cfile.write(cblock)
			
			fwsize = (4 + len(fblock) + len(cblock))
			contentsize += fwsize
			self.writeLog("packing [%s.pack] <<< %s | %s | %s\n" % (nodename,
				tools.format_filesize(fwsize),
				self.getConfigString(fconf),
				fconf["wpath"]))
		return contentsize
		
	def getConfigString(self,fconf):
		ftype = "F" if fconf["type"] == "FILE" else "D"
		crypto = "E" if fconf["flag"] & FILEFLAG["CRYPTO"] != 0 else "_"
		compress = "C" if fconf["flag"] & FILEFLAG["COMPRESS"] != 0 else "_"
		keyindex = "%3d" % fconf["keyindex"] if crypto == "E" else "   "
		if "luacompile" in fconf:
			if fconf["luacompile"] == "lua64":
				compile = "64"
			else:
				compile = "32"
		else:
			compile = "  "
		
		return "%s%s%s %s %s" % (ftype,crypto,compress,keyindex,compile)
	
	def shouldCrypto(self,filepath):
		_,filename = os.path.split(filepath)
		return tools.wildcard_matchs(self.config["pack"]["cryptos"],filename)
	
	def shouldCompress(self,filepath):
		filesize = os.path.getsize(filepath)
		_,filename = os.path.split(filepath)
		for comps in self.config["pack"]["compresses"]:
			if tools.wildcard_match(comps["file"],filename) and filesize >= comps["size"]:
				return True
		return False
		
	def buildFileConfig(self,nodename,fconf):
		if fconf["type"] == "FILE":
			filepath = self.nodespath + "/" + nodename + fconf["path"]
			fconf["flag"] = 0
			fconf["keyindex"] = 0
			
			if self.shouldCrypto(filepath):
				fconf["flag"] |= FILEFLAG["CRYPTO"]	
				fconf["keyindex"] = self.getAESKey(fconf["path"])
				
			if self.shouldCompress(filepath):
				fconf["flag"] |= FILEFLAG["COMPRESS"]
			
			return struct.pack("<BIHB",0,fconf["filesize"],fconf["flag"],fconf["keyindex"])
		else:	# directory
			fconf["flag"] = 0
			fconf["keyindex"] = 0
			
			if self.config["pack"]["cryptodir"]:
				fconf["flag"] |= FILEFLAG["CRYPTO"]	
				fconf["keyindex"] = self.getAESKey(fconf["path"])
			
			return struct.pack("<BHB",1,fconf["flag"],fconf["keyindex"])
		
	def buildFileContent(self,nodename,fconf):
		if fconf["type"] == "FILE":
			filecontent = None
			filepath = self.nodespath + "/" + nodename + fconf["path"]
			
			if "luacompile" in fconf:
				templua = self.temppath + "/lua.bytes"
				tools.compile_lua(filepath,fconf["luacompile"] == "lua64",self.config["pack"]["luajit"],templua)
				filepath = templua
				
			if fconf["flag"] & FILEFLAG["CRYPTO"] != 0:
				cryptofile = self.temppath + "/file.crypto"
				keys = self.config["aes"]["keys"][fconf["keyindex"]]
				tools.encrypto_aes(keys["key"],keys["iv"],filepath,cryptofile)
				filepath = cryptofile
				
			with open(filepath, 'rb') as f:
				filecontent = f.read()
				if fconf["flag"] & FILEFLAG["COMPRESS"] != 0:
					uncompsize = len(filecontent)
					filecontent = zlib.compress(filecontent)
					filecontent = struct.pack("I%ds" % len(filecontent),uncompsize,filecontent)
					
			return filecontent
		else:
			filecontent = tools.getShortBlock(len(fconf["files"]))
			for fname in fconf["files"]:
				filecontent += tools.getStringBlock(fname)
			
			if fconf["flag"] & FILEFLAG["CRYPTO"] != 0:
				originfile = self.temppath + "/dir.origin"
				cryptofile = self.temppath + "/dir.crypto"
				with open(originfile,"wb") as f:
					f.write(filecontent)
				keys = self.config["aes"]["keys"][fconf["keyindex"]]
				tools.encrypto_aes(keys["key"],keys["iv"],originfile,cryptofile)
				with open(cryptofile, 'rb') as f:
					filecontent = f.read()
				
			return filecontent
		
	def buildFileList(self,respath,packpath,filelist = None,subfiles = None):
		if filelist == None:
			filelist = []
		if subfiles == None:
			subfiles = []
		ignorelist = self.getIgnoreList(respath)
		for file in os.listdir(respath):
			if file != self.config["pack"]["ignorefile"] and not tools.wildcard_matchs(ignorelist,file):
				subfiles.append(file)
				if os.path.isdir(respath + "/" + file):
					subfiles_ = []
					if self.config["pack"]["packdir"]:
						filelist.append({
							"type":"DIRECTORY",
							"path": packpath + "/" + file,
							"files":subfiles_,
						})
					self.buildFileList(respath + "/" + file,packpath + "/" + file,filelist,subfiles_)
				else:
					filelist.append({
						"type":"FILE",
						"path": packpath + "/" + file,
						"filesize":os.path.getsize(respath + "/" + file),
					})
		return filelist
		
	def getIgnoreList(self,path):
		ignfile = path + "/" + self.config["pack"]["ignorefile"]
		ignorelist = []
		if os.path.isfile(ignfile):
			with open(ignfile, 'r') as f:
				for line in f.readlines():
					ignorelist.append(line.strip('\n'))
		return ignorelist + list(self.config["pack"]["ignores"])
	
if __name__ == "__main__":
	try:
		packs = {}
		versadds = {}
		'''
			命令分割	,
			使能打包	[nodename]=[true/false] 默认 true
			提升版本	[nodename]+[1/2/3]		默认 1 (1 修订版本, 2 次本版, 3 主版本)
		'''
		packcmdsstr = input("输入打包命令:").strip()
		if packcmdsstr != "":
			packcmdstr = packcmdsstr.split(",")
			for packcmd in packcmdstr:
				if "+" in packcmd:
					optstr = packcmd.split("+")
					if len(optstr) == 2:
						versadds[optstr[0].strip()] = int(optstr[1].strip())
				elif "=" in packcmd:
					optstr = packcmd.split("=")
					if len(optstr) == 2:
						packs[optstr[0].strip()] = optstr[1].strip().upper() != "FALSE"
		ResourcePacker(tools.get_scriptconfig(),{
			"packs":packs,
			"versadds":versadds
		}).pack()
		print("资源打包完成")
	except Exception as e:
		print(e)
	os.system("pause")