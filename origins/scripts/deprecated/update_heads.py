# -*- coding: utf-8 -*-

import os,tools,shutil
from PIL import Image

'''头像更新器'''
class HeadUpdater:
	def __init__(self):
		self.curpath = os.path.split(os.path.realpath(__file__))[0]
		self.basepath = self.curpath + "/.."
		self.headfile = self.basepath + "/configs/heads.json"
	
	def update(self):
		if not os.path.exists(self.headfile):
			print("头像配置文件:" + self.headfile + "不存在!")
			return
		self.headconf = tools.read_json(self.headfile)
		self.mdsdir,_ = os.path.split(self.headfile)
		self.source = self.mdsdir + "/" + self.headconf["source"]
		self.dest = self.mdsdir + "/" + self.headconf["dest"]
		if not os.path.exists(self.dest):
			os.makedirs(self.dest)
		
		# 遍历所有头像配置
		for headc in self.headconf["heads"]:
			if headc["flipX"]:
				srcimg = Image.open(self.source + "/" + headc["image"])
				srcimg = srcimg.transpose(Image.FLIP_LEFT_RIGHT)
				srcimg.save(self.dest + "/" + headc["head"])
			else:
				shutil.copyfile(self.source + "/" + headc["image"],self.dest + "/" + headc["head"])
		
if __name__ == "__main__":
	'''
	try:
		HeadUpdater().update()
		print("头像生成完成")
	except Exception:
		print("异常发生!!!")
	'''
		
	HeadUpdater().update()
	
	os.system("pause")
	