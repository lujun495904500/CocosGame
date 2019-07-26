# -*- coding: utf-8 -*-

import os,getopt,sys
from PIL import Image
from toolkits import tools

CURPATH = os.path.split(os.path.realpath(__file__))[0]

'''模型更新器'''
class ModelUpdater:
	def __init__(self,config,nodename = "main"):
		self.config = config
		self.nodename = nodename
		self.nodepath = CURPATH + "/" + config["path"]["game"] + "/" + nodename
		if not os.path.isdir(self.nodepath):
			raise Exception("无法识别的节点: " + nodename + " !!!")
		self.configpath = self.nodepath + "/origins/models"
		self.srcwalk = CURPATH + "/" + config["path"]["origins"] + "/walks"
		self.srcdeath = CURPATH + "/" + config["path"]["origins"] + "/deaths"
		self.srcattack = CURPATH + "/" + config["path"]["origins"] + "/attacks"
		self.destimages = self.nodepath + "/res/" + nodename + "/graphics/models"
		self.destmodels = self.nodepath + "/res/" + nodename + "/models"
		
	def update(self):
		if os.path.isdir(self.configpath):
			if not os.path.isdir(self.destimages):
				os.makedirs(self.destimages)
			if not os.path.isdir(self.destmodels):
				os.makedirs(self.destmodels)
				
			# 读取基础配置信息
			config = tools.read_config(self.srcwalk + "/config.ini")
			self.walksize = (config["info"].getint("blockwidth"),config["info"].getint("blockheight"))
			config = tools.read_config(self.srcdeath + "/config.ini")
			self.deathbsize = (config["info"].getint("basewidth"),config["info"].getint("baseheight"))
			config = tools.read_config(self.srcattack + "/config.ini")
			self.attackbsize = (config["info"].getint("basewidth"),config["info"].getint("baseheight"))
			
			for config in [ x for x in os.listdir(self.configpath) if x.endswith(".json")]:
				self.updateConfig(self.configpath + "/" + config)
		
			# 打包所有模型
			for modeldir in [x for x in os.listdir(self.destimages) if os.path.isdir(self.destimages + "/" + x)]:
				tools.pack_texture(
					self.nodepath + "/res/" + self.nodename + "/graphics/plists/models/" + modeldir + ".png",
					self.nodepath + "/res/" + self.nodename + "/graphics/plists/models/" + modeldir + ".plist",
					modeldir + "/",
					self.nodename + "/models/" + modeldir + "/",
					self.destimages + "/" + modeldir
				)
		
	def updateConfig(self,configfile):
		# 遍历所有模型配置
		mdsconf = tools.read_json(configfile)
		for mdconf in mdsconf["models"]:
			self.gen_model(mdconf)
				
	def move_image(self,img,offest):
		lb = [-offest[0],offest[1]]
		rt = [img.size[0]-offest[0],img.size[1]+offest[1]]
		dp = [offest[0],-offest[1]]
		
		if lb[0] < 0:
			lb[0] = 0
		elif lb[0] > img.size[0]:
			lb[0] = img.size[0]
		if rt[0] < 0:
			rt[0] = 0
		elif rt[0] > img.size[0]:
			rt[0] = img.size[0]
		if lb[1] < 0:
			lb[1] = 0
		elif lb[1] > img.size[1]:
			lb[1] = img.size[1]
		if rt[1] < 0:
			rt[1] = 0
		elif rt[1] > img.size[1]:
			rt[1] = img.size[1]
		if dp[0] < 0:
			dp[0] = 0
		elif dp[0] > img.size[0]:
			dp[0] = img.size[0] 
		if dp[1] < 0:
			dp[1] = 0
		elif dp[1] > img.size[1]:
			dp[1] = img.size[1]
			
		newimg = Image.new("RGBA",img.size)
		cropimg = img.crop((lb[0],lb[1],rt[0],rt[1]))
		newimg.paste(cropimg,(dp[0],dp[1]))
		
		return newimg
	
	def save_image(self,imgdir,imgname,img):
		if not os.path.isdir(imgdir):
			os.makedirs(imgdir)
		img.save(imgdir + "/" +imgname)
	
	def gen_model(self,mdconf):
		walkimg = Image.open(self.srcwalk + "/" + mdconf["color"] + ".png")
		deathimg = Image.open(self.srcdeath + "/" + mdconf["color"] + ".png")
		attackimg = Image.open(self.srcattack + "/" + mdconf["color"] + ".png")
		
		mdcnffile = self.destmodels + "/" + mdconf["name"] + ".json"
		mdcnf = {
			"name":mdconf["name"],
			"meta":mdconf["meta"],
			"modelsize":mdconf["modelsize"],
			"anchor":mdconf["anchor"],
			"params":mdconf["params"],
			"source":{
				"plist":"$(respath)/" + self.nodename + "/graphics/plists/models/" + mdconf["name"] + ".plist",
				"image":"$(respath)/" + self.nodename + "/graphics/plists/models/" + mdconf["name"] + ".png",
				"fpath": self.nodename + "/models/" + mdconf["name"] + "/"
			},
			"frames":[]
		}
		
		# 步行图
		if "walk" in mdconf:
			for wtype,witem in mdconf["walk"].items():
				windexs = witem["index"]
				if "flip" in witem:
					wflips = witem["flip"]
				else:
					wflips = []
				if "offest" in witem:
					woffests = witem["offest"]
				else:
					woffests = []
				for i in range(0,len(windexs)):
					windex = windexs[i]
					indeximg = walkimg.crop((self.walksize[0]*(windex[0]-1),self.walksize[1]*(windex[1]-1),
						self.walksize[0]*(windex[0]),self.walksize[1]*(windex[1])))
					if i < len(wflips):
						if wflips[i][0]:
							indeximg = indeximg.transpose(Image.FLIP_LEFT_RIGHT)
						if wflips[i][1]:
							indeximg = indeximg.transpose(Image.FLIP_TOP_BOTTOM)
					if i < len(woffests):
						indeximg = self.move_image(indeximg,woffests[i])
					self.save_image(self.destimages + "/" + mdconf["name"], "walk_" + wtype + str(i+1) + ".png", indeximg)
					mdcnf["frames"].append("walk_" + wtype + str(i+1))
		
		# 死亡图
		if "death" in mdconf:
			deathcnf = mdconf["death"]
			dindexs = deathcnf["index"]
			if "flip" in deathcnf:
				dflips = deathcnf["flip"]
			else:
				dflips = []
			if "offest" in deathcnf:
				doffests = deathcnf["offest"]
			else:
				doffests = []
			for i in range(0,len(dindexs)):
				dindex = dindexs[i]
				indeximg = deathimg.crop((self.deathbsize[0]*(dindex[0]-1),self.deathbsize[1]*(dindex[1]-1),
					self.deathbsize[0]*(dindex[0]),self.deathbsize[1]*(dindex[1])))
				indeximg = indeximg.transpose(Image.FLIP_LEFT_RIGHT)
				if i < len(dflips):
					if dflips[i][0]:
						indeximg = indeximg.transpose(Image.FLIP_LEFT_RIGHT)
					if dflips[i][1]:
						indeximg = indeximg.transpose(Image.FLIP_TOP_BOTTOM)
				if i < len(doffests):
					indeximg = self.move_image(indeximg,doffests[i])
				self.save_image(self.destimages + "/" + mdconf["name"], "death" + str(i+1) + ".png", indeximg)
				mdcnf["frames"].append("death" + str(i+1))
			
		# 攻击图	
		if "attack" in mdconf:
			attackcnf = mdconf["attack"]
			atkseg = attackcnf["segment"]
			aindex = attackcnf["index"]
			if "flip" in attackcnf:
				aflips = attackcnf["flip"]
			else:
				aflips = []
			if "offest" in attackcnf:
				aoffests = attackcnf["offest"]
			else:
				aoffests = []
			atkimg = attackimg.crop((self.attackbsize[0]*(aindex[0]-1),self.attackbsize[1]*(aindex[1]-1),
				self.attackbsize[0]*(aindex[0]),self.attackbsize[1]*(aindex[1])))
			segsize = (atkimg.size[0]/atkseg,atkimg.size[1])
			for i in range(atkseg):
				indeximg = atkimg.crop((i*segsize[0],0,(i+1)*segsize[0],segsize[1]))
				indeximg = indeximg.transpose(Image.FLIP_LEFT_RIGHT)
				if i < len(aflips):
					if aflips[i][0]:
						indeximg = indeximg.transpose(Image.FLIP_LEFT_RIGHT)
					if aflips[i][1]:
						indeximg = indeximg.transpose(Image.FLIP_TOP_BOTTOM)
				if i < len(aoffests):
					indeximg = self.move_image(indeximg,aoffests[i])
				self.save_image(self.destimages + "/" + mdconf["name"], "attack" + str(i+1) + ".png", indeximg)
				mdcnf["frames"].append("attack" + str(i+1))
				
		attackimg.close()
		deathimg.close()
		walkimg.close()
		
		# 保存配置
		tools.write_json(mdcnf,mdcnffile,self.config["debug"])
		print("更新模型:" + mdconf["name"])
	
def updateModels():
	config = tools.get_scriptconfig()
	dopacks = config['update']['dopacks']
	
	# 更新节点
	def updateNode(nodename):
		print(">>>>>>>>>>>>>>>>>>>[%s]模型>>>>>>>>>>>>>>>>>>>" % nodename)
		try:
			ModelUpdater(config,nodename).update()
			print("<<<<<<<<<<<<<<<<<<<更新完成<<<<<<<<<<<<<<<<<<<\n")
		except Exception as e:
			print(e)
			print("<<<<<<<<<<<<<<<<<<<更新失败!!!<<<<<<<<<<<<<<<<<<<\n")
	
	# 遍历所有包
	for nodename in os.listdir(CURPATH + "/" + config["path"]["game"]):
		if os.path.isdir(CURPATH + "/" + config["path"]["game"] + "/" + nodename) and tools.wildcard_matchs(dopacks,nodename):
			updateNode(nodename)
	
if __name__ == "__main__":
	updateModels()
	os.system("pause")
	