# -*- coding: utf-8 -*-

import sys,getopt,os
from PIL import Image

'''特效提取器'''
class EffectExtractor:
	
	# 块大小
	blocksize = (16,16)
	
	# 输出大小
	outsize = (10,14)
	
	# 输出图像大小
	oimgsize = (blocksize[0] * outsize[0],blocksize[1] * outsize[1])
	
	def __init__(self,ifile,ofile):
		if ofile == None:
			dir,file = os.path.split(ifile)
			fname,fext = os.path.splitext(file)
			ofile = dir + "/" + fname + "_effects" + fext
		self.iimg = Image.open(ifile)
		self.isize = self.iimg.size
		self.oimg = Image.new(self.iimg.mode,self.oimgsize)
		self.opos = [0,0]
		self.ofile = ofile
		self.remove_blackbg()
	
	def remove_blackbg(self):
		self.iimg = self.iimg.convert(mode="RGBA")
		for y in range(self.isize[1]):
			for x in range(self.isize[0]):
				p = self.iimg.getpixel((x,y))
				if p[0] == 0 and p[1] == 0 and p[2] == 0:
					self.iimg.putpixel((x,y),(0,0,0,0))
	
	def do_extract(self):
		self.extract_damage()
		self.extract_damage2()
		self.extract_fire1()
		self.extract_water1()
		self.extract_heal1()
		self.extract_fallwood()
		self.extract_fire2()
		self.extract_water2()
		self.extract_stone1()
		
		self.extract_revive()
		
		self.extract_unknown()
		
		self.oimg.save(self.ofile)
	
	def get_image(self,rect):
		return self.iimg.crop((rect[0],rect[1],rect[0]+rect[2],rect[1]+rect[3]))
		
	def set_image(self,img,pos):
		self.oimg.paste(img,(pos[0],pos[1],pos[0] + img.size[0],
			pos[1] + img.size[1]))
	
	def put_image(self,img):
		if self.opos[0] == self.oimgsize[0]:
			self.opos[0] = 0
			self.opos[1] += self.blocksize[1]
		self.oimg.paste(img,(self.opos[0],self.opos[1],self.opos[0] + self.blocksize[0],
			self.opos[1] + self.blocksize[1]))
		self.opos[0] += self.blocksize[0]
	
	def extract_damage(self):
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((168,8,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((296,8,16,8)),(0,8,16,16))
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((184,8,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((312,8,16,8)),(0,8,16,16))
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((200,8,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((328,8,16,8)),(0,8,16,16))
		self.put_image(tmpimg)
	
	def extract_damage2(self):
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((504,8,8,8)),(0,0,8,8))
		tmpimg.paste(self.get_image((504,8,8,8)),(0,8,8,16))
		tmpimg.paste(self.get_image((504,8,8,8)),(8,8,16,16))
		tmpimg.paste(self.get_image((424,8,8,8)),(8,0,16,8))
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((432,8,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((448,8,16,8)),(0,8,16,16))
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((216,8,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((232,8,16,8)),(0,8,16,16))
		self.put_image(tmpimg)
	
	def extract_fire1(self):
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((0,0,8,8)),(4,4,12,12))
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((16,0,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((144,0,16,8)),(0,8,16,16))
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((272,0,16,8)),(0,0,16,8))
		self.put_image(tmpimg)
	
	def extract_water1(self):
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((448,0,16,8)),(0,4,16,12))
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((464,0,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((80,8,16,8)),(0,8,16,16))
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((480,0,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((96,8,16,8)),(0,8,16,16))
		self.put_image(tmpimg)
	
	def extract_heal1(self):
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((408,8,16,8)).transpose(Image.FLIP_LEFT_RIGHT),(0,0,16,8))
		tmpimg.paste(self.get_image((280,8,16,8)).transpose(Image.FLIP_LEFT_RIGHT),(0,8,16,16))
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((152,8,16,8)).transpose(Image.FLIP_LEFT_RIGHT),(0,0,16,8))
		tmpimg.paste(self.get_image((232,0,8,8)).transpose(Image.FLIP_LEFT_RIGHT),(0,8,8,16))
		self.put_image(tmpimg)
	
	def extract_fallwood(self):
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((432,0,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((48,8,16,8)),(0,8,16,16))
		tmpimg = tmpimg.transpose(Image.FLIP_LEFT_RIGHT)
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((240,0,8,8)),(4,4,12,12))
		imgf1 = self.get_image((496,0,8,8))
		tmpimg.alpha_composite(imgf1,(0,0),(0,0))
		imgf2 = self.get_image((504,0,8,8))
		tmpimg.alpha_composite(imgf2,(8,8),(0,0))
		tmpimg = tmpimg.transpose(Image.FLIP_LEFT_RIGHT)
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		imgf1 = self.get_image((112,8,8,8))
		tmpimg.alpha_composite(imgf1,(0,2),(0,0))
		imgf2 = self.get_image((120,8,8,8))
		tmpimg.alpha_composite(imgf2,(8,6),(0,0))
		tmpimg = tmpimg.transpose(Image.FLIP_LEFT_RIGHT)
		self.put_image(tmpimg)
		
		tmpimg = self.get_image((400,0,24,8))
		tmpimg = tmpimg.transpose(Image.FLIP_LEFT_RIGHT)
		self.set_image(tmpimg,(0,13*self.blocksize[1]+8))
		tmpimg = self.get_image((16,8,24,8))
		tmpimg = tmpimg.transpose(Image.FLIP_LEFT_RIGHT)
		self.set_image(tmpimg,(24,13*self.blocksize[1]+8))
	
	def extract_fire2(self):
		self.set_image(self.get_image((8,0,8,8)),(8,11*self.blocksize[1]+8))
		self.set_image(self.get_image((128,0,16,8)),(0,12*self.blocksize[1]))
		self.set_image(self.get_image((256,0,16,8)),(0,12*self.blocksize[1]+8))
		
		self.set_image(self.get_image((32,0,16,8)),(self.blocksize[0],11*self.blocksize[1]+8))
		self.set_image(self.get_image((160,0,16,8)),(self.blocksize[0],12*self.blocksize[1]))
		self.set_image(self.get_image((288,0,16,8)),(self.blocksize[0],12*self.blocksize[1]+8))
	
		self.set_image(self.get_image((48,0,16,8)),(2*self.blocksize[0],11*self.blocksize[1]+8))
		self.set_image(self.get_image((176,0,16,8)),(2*self.blocksize[0],12*self.blocksize[1]))
		self.set_image(self.get_image((304,0,16,8)),(2*self.blocksize[0],12*self.blocksize[1]+8))
	
		self.set_image(self.get_image((64,0,16,8)),(3*self.blocksize[0],11*self.blocksize[1]+8))
		self.set_image(self.get_image((192,0,16,8)),(3*self.blocksize[0],12*self.blocksize[1]))
		self.set_image(self.get_image((320,0,16,8)),(3*self.blocksize[0],12*self.blocksize[1]+8))
	
		self.set_image(self.get_image((80,0,16,8)),(4*self.blocksize[0],11*self.blocksize[1]+8))
		self.set_image(self.get_image((208,0,16,8)),(4*self.blocksize[0],12*self.blocksize[1]))
		self.set_image(self.get_image((336,0,16,8)),(4*self.blocksize[0],12*self.blocksize[1]+8))
	
		self.set_image(self.get_image((96,0,16,8)),(5*self.blocksize[0],11*self.blocksize[1]+8))
		self.set_image(self.get_image((224,0,8,8)),(5*self.blocksize[0]+4,12*self.blocksize[1]))
		self.set_image(self.get_image((352,0,16,8)),(5*self.blocksize[0],12*self.blocksize[1]+8))
	
		self.set_image(self.get_image((112,0,16,8)),(6*self.blocksize[0],11*self.blocksize[1]+8))
		self.set_image(self.get_image((248,0,8,8)),(6*self.blocksize[0]+8,12*self.blocksize[1]))
		self.set_image(self.get_image((368,0,16,8)),(6*self.blocksize[0],12*self.blocksize[1]+8))
	
	def extract_water2(self):
		self.set_image(self.get_image((64,8,8,8)),(4,10*self.blocksize[1]))
		self.set_image(self.get_image((72,8,8,8)),(4,10*self.blocksize[1]+8))
		
		self.set_image(self.get_image((128,8,8,8)),(self.blocksize[0],10*self.blocksize[1]))
		self.set_image(self.get_image((144,8,8,8)),(self.blocksize[0] + 16,10*self.blocksize[1]))
		self.set_image(self.get_image((256,8,24,8)),(self.blocksize[0],10*self.blocksize[1]+8))
		
		self.set_image(self.get_image((384,8,24,8)),(2*self.blocksize[0] + 8,10*self.blocksize[1]+8))
	
	def extract_stone1(self):
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((384,0,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((0,8,16,8)),(0,8,16,16))
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((232,8,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((360,8,16,8)),(0,8,16,16))
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((464,8,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((480,8,16,8)),(0,8,16,16))
		self.put_image(tmpimg)
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((496,8,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((248,8,8,8)),(0,8,8,16))
		tmpimg.paste(self.get_image((376,8,8,8)),(8,8,16,16))
		self.put_image(tmpimg)
	
	def extract_unknown(self):
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((216,8,16,8)),(0,0,16,8))
		tmpimg.paste(self.get_image((344,8,16,8)),(0,8,16,16))
		self.put_image(tmpimg)
	
	def extract_revive(self):
		tmpimg = Image.new(self.iimg.mode,self.blocksize)
		tmpimg.paste(self.get_image((232,0,8,8)),(4,4,12,12))
		self.put_image(tmpimg)
	
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
		EffectExtractor(ifile,ofile).do_extract()
	else:
		basepath = os.path.split(os.path.realpath(__file__))[0] + "/.."
		sourcepath = basepath + "/origins/effects"
		destpath = basepath + "/effects"
		for file in os.listdir(sourcepath):
			EffectExtractor(sourcepath + "/" + file,destpath + "/" + file).do_extract()
			print("提取特效模型文件:" + file)
		os.system("pause")
	