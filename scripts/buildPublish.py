# -*- coding: utf-8 -*-

import os,sys,cryptoConfig,shutil
from toolkits import tools

CURPATH = os.path.split(os.path.realpath(__file__))[0]
LOCALCONFIG = "localconfig.json"

# 构建发布
def build():
	config = tools.get_scriptconfig()
	configdir = CURPATH + "/publish/config"
	tempdir = CURPATH + "/temp"
	compackdir = CURPATH + "/" + config["path"]["packs"] + "/installed/completes"
	pubpackdir = CURPATH + "/" + config["path"]["packs"] + "/publish"
	if not os.path.exists(compackdir):
		raise Exception("未找到安装游戏资源:" + compackdir)
	if os.path.exists(pubpackdir):
		shutil.rmtree(pubpackdir)
	os.makedirs(pubpackdir)
	if not os.path.exists(configdir):
		os.makedirs(configdir)
	if not os.path.exists(tempdir):
		os.makedirs(tempdir)
	
	playpacks = []
	
	# 搜索剧本依赖与所属包
	localconfig = config["publish"]["localconfig"]
	localplays = {}
	localconfig["plays"] = localplays
	allplays = tools.read_json(CURPATH + "/" + config["path"]["game"] + "/plays.json")
	def addplay(pname):
		if pname in allplays:
			play = allplays[pname]
			pack = play["pack"]
			if pname not in localplays:
				localplays[pname] = play
			if pack not in playpacks:
				playpacks.append(pack)
			if "prefix" in play:
				addplay(play["prefix"])
	for pname in config["publish"]["preplays"]:
		addplay(pname)
	tools.write_json(localconfig,tempdir + "/" + LOCALCONFIG,True)
	cryptoConfig.do_crypto("E",tempdir + "/" + LOCALCONFIG,configdir + "/" + LOCALCONFIG)
	
	# 生成pack目录
	allpacks = config["publish"]["basepacks"] + playpacks
	for pack in allpacks:
		shutil.copyfile(compackdir + "/" + pack + ".pack", pubpackdir + "/" + pack + ".pack")
	
if __name__ == "__main__":
	try:
		build()
		print("构建发布完成")
	except Exception as e:
		print(e)
	os.system("pause")
