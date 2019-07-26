# -*- coding: utf-8 -*-

import os,shutil,getopt,sys
from PIL import Image
from toolkits import tools

CURPATH = os.path.split(os.path.realpath(__file__))[0]

'''特效更新器'''
class EffectUpdater:
	def __init__(self,config,nodename = "main"):
		self.config = config
		self.nodename = nodename
		self.nodepath = CURPATH + "/" + config["path"]["game"] + "/" + nodename
		if not os.path.isdir(self.nodepath):
			raise Exception("无法识别的节点: " + nodename + " !!!")
			
		self.configpath = self.nodepath + "/origins/effects"
		self.srcimages = CURPATH + "/" + config["path"]["origins"] + "/effects"
		self.destimages = self.nodepath + "/res/" + nodename + "/graphics/effects"
		self.desteffects = self.nodepath + "/res/" + nodename + "/effects"
	
	def update(self):
		if os.path.isdir(self.configpath):
			if not os.path.isdir(self.destimages):
				os.makedirs(self.destimages)
			if not os.path.isdir(self.desteffects):
				os.makedirs(self.desteffects)
			
			for config in [ x for x in os.listdir(self.configpath) if x.endswith(".json")]:
				self.updateConfig(self.configpath + "/" + config)
		
			# 打包所有特效
			for eftdir in [x for x in os.listdir(self.destimages) if os.path.isdir(self.destimages + "/" + x)]:
				tools.pack_texture(
					self.nodepath + "/res/" + self.nodename + "/graphics/plists/effects/" + eftdir + ".png",
					self.nodepath + "/res/" + self.nodename + "/graphics/plists/effects/" + eftdir + ".plist",
					eftdir + "/",
					self.nodename + "/effects/" + eftdir + "/",
					self.destimages + "/" + eftdir
				)
				
	def updateConfig(self,configfile):
		# 遍历所有配置
		efsconf = tools.read_json(configfile)
		for efconf in efsconf["effects"]:
			self.gen_effect(efconf)
		
	def gen_effect(self,efconf):
		effectimg = Image.open(self.srcimages + "/" + efconf["color"] + ".png")
		framesdir = self.destimages + "/" + efconf["name"]
		if os.path.isdir(framesdir):
			shutil.rmtree(framesdir)
		os.makedirs(framesdir)	
		
		efcnf = {
			"name":efconf["name"],
			"meta":efconf["meta"],
			"params":efconf["params"],
			"source":{
				"plist":"$(respath)/" + self.nodename + "/graphics/plists/effects/" + efconf["name"] + ".plist",
				"image":"$(respath)/" + self.nodename + "/graphics/plists/effects/" + efconf["name"] + ".png",
				"fpath": self.nodename + "/effects/" + efconf["name"] + "/"
			},
			"frames":[]
		}
		
		#遍历所有帧
		for (fname,frect) in efconf["frames"].items():
			efcnf["frames"].append(fname)
			fimg = effectimg.crop((frect[0],frect[1],frect[0]+frect[2],frect[1]+frect[3]))
			fimg.save(self.destimages + "/" + efconf["name"] + "/%s.png" % fname)
			
		# 保存配置
		tools.write_json(efcnf,self.desteffects + "/" + efconf["name"] + ".json",self.config["debug"])
		print("更新特效:" + efconf["name"])
	
def updateEffects():
	config = tools.get_scriptconfig()
	dopacks = config['update']['dopacks']
	
	# 更新节点
	def updateNode(nodename):
		print(">>>>>>>>>>>>>>>>>>>[%s]特效>>>>>>>>>>>>>>>>>>>" % nodename)
		try:
			EffectUpdater(config,nodename).update()
			print("<<<<<<<<<<<<<<<<<<<更新完成<<<<<<<<<<<<<<<<<<<\n")
		except Exception as e:
			print(e)
			print("<<<<<<<<<<<<<<<<<<<更新失败!!!<<<<<<<<<<<<<<<<<<<\n")
	
	# 遍历所有包
	for nodename in os.listdir(CURPATH + "/" + config["path"]["game"]):
		if os.path.isdir(CURPATH + "/" + config["path"]["game"] + "/" + nodename) and tools.wildcard_matchs(dopacks,nodename):
			updateNode(nodename)
	
if __name__ == "__main__":
	updateEffects()
	os.system("pause")