# -*- coding: utf-8 -*-

import os,sys,shutil,HDiffPatch
from toolkits import tools

CURPATH = os.path.split(os.path.realpath(__file__))[0]

'''资源安装器'''
class ResourceInstaller:
	def __init__(self,config,options = {}):
		self.config = config
		self.options = options
		self.packspath = CURPATH + "/" + config["path"]["packs"]
		self.runpath = CURPATH + "/" + config["path"]["rundata"]
		self.runpacks = self.runpath + "/packs"
		self.temppath = CURPATH + "/temp"
		self.latestpath = self.packspath + "/latest"
		self.compspath = self.packspath + "/installed/completes"
		self.patchspath = self.packspath + "/installed/patchs"
		self.logfile = None
			
	def __del__(self):
		if self.logfile != None:
			self.logfile.close()
			self.logfile = None
	
	def writeLog(self,log):
		if self.logfile != None:
			self.logfile.write(log)
		if self.config["printlog"]:
			print(log,end='')
	
	def install(self):
		if os.path.isdir(self.latestpath):
			if not os.path.isdir(self.compspath):
				os.makedirs(self.compspath)
			if not os.path.isdir(self.patchspath):
				os.makedirs(self.patchspath)
			if not os.path.isdir(self.runpath):
				os.makedirs(self.runpath)
			if not os.path.isdir(self.runpacks):
				os.makedirs(self.runpacks)
			if not os.path.isdir(self.temppath):
				os.makedirs(self.temppath)
			self.logfile = open(self.packspath + "/install_logs.txt","w")
			
			for nodefile in os.listdir(self.latestpath):
				nodename,_ = os.path.splitext(nodefile)
				self.writeLog("---------------------------------INSTALL--------------------------------\n")
				self.installNode(nodename,self.latestpath + "/" + nodefile)
				self.writeLog("-----------------------------------END----------------------------------\n\n")
				
	def installNode(self,nodename,filepath):
		self.writeLog("Node Name : %s\n" % nodename)
		self.writeLog("Latest File : %s\n" % filepath)
		
		verscode = 0
		with open(filepath,"rb") as f:
			verscode = tools.getLongValue(f.read(4))
		
		self.writeLog("Latest Version : %s\n" % tools.getVersionName(verscode))
		
		_,filename = os.path.split(filepath)
		compfile = self.compspath + "/" + filename
		if os.path.isfile(compfile):
			oldvers = 0
			with open(compfile,"rb") as f:
				oldvers = tools.getLongValue(f.read(4))
				
			self.writeLog("Old Version : %s\n" % tools.getVersionName(oldvers))
			
			# 判断版本
			if oldvers >= verscode:
				self.writeLog("currently is the latest version pack file\n")
				return 
				
			# 判断md5
			if tools.file_md5(filepath,4) == tools.file_md5(compfile,4):
				self.writeLog("document unchanged cancel update\n")
				return 
		
		''' 需要更新版本 '''
		# 尝试生成补丁
		if os.path.isfile(compfile) and os.path.getsize(filepath) >= self.config["pack"]["patchsize"]:
			patchname = tools.getVersionName(oldvers) + "_" + tools.getVersionName(verscode) + ".patch"
			temppatch = self.temppath + "/" + patchname
			HDiffPatch.create_diff(filepath,compfile,temppatch)
			if os.path.getsize(temppatch) < os.path.getsize(filepath):
				npatchpath = self.patchspath + "/" + nodename
				if not os.path.isdir(npatchpath):
					os.makedirs(npatchpath)
				shutil.copyfile(temppatch,npatchpath + "/" + patchname)
				
				self.writeLog("Create Patch File : %s\n" % patchname)
		
		shutil.copyfile(filepath,compfile)
		
		if nodename.lower() == "boot":
			shutil.copyfile(filepath,self.runpath + "/" + filename)
		else:
			shutil.copyfile(filepath,self.runpacks + "/" + filename)
		
		self.writeLog("Update To Version : %s\n" % tools.getVersionName(verscode))
		
if __name__ == "__main__":
	try:
		ResourceInstaller(tools.get_scriptconfig()).install()
		print("资源安装完成")
	except Exception as e:
		print(e)
	os.system("pause")
