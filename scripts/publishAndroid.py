# -*- coding: utf-8 -*-

import os,sys,shutil,subprocess,re,math,buildPublish
from toolkits import tools

CURPATH = os.path.split(os.path.realpath(__file__))[0]

# APK 根版本号
APKROOTVERSION	= 1000000

# 安卓发布器
class AndroidPublisher:
	def __init__(self,config,options = {}):
		self.config = config
		self.options = options
		self.andprojpath = CURPATH + "/" + config["path"]["project"] + "/proj.android"
		self.publishpath = CURPATH + "/" + config["path"]["publish"]
		self.andpubpath = self.publishpath + "/android"
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
		if not os.path.exists(self.andprojpath):
			raise Exception("android project %s not found !" % self.andprojpath)
		self.projectname = self.get_project_name()
		if self.projectname == None:
			raise Exception("android project name not detected !")
		if not os.path.exists(self.andpubpath):
			os.makedirs(self.andpubpath)
		buildPublish.build()
			
		pubconffile = self.publishpath + "/config.json"
		if not os.path.isfile(pubconffile):
			tools.write_json({},pubconffile,True)
		self.publishconf = tools.read_json(pubconffile)
		if "android" not in self.publishconf:
			self.publishconf["android"] = {}
		self.andpubconf = self.publishconf["android"]
		
		self.logfile = open(self.publishpath + "/android_logs.txt","w")
		
		if "verscode" in self.andpubconf:
			self.buildvers = self.andpubconf["verscode"]
			if "addversion" in self.options:
				addversion = self.options["addversion"]
			else:
				addversion = 1
			addvers = int(math.pow(1000,addversion-1))
			self.buildvers -= self.buildvers % addvers
			self.buildvers += addvers
		else:
			self.buildvers = APKROOTVERSION
		
		self.writeLog("---------------------------------PUBLISH--------------------------------\n")
		self.writeLog("Project Name : %s\n" % self.projectname)
		self.writeLog("Build Version : %s\n" % tools.getVersionName(self.buildvers))
		
		self.buildmode = "debug" if self.config["publish"]["debug"] else "release"
		self.writeLog("Build Mode : %s\n\n" % self.buildmode)
		
		if "gamename" in self.config["publish"]:
			pubapkname = self.config["publish"]["gamename"]
		else:
			pubapkname = self.projectname
		pubapkname += "_" + tools.getVersionName(self.buildvers) + ("_debug" if self.buildmode == "debug" else "") + ".apk"
		pubapkpath = self.andpubpath + "/" + pubapkname
		if os.path.exists(pubapkpath):
			os.remove(pubapkpath)
		
		self.writeLog("Gradle Build Begin ......\n")
		buildapkpath = self.gradle_build_apk()
		self.writeLog("Gradle Build End\n\n")
		
		if os.path.isfile(buildapkpath):
			shutil.copyfile(buildapkpath, pubapkpath)
			
			self.andpubconf["verscode"] = self.buildvers
			tools.write_json(self.publishconf,pubconffile,True)
			
			self.writeLog("Build APK File : %s\n" % pubapkpath)
			self.writeLog("Publish Success\n")
		else:
			self.writeLog("Publish Failure : build apk %s not found !!!\n" % buildapkpath)
		
		self.writeLog("------------------------------------------------------------------------\n\n")
		
	def get_project_name(self):
		setting_file = os.path.join(self.andprojpath, 'settings.gradle')
		if os.path.isfile(setting_file):
			# get project name from settings.gradle
			f = open(setting_file)
			lines = f.readlines()
			f.close()

			pattern = r"project\(':(.*)'\)\.projectDir[ \t]*=[ \t]*new[ \t]*File\(settingsDir, 'app'\)"
			for line in lines:
				line_str = line.strip()
				match = re.match(pattern, line_str)
				if match:
					return match.group(1)
		return None
		
	def gradle_build_apk(self):
		buildapkname = '%s-%s.apk' % (self.projectname, self.buildmode)
		buildapkpath = os.path.join(self.andprojpath, 'app/build/outputs/apk', self.buildmode, buildapkname)
		if os.path.exists(buildapkpath):
			os.remove(buildapkpath)
			
		commands = []
		commands.append('gradlew.bat' if sys.platform == 'win32' else 'gradlew')
		commands.append('--parallel')
		commands.append('--info')
		commands.append('assemble%s' % ('Debug' if self.buildmode == 'debug' else 'Release'))
		
		commands.append('-P%s=%d' % ("PROP_GAME_VERSIONCODE",self.buildvers))
		commands.append('-P%s=%s' % ("PROP_GAME_VERSIONNAME",tools.getVersionName(self.buildvers)))
		if "packagename" in self.config["publish"]:
			commands.append('-P%s=%s' % ("PROP_GAME_PACKNAME",self.config["publish"]["packagename"]))
		
		self.writeLog("gradle commands : %s\n" % (" ".join(commands)))
		
		lastwd = os.getcwd()
		os.chdir(self.andprojpath)
		subprocess.call(commands)
		os.chdir(lastwd)
		
		return buildapkpath
		
if __name__ == "__main__":
	try:
		options = {}
		'''
			命令分割	,
			提升版本	[vers]+[1/2/3]		默认 1 (1 修订版本, 2 次本版, 3 主版本)
		'''
		pubcmdsstr = input("输入发布命令:").strip()
		if pubcmdsstr != "":
			pubcmdstr = pubcmdsstr.split(",")
			for pubcmd in pubcmdstr:
				if "+" in pubcmd:
					optstr = pubcmd.split("+")
					if len(optstr) == 2 and optstr[0].lower()=="vers":
						options["addversion"] = int(optstr[1].strip())
		
		AndroidPublisher(tools.get_scriptconfig(),options).publish()
		print("安卓版本发布完成")
	except Exception as e:
		print(e)
	os.system("pause")
	