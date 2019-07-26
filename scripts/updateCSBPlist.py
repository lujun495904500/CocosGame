# -*- coding: utf-8 -*-

import os,getopt,sys
from toolkits import tools

CURPATH = os.path.split(os.path.realpath(__file__))[0]

'''csb图集更新器'''
class CSBPlistUpdater:
	def __init__(self,config,nodename = "main"):
		self.config = config
		self.nodename = nodename
		self.nodepath = CURPATH + "/" + config["path"]["game"] + "/" + nodename
		if not os.path.isdir(self.nodepath):
			raise Exception("无法识别的节点: " + nodename + " !!!")
		self.srcimages = self.nodepath + "/res/" + nodename + "/graphics/cocosstudio"
		self.destplist = self.nodepath + "/res/" + nodename + "/cocosstudio"
		
	def update(self):
		if os.path.isdir(self.srcimages):
			if not os.path.isdir(self.destplist):
				os.makedirs(self.destplist)
			
			# 打包文理
			tools.pack_texture(
				self.destplist + "/" + "images.png",
				self.destplist + "/" + "images.plist",
				"cocosstudio/",
				self.nodename + "/images/",
				self.srcimages,
				True
			)
			
def updateCSBPlist():
	config = tools.get_scriptconfig()
	dopacks = config['update']['dopacks']
	
	# 更新节点
	def updateNode(nodename):
		print(">>>>>>>>>>>>>>>>>>>[%s]CSB plist>>>>>>>>>>>>>>>>>>>" % nodename)
		try:
			CSBPlistUpdater(config,nodename).update()
			print("<<<<<<<<<<<<<<<<<<<更新完成<<<<<<<<<<<<<<<<<<<\n")
		except Exception as e:
			print(e)
			print("<<<<<<<<<<<<<<<<<<<更新失败!!!<<<<<<<<<<<<<<<<<<<\n")
	
	# 遍历所有包
	for nodename in os.listdir(CURPATH + "/" + config["path"]["game"]):
		if os.path.isdir(CURPATH + "/" + config["path"]["game"] + "/" + nodename) and tools.wildcard_matchs(dopacks,nodename):
			updateNode(nodename)
			
if __name__ == "__main__":
	updateCSBPlist()
	os.system("pause")