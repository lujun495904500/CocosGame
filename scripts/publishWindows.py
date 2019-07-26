# -*- coding: utf-8 -*-

import os,sys,shutil,re,subprocess,zipfile,time,buildPublish
import winreg
from toolkits import tools

CURPATH = os.path.split(os.path.realpath(__file__))[0]

# Windows发布器
class WindowsPublisher:
	def __init__(self,config,options = {}):
		self.config = config
		self.options = options
		self.winprojpath = CURPATH + "/" + config["path"]["project"] + "/proj.win32"
		self.publishpath = CURPATH + "/" + config["path"]["publish"]
		self.winpubpath = self.publishpath + "/windows"
		self.binbuilddir = CURPATH + "/temp/winbuild"
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
			
	def publish(self):
		if not os.path.exists(self.winprojpath):
			raise Exception("windows project %s not found !" % self.winprojpath)
		self.projfile,self.projname,self.projvers = self.get_project_info(self.winprojpath)
		if self.projfile == None or self.projname == None:
			raise Exception("visual studio project *.sln can't detected !")
		if self.projvers == None:
			raise Exception("visual studio version can't detected !")
		self.buildtool = self.get_msbuild_path(self.projvers)
		if self.buildtool == None:
			raise Exception("build tool VS[%s] can't detected !" % self.projvers)
		if not os.path.exists(self.winpubpath):
			os.makedirs(self.winpubpath)
		if os.path.isdir(self.binbuilddir):
			shutil.rmtree(self.binbuilddir)
		buildPublish.build()
		
		self.logfile = open(self.publishpath + "/windows_logs.txt","w")
		
		self.writeLog("---------------------------------PUBLISH--------------------------------\n")
		self.writeLog("Project Name : %s\n" % self.projname)
		self.writeLog("Visual Studio Version : %s\n" % self.projvers)
		self.buildmode = "Debug" if self.config["publish"]["debug"] else "Release"
		self.writeLog("Build Mode : %s\n" % self.buildmode)
		self.writeLog("Build Tool : %s\n\n" % self.buildtool)
		
		self.writeLog("Build Begin ......\n")
		job_number = 2
		self.writeLog("Job Number Max : %d\n" % job_number)
		commands = [
			self.buildtool,
			self.projfile,
			'/t:%s' % self.projname,
			'/p:Configuration=%s' % self.buildmode,
			'/p:Platform=%s' % "Win32",
			'/p:LocalDebuggerWorkingDirectory=%s' % self.binbuilddir,
            '/m:%s' % job_number
		]
		self.writeLog("commands : %s\n" % " ".join(commands))
		subprocess.call(commands)
		self.writeLog("Build End\n\n")
		
		# 创建压缩包
		if "gamename" in self.config["publish"]:
			gamename = self.config["publish"]["gamename"]
		else:
			gamename = self.projname
		gamezipfile = gamename + "_" +time.strftime("%Y%m%d%H%M%S", time.localtime()) + ".zip"
		gamezippath = self.winpubpath + "/" + gamezipfile
		gamezip = zipfile.ZipFile(gamezippath, 'w', zipfile.ZIP_DEFLATED)
		
		# 压缩bin目录
		zippath = gamename + "/bin"
		for filename in os.listdir(self.binbuilddir):
			name, ext = os.path.splitext(filename)
			if ext == ".exe" or ext == ".dll":
				gamezip.write(self.binbuilddir + "/" + filename,zippath + "/" + filename)
				
		
		# 写入boot资源包
		gamezip.write(CURPATH + "/" + self.config["path"]["packs"] + "/installed/completes/boot.pack", gamename + "/boot.pack")
		
		# 写入发布资源包
		zippath = gamename + "/packs"
		instedres = CURPATH + "/" + self.config["path"]["packs"] + "/publish"
		for filename in os.listdir(instedres):
			name, ext = os.path.splitext(filename)
			if ext == ".pack":
				gamezip.write(instedres + "/" + filename,zippath + "/" + filename)
				
		# 写入配置文件
		gamezip.write(CURPATH + "/publish/config/localconfig.json",gamename + "/localconfig.json")
		
		# 写入运行脚本
		gamezip.writestr(gamename + "/运行游戏.bat", 'start bin/%s.exe -resolution 852x480 -workdir "%%cd%%"' % self.projname)
		
		# 写入额外文件
		self.zip_write_path(gamezip,CURPATH + "/publish/windows",gamename)
		gamezip.close()
		
		self.writeLog("Build Zip File : %s\n" % gamezippath)
		self.writeLog("Publish Success\n")
		self.writeLog("------------------------------------------------------------------------\n\n")
		
	def zip_write_path(self,zip,writepath,destpath):
		for filename in os.listdir(writepath):
			filepath = writepath + "/" + filename
			if os.path.isfile(filepath):
				zip.write(filepath,destpath + "/" + filename)
			else:
				self.zip_write_path(zip,filepath,destpath + "/" + filename)
		
	def get_project_info(self,winprojpath):
		projfile = None
		projname = None
		projvers = None
		
		for filename in os.listdir(winprojpath):
			name, ext = os.path.splitext(filename)
			if ext.lower() == ".sln":
				projfile = winprojpath + "/" + filename
				projname = name
				break
				
		if projfile != None:
			with open(projfile,"r",encoding='utf-8') as f:
				for line in f.readlines():
					match = re.match("[ \t]*VisualStudioVersion[ \t]*=[ \t]*([0-9.]+)", line)
					if match:
						projvers = match.group(1).split(".")[0] + ".0"
						break
						
		return (projfile,projname,projvers)
		
	def is_32bit_windows(self):
		if sys.platform != 'win32':
			return False
		arch = os.environ['PROCESSOR_ARCHITECTURE'].lower()
		archw = "PROCESSOR_ARCHITEW6432" in os.environ
		return (arch == "x86" and not archw)
		
	def get_msbuild_path(self,vs_ver):
		if self.is_32bit_windows():
			reg_flag_list = [ winreg.KEY_WOW64_32KEY ]
		else:
			reg_flag_list = [ winreg.KEY_WOW64_64KEY, winreg.KEY_WOW64_32KEY ]
			
		# Find VS path
		msbuild_path = None
		for reg_flag in reg_flag_list:
			try:
				vs = winreg.OpenKey(
					winreg.HKEY_LOCAL_MACHINE,
					r"SOFTWARE\Microsoft\MSBuild\ToolsVersions\%s" % vs_ver,
					0,
					winreg.KEY_READ | reg_flag
				)
				msbuild_path, type = winreg.QueryValueEx(vs, 'MSBuildToolsPath')
			except:
				continue

			if msbuild_path is not None:
				msbuild_path = os.path.join(msbuild_path, "MSBuild.exe")
				if os.path.exists(msbuild_path):
					break
				else:
					msbuild_path = None

		return msbuild_path
			
if __name__ == "__main__":
	try:
		WindowsPublisher(tools.get_scriptconfig()).publish()
		print("Windows版本发布完成")
	except Exception as e:
		print(e)
	os.system("pause")
	