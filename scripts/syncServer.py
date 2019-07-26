# -*- coding: utf-8 -*-

import os,sys,re,shutil,time
from ftplib import FTP
from toolkits import tools

CURPATH = os.path.split(os.path.realpath(__file__))[0]

# zlib 格式
ZLIBFORMAT = "%d.zlib"

# 重连时间
RECONNECTTIME = 5

''' 服务器同步器 '''
class ServerSynchro:
	def __init__(self,config,options = {}):
		self.config = config
		self.syncconf = config["sync"]
		self.ftpconf = self.syncconf["ftp"]
		self.completenum = self.syncconf["completenum"]
		self.options = options
		self.packspath = CURPATH + "/" + config["path"]["packs"]
		self.compspath = self.packspath + "/installed/completes"
		self.patchspath = self.packspath + "/installed/patchs"
		self.temppath = CURPATH + "/temp"
		self.rmconfpath = self.syncconf["dataroot"] + "/" + self.syncconf["gameconf"]
		self.tmpconfpath = self.temppath + "/" + self.syncconf["gameconf"]
		self.tmpconfjson = self.temppath + "/" + self.syncconf["gameconf"] + "_dec"
		self.ftp = None
		self.logfile = None
		
	def __del__(self):
		self.ftp_disconnect()
		if self.logfile != None:
			self.logfile.close()
			self.logfile = None
		
	def get_absolutepath(self,path):
		if not path.startswith("/"):
			path = self.ftp.pwd() + path
		return path
		
	def is_dirsexsit(self,path):
		pathsplit = [x for x in path.split("/") if x != ""]
		if path.startswith("/"):
			npath = "/"
		else:
			npath = self.ftp.pwd()
		pindex = 0
		while pindex < len(pathsplit):
			exsit = False
			def dirline(line):
				nonlocal exsit
				if not exsit:
					lines = re.split(r'[ ]+',line)
					if lines[0].startswith("d") and lines[-1] == pathsplit[pindex]:
						exsit = True
			self.ftp.dir(npath,dirline)
			npath += pathsplit[pindex] + "/"
			pindex += 1
			if not exsit:
				return False
		return True
		
	def is_fileexsit(self,filepath):
		filedir,filename = os.path.split(filepath)
		if not self.is_dirsexsit(filedir):
			return False
		filedir = self.get_absolutepath(filedir)
		exsit = False
		def dirline(line):
			nonlocal exsit
			if not exsit:
				lines = re.split(r'[ ]+',line)
				if lines[0].startswith("-") and lines[-1] == filename:
						exsit = True
		self.ftp.dir(filedir,dirline)
		return exsit
		
	def mkdirs(self,path):
		pathsplit = [x for x in path.split("/") if x != ""]
		if path.startswith("/"):
			npath = "/"
		else:
			npath = self.ftp.pwd()
		pindex = 0
		while pindex < len(pathsplit):
			exsit = False
			def dirline(line):
				nonlocal exsit
				if not exsit:
					lines = re.split(r'[ ]+',line)
					if lines[0].startswith("d") and lines[-1] == pathsplit[pindex]:
						exsit = True
			self.ftp.dir(npath,dirline)
			npath += pathsplit[pindex] + "/"
			pindex += 1
			if not exsit:
				self.ftp.mkd(npath)
	
	def cleardir(self,path):
		path = self.get_absolutepath(path)
		if not path.endswith("/"):
			path += "/"
		if self.is_dirsexsit(path):
			subfiles = []
			def dirline(line):
				nonlocal subfiles
				lines = re.split(r'[ ]+',line)
				subfiles.append({
					"type":"D" if lines[0].startswith("d") else "F",
					"name":lines[-1]
				})
			self.ftp.dir(path,dirline)
			for subfile in subfiles:
				if subfile["type"] == "F":
					self.ftp.delete(path + subfile["name"])
				else:
					self.rmdir(path + subfile["name"])
		
	def rmdir(self,path):
		path = self.get_absolutepath(path)
		if not path.endswith("/"):
			path += "/"
		if self.is_dirsexsit(path):
			self.cleardir(path)
			self.ftp.rmd(path)
	
	def download_file(self,rmpath,lcpath,bufsize = 8192):
		if self.is_fileexsit(rmpath):
			rmpath = self.get_absolutepath(rmpath)
			with open(lcpath,"wb") as f:
				self.ftp.retrbinary("RETR %s" % rmpath,f.write,bufsize)
			return True
		return False
		
	def redownload_file(self,rmpath,lcpath,bufsize = 8192,count = 3):
		for tryn in range(0,count):
			try:
				if tryn > 0:
					self.writeLog("download file fail retry %d ...\n" % tryn)
				return self.download_file(rmpath,lcpath,bufsize)
			except Exception as e:
				self.ftp_reconnect()
		raise Exception("download file %s fail!" % lcpath)
		
	def upload_file(self,lcpath,rmpath,cover = False,bufsize = 8192):
		if not self.is_fileexsit(rmpath) or cover:
			rmpath = self.get_absolutepath(rmpath)
			rmdir,_ = os.path.split(rmpath)
			self.mkdirs(rmdir)
			with open(lcpath,"rb") as f:
				self.ftp.storbinary("STOR %s" % rmpath,f,bufsize)
			return True
		return False
	
	def reupload_file(self,lcpath,rmpath,cover = False,bufsize = 8192,count = 3):
		for tryn in range(0,count):
			try:
				if tryn > 0:
					self.writeLog("upload file fail retry %d ...\n" % tryn)
				return self.upload_file(lcpath,rmpath,cover,bufsize)
			except Exception as e:
				self.ftp_reconnect()
		raise Exception("upload file %s fail!" % rmpath)
	
	def writeLog(self,log):
		if self.logfile != None:
			self.logfile.write(log)
		if self.config["printlog"]:
			print(log,end='')
			
	def getConfigAES(self):
		return self.config["aes"]["keys"][self.config["aes"]["confindex"]]
			
	def load_config(self):
		if not self.redownload_file(self.rmconfpath,self.tmpconfpath):
			self.packsconf = {}
			self.rmgameconf = {
				"packs":self.packsconf
			}
			
			self.writeLog("build new config\n")
			
		else:
			confaes = self.getConfigAES()
			tools.decrypto_aes(confaes["key"],confaes["iv"],self.tmpconfpath,self.tmpconfjson)
			self.rmgameconf = tools.read_json(self.tmpconfjson)
			if "packs" in self.rmgameconf:
				self.packsconf = self.rmgameconf["packs"]
			else:
				self.packsconf = {}
				self.rmgameconf["packs"] = self.packsconf
			
			self.writeLog("load config from server\n")
		# 更新剧本
		self.rmgameconf["plays"] = tools.read_json(CURPATH + "/" + self.config["path"]["game"] + "/plays.json")
			
	def save_config(self):
		tools.write_json(self.rmgameconf,self.tmpconfjson,True)
		confaes = self.getConfigAES()
		tools.encrypto_aes(confaes["key"],confaes["iv"],self.tmpconfjson,self.tmpconfpath)
		upresult = self.reupload_file(self.tmpconfpath,self.rmconfpath,True)
		
		self.writeLog("save config : %s\n" % str(upresult))
		
		return upresult
		
	def ftp_disconnect(self):
		if self.ftp != None:
			self.ftp.close()
			self.ftp = None
		
	def ftp_connect(self):
		self.ftp_disconnect()
		self.ftp = FTP()
		self.ftp.connect(self.ftpconf["connect"]["ip"],self.ftpconf["connect"]["port"])
		self.ftp.login(self.ftpconf["login"]["username"],self.ftpconf["login"]["password"])
		
	def ftp_reconnect(self):
		self.ftp_disconnect()
		time.sleep(RECONNECTTIME)
		self.ftp_connect()
		
	def sync(self):
		self.logfile = open(self.packspath + "/sync_logs.txt","w")
		
		self.writeLog("sync gamedata to server ...\n")
		
		self.ftp_connect()
		self.mkdirs(self.syncconf["dataroot"])
		self.load_config()
		
		for filename in os.listdir(self.compspath):
			nodename,_ = os.path.splitext(filename)
			verscode = 0
			with open(self.compspath + "/" + filename,"rb") as f:
				verscode = tools.getLongValue(f.read(4))
			if nodename not in self.packsconf or self.packsconf[nodename]["verscode"] < verscode:
				self.writeLog("---------------------------------SYNC--------------------------------\n")
				self.syncNode(nodename, verscode)
				self.writeLog("----------------------------------END--------------------------------\n\n")
				
		self.save_config()
		
	def is_rmpatchexsit(self,nodename,patchname):
		if nodename in self.packsconf:
			if "patchs" in self.packsconf[nodename]:
				if patchname in self.packsconf[nodename]["patchs"]:
					return True
		return False			
		
	def syncNode(self,nodename,verscode):
		self.writeLog("Node Name : %s\n" % nodename)
		self.writeLog("Node Version : %s\n\n" % tools.getVersionName(verscode))
		
		self.writeLog("Sync Complete Pack ... ...\n")
		
		# 同步整包
		rmcompdir = self.syncconf["dataroot"] + "/packs/completes/" + nodename + "/" + tools.getVersionName(verscode)
		if not self.is_dirsexsit(rmcompdir):
			rmcomptmp = self.syncconf["dataroot"] + "/packs/completes/" + nodename + "/temp"
			self.mkdirs(rmcomptmp)
			self.cleardir(rmcomptmp)
			lccmptmp = self.temppath + "/completetemp"
			if not os.path.isdir(lccmptmp):
				os.makedirs(lccmptmp)
			tools.clear_dir(lccmptmp)
			
			filecount = tools.split_file(self.compspath + "/" + nodename + ".pack",lccmptmp,ZLIBFORMAT,self.syncconf["zlibmaxsize"],True)
			
			self.writeLog("Split Complete Pack To %d Files \n" % filecount)
			
			totalsize = 0
			for file in os.listdir(lccmptmp):
				upresult = self.reupload_file(lccmptmp + "/" + file,rmcomptmp + "/" + file,True)
				totalsize += os.path.getsize(lccmptmp + "/" + file)
				
				self.writeLog("Upload Split File %s/%s %s\n" % (nodename,file,"SUCCESS" if upresult else "FAILURE"))
			
			if nodename not in self.packsconf:
				self.packsconf[nodename] = {}
			self.packsconf[nodename]["verscode"] = verscode
			self.packsconf[nodename]["versname"] = tools.getVersionName(verscode)
			self.packsconf[nodename]["complete"] = {
				"path" : rmcompdir[len(self.syncconf["dataroot"]):],
				"format" : ZLIBFORMAT,
				"count" : filecount,
				"size" : totalsize
			}
			
			tools.write_json(self.packsconf[nodename], self.temppath + "/complete.config.json")
			upresult = self.reupload_file(self.temppath + "/complete.config.json",rmcomptmp + "/config.json",True)
			
			self.ftp.rename(rmcomptmp,rmcompdir)
		else:
			downresult = self.redownload_file(rmcompdir + "/config.json",self.temppath + "/complete.config.json")
			if not downresult:
				raise Exception("read fail : " + rmcompdir + "/config.json")
			completeconf = tools.read_json(self.temppath + "/complete.config.json")
			if nodename not in self.packsconf:
				self.packsconf[nodename] = {}
			self.packsconf[nodename]["verscode"] = completeconf["verscode"]
			self.packsconf[nodename]["versname"] = completeconf["versname"]
			self.packsconf[nodename]["complete"] = completeconf["complete"]
			
		self.writeLog("Sync Complete Pack End\n")
		
		# 检查多余的整包
		packvers = []
		for fname,attr in self.ftp.mlsd(self.syncconf["dataroot"] + "/packs/completes/" + nodename + "/",["type"]):
			if attr['type'] == "dir":
				packvers.append(tools.getVersionCode(fname))
		if len(packvers) > self.completenum:
			self.writeLog("\n")
			packvers = sorted(packvers, reverse=True)[self.completenum:]
			for packver in packvers:
				self.rmdir(self.syncconf["dataroot"] + "/packs/completes/" + nodename + "/" + tools.getVersionName(packver))
				self.writeLog("Remove Unnecessary Complete Pack %s\n" % (nodename + "/" + tools.getVersionName(packver)))
	
		# 同步补丁
		if os.path.isdir(self.patchspath + "/" + nodename):
			self.writeLog("\nSync Patch ... ...\n")
	
			rmpatchroot = self.syncconf["dataroot"] + "/packs/patchs/%s" % nodename
			rmpatchtmp = rmpatchroot + "/temp"
			self.mkdirs(rmpatchtmp)
			lcpatchtmp = self.temppath + "/patchtemp"
			if not os.path.isdir(lcpatchtmp):
				os.makedirs(lcpatchtmp)
			if nodename not in self.packsconf:
				self.packsconf[nodename] = {}
			if "patchs" not in self.packsconf[nodename]:
				self.packsconf[nodename]["patchs"] = {}
			for patch in os.listdir(self.patchspath + "/" + nodename):
				patchname,patchext = os.path.splitext(patch)
				rmpatchdir = rmpatchroot + "/" + patchname
				if not self.is_rmpatchexsit(nodename, patchname):
					if not self.is_dirsexsit(rmpatchdir):
						self.cleardir(rmpatchtmp)
						tools.clear_dir(lcpatchtmp)
						filecount = tools.split_file(self.patchspath + "/" + nodename + "/" + patch,lcpatchtmp,ZLIBFORMAT,self.syncconf["zlibmaxsize"],True)
						
						self.writeLog("Split %s To %d Files \n" % (patch,filecount))
						
						totalsize = 0
						for file in os.listdir(lcpatchtmp):
							upresult = self.reupload_file(lcpatchtmp + "/" + file,rmpatchtmp + "/" + file,True)
							totalsize += os.path.getsize(lcpatchtmp + "/" + file)
							
							self.writeLog("Upload Split File %s/%s/%s %s\n" % (nodename,patchname,file,"SUCCESS" if upresult else "FAILURE"))
						
						self.packsconf[nodename]["patchs"][patchname] = {
							"path" : rmpatchdir[len(self.syncconf["dataroot"]):],
							"format" : ZLIBFORMAT,
							"count" : filecount,
							"size" : totalsize
						}
						
						tools.write_json(self.packsconf[nodename]["patchs"][patchname], self.temppath + "/patch.config.json")
						upresult = self.reupload_file(self.temppath + "/patch.config.json",rmpatchtmp + "/config.json",True)
				
						self.ftp.rename(rmpatchtmp,rmpatchdir)
					else:
						downresult = self.redownload_file(rmpatchdir + "/config.json",self.temppath + "/patch.config.json")
						if not downresult:
							raise Exception("read fail : " + rmpatchdir + "/config.json")
						self.packsconf[nodename]["patchs"][patchname] = tools.read_json(self.temppath + "/patch.config.json")
						
					self.writeLog("Sync Patch %s End\n" % patch)

			self.writeLog("Sync All Patch End\n")
		
if __name__=="__main__":
	try:
		ServerSynchro(tools.get_scriptconfig()).sync()
		print("服务器同步完成")
	except Exception as e:
		print(e)
	os.system("pause")
