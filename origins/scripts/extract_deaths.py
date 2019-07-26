# -*- coding: utf-8 -*-

import sys,getopt,os
from PIL import Image

'''死亡图片提取器'''
class DeathExtractor:
	# 输入单元高度
	iheight = 8
	
	# 块大小
	blocksize = (24,16)
	
	# 输出大小
	outsize = (6,20)
	
	# 输出图像大小
	oimgsize = (blocksize[0] * outsize[0],blocksize[1] * outsize[1])
	
	'''初始化'''
	def __init__(self,ifile,ofile):
		if ofile == None:
			dir,file = os.path.split(ifile)
			fname,fext = os.path.splitext(file)
			ofile = dir + "/" + fname + "_deaths" + fext
		self.iimg = Image.open(ifile)
		self.isize = self.iimg.size
		self.ipos = [0,0]
		self.oimg = Image.new(self.iimg.mode,self.oimgsize)
		self.opos = [0,0]
		self.ofile = ofile
		self.remove_blackbg()
	
	'''移除黑色背景'''
	def remove_blackbg(self):
		self.iimg = self.iimg.convert(mode="RGBA")
		for y in range(self.isize[1]):
			for x in range(self.isize[0]):
				p = self.iimg.getpixel((x,y))
				if p[0] == 0 and p[1] == 0 and p[2] == 0:
					self.iimg.putpixel((x,y),(0,0,0,0))
		
	'''提取操作'''
	def do_extract(self):
		self.extract_16_24(1,"h")
		self.extract_8_24(1,"m")
		self.extract_16_24(3,"t")
		self.extract_8_24(1,"m")
		self.extract_16_24(1,"h")
		self.extract_16_24(1,"t")
		self.extract_8_24(1,"m")
		self.extract_16_24(5,"t")
		self.extract_24(1)
		self.extract_16_24(8,"t")
		self.extract_24(1)
		self.extract_8_24(1,"t")
		self.extract_16_24(1,"t")
		self.extract_8_24(1,"m")
		self.extract_16_24(2,"t")
		self.extract_8_24(2,"m")
		self.extract_16_24(2,"t")
		self.extract_16_24(1,"h")
		self.extract_16_24(1,"t")
		self.extract_8_24(1,"m")
		self.extract_16_24(1,"h")
		self.extract_16_24(1,"t")
		self.extract_8_24(1,"m")
		self.extract_16_24(1,"t")
		self.extract_16_24(1,"h")
		self.extract_16_24(1,"t")
		self.extract_16_24(2,"h")
		self.extract_16_24(6,"t")
		self.extract_24(1)
		self.skip_line()
		self.extract_8_24(1,"m")
		self.extract_16_24(5,"t")
		self.extract_24_24(1)
		self.extract_8_24(2,"m")
		self.extract_16_24(2,"t")
		self.skip_width(16)
		self.extract_8_24(1,"m")
		self.extract_16_24(2,"t")
		self.extract_24_24(1)
		self.extract_16_24(1,"t")
		self.extract_24_24(1)
		self.extract_16_24(1,"t")
		self.extract_24_24(3)
		self.extract_16_24(1,"t")
		self.extract_24_24(1)
		self.extract_24(1)
		self.extract_16_24(2,"t")
		self.extract_24_24(1)
		self.extract_16_24(4,"t")
		self.extract_24_24(1)
		self.extract_16_24(1,"t")
		self.extract_24_24(1)
		self.extract_16_24(3,"t")
		self.skip_line()
		self.extract_16_24(3,"t")
		self.extract_24_24(1)
		self.extract_16_24(2,"t")
		self.extract_24_24(1)
		self.extract_16_24(1,"t")
		self.extract_24_24(1)
		self.extract_16_24(2,"t")
		
		
		self.oimg.save(self.ofile)
		
	'''获得指定宽度的图片'''
	def get_image(self,width):
		if self.ipos[0] == self.isize[0]:
			self.ipos[0] = 0
			self.ipos[1] += self.iheight
		img = self.iimg.crop((self.ipos[0],self.ipos[1],self.ipos[0] + width,self.ipos[1] + self.iheight))
		self.ipos[0] += width
		return img
	
	'''跳过当前的行'''
	def skip_line(self):
		self.ipos[0] = 0
		self.ipos[1] += self.iheight
	
	'''跳过指定宽度'''
	def skip_width(self,width):
		if self.ipos[0] == self.isize[0]:
			self.ipos[0] = 0
			self.ipos[1] += self.iheight
		self.ipos[0] += width
	
	'''提取24_24'''
	def extract_24_24(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(24),(self.opos[0],self.opos[1],self.opos[0] + 24,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0],self.opos[1] + self.iheight,self.opos[0] + 24,self.opos[1]+ 2*self.iheight))
			self.opos[0] += self.blocksize[0]
			
	'''提取16_24'''
	def extract_16_24(self,count,pos):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			if pos == "h":
				self.oimg.paste(self.get_image(16),(self.opos[0],self.opos[1],self.opos[0] + 16,self.opos[1] + self.iheight))
			elif pos == "t":
				self.oimg.paste(self.get_image(16),(self.opos[0]+8,self.opos[1],self.opos[0] + 24,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0],self.opos[1] + self.iheight,self.opos[0] + 24,self.opos[1]+ 2*self.iheight))
			self.opos[0] += self.blocksize[0]
		
	'''提取24'''
	def extract_24(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(24),(self.opos[0],self.opos[1] + self.iheight,self.opos[0] + 24,self.opos[1]+ 2*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	'''提取8_24'''
	def extract_8_24(self,count,pos):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			if pos == "h":
				self.oimg.paste(self.get_image(8),(self.opos[0],self.opos[1],self.opos[0] + 8,self.opos[1] + self.iheight))
			elif pos == "m":
				self.oimg.paste(self.get_image(8),(self.opos[0]+8,self.opos[1],self.opos[0] + 16,self.opos[1] + self.iheight))
			elif pos == "t":
				self.oimg.paste(self.get_image(8),(self.opos[0]+16,self.opos[1],self.opos[0] + 24,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0],self.opos[1] + self.iheight,self.opos[0] + 24,self.opos[1]+ 2*self.iheight))
			self.opos[0] += self.blocksize[0]
	
if __name__ == "__main__":
	ifile = None
	ofile = None
	try:
		opts,args = getopt.getopt(sys.argv[1:],"i:d:",["ifile=","ofile="])
	except getopt.GetoptError:
		print("命令行参数格式错误!")
		sys.exit(2)
	
	for opt,arg in opts:
		if opt in ("-i","--ifile"):
			ifile = arg
		elif opt in ("-d","--ofile"):
			ofile = arg
	if ifile == None and len(args) > 0:
		ifile = args[0]
	
	if ifile != None:
		DeathExtractor(ifile,ofile).do_extract()
	else:
		basepath = os.path.split(os.path.realpath(__file__))[0] + "/.."
		sourcepath = basepath + "/origins/deaths"
		destpath = basepath + "/deaths"
		for file in os.listdir(sourcepath):
			DeathExtractor(sourcepath + "/" + file,destpath + "/" + file).do_extract()
			print("提取死亡模型文件:" + file)
		os.system("pause")
