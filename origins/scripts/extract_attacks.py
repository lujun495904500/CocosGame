# -*- coding: utf-8 -*-

import sys,getopt,os
from PIL import Image

'''攻击图片提取器'''
class AttackExtractor:
	# 输入单元高度
	iheight = 8
	
	# 块大小
	blocksize = (96,32)
	
	# 输出大小
	outsize = (6,20)
	
	# 输出图像大小
	oimgsize = (blocksize[0] * outsize[0],blocksize[1] * outsize[1])
	
	'''初始化'''
	def __init__(self,ifile,ofile):
		if ofile == None:
			dir,file = os.path.split(ifile)
			fname,fext = os.path.splitext(file)
			ofile = dir + "/" + fname + "_attacks" + fext
		self.iimg = Image.open(ifile)
		self.isize = self.iimg.size
		self.ipos = [0,0]
		self.oimg = Image.new(self.iimg.mode,self.oimgsize)
		self.opos = [0,0]
		self.ofile = ofile
		self.pieceimg = [] # 图像碎片
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
		# 剑
		self.extract_8_4x16_32(1)
		self.extract_2x16_24_32(1)
		self.extract_24_2x16_32(1)
		self.extract_8_4x16_32T(1)
		self.extract_3x16_32(1)
		self.extract_4x16_32(1)
		self.extract_8_24_2x16_32(1)
		self.extract_32_2x16_32(1)
		self.extract_24_2x16_32T1(1)
		self.extract_4x16_32(1)
		self.extract_24_2x16_32(1)
		# 2行 完
		self.extract_4x16_24_32(1)
		self.extract_16_32_16_24_16(1)
		self.extract_8_3x16_24_32(1)
		self.extract_24_2x16_32(1)
		self.extract_8_3x24_32S(1)
		self.extract_16_24_16_32(1)
		self.extract_8_3x16_24_32(1)
		self.extract_4x16_32(1)
		self.skip_width(32)
		self.extract_8_4x16_32(1)
		self.skip_line()
		self.skip_width(40)
		self.extract_line5_first()
		self.extract_3x16_24_32H(1)
		self.extract_2x16_2x24_32(1)
		self.extract_8_2x24_16_32(1)
		self.extract_3x16_24_32(1)
		self.extract_4x16_32T(2)
		self.skip_width(64)
		self.extract_16_2x24_16_32(1)
		self.extract_4x16_32S(1)
		self.extract_8_3x16_8_24_32(1)
		self.extract_8_4x16_32T(1)
		self.extract_4x16_32T(1)
		self.extract_8_3x16_2x32(1)
		self.extract_8_2x16_2x8_32(1)
		self.extract_3x16_2x32(3)
		self.extract_4x16_32T(1)
		self.skip_line()
		# 8 行
		self.pieceimg.append(self.get_image(56)) # 1
		self.extract_4x16_32T(1)
		self.extract_3x16_2x32(1)
		self.extract_16_24_2x16_2x32(1)
		self.pieceimg.append(self.get_image(56)) # 2
		self.extract_8_3x16_24_32(1)
		self.extract_3x16_24_32T(1)
		self.extract_8_3x16_24_32T(1)
		self.extract_3x16_24_32T(1)
		self.extract_4x16_32T(1)
		self.extract_3x16_24_32S(1)
		self.pieceimg.append(self.get_image(56)) # 3
		self.pieceimg.append(self.get_image(40)) # 4
		self.pieceimg.append(self.get_image(48)) # 5
		self.pieceimg.append(self.get_image(64)) # 6
		self.merge_pieces_4_1(self.pieceimg[3],self.pieceimg[0])
		self.merge_pieces_3_5(self.pieceimg[2],self.pieceimg[4])
		self.merge_pieces_6_2(self.pieceimg[5],self.pieceimg[1])
		self.skip_width(112)
		self.extract_5x16_32(1)
		self.extract_8_4x16_32S(1)
		self.extract_5x16_32(1)
		self.extract_8_3x16_24_32(2)
		self.extract_2x8_3x16_32(1)
		self.extract_5x16_32(1)
		self.extract_8_3x16_24_32(1)
		self.skip_width(24)
		
		# 弓箭手
		self.extract_archer(3,True)
		self.extract_archer(1)
		self.skip_line()
		
		# 刀
		self.extract_5x16_32H(1)
		self.extract_8_3x16_2x32H(1)
		self.extract_5x16_32H(1)
		self.extract_4x16_32T(1)
		self.extract_5x16_32S(1)
		self.extract_5x16_32H(1)
		self.extract_8_4x16_32(1)
		self.extract_2x16_2x24(1)
		self.extract_3x24_32(1)
		self.skip_line()
		
		# 枪
		self.extract_16_32_16_32(3)
		self.extract_16_32_16_8_24O(1,-2)
		self.extract_16_32_16_32(1)
		self.extract_16_32_16_32S(1)
		self.extract_16_32_16_32(2)
		self.extract_16_32_16_8_24O(1,-1)
		self.extract_16_32_16_32(1)
		self.extract_16_32_16_32R(1)
		self.extract_16_32_16_8_24O(1,-1)
		self.extract_16_32_16_32(1)
		self.extract_16_2x24_32(1)
		self.extract_16_32_16_8_24O(1,-1)
		self.extract_16_32_16_32(2)
		self.extract_16_32_24_32(2)
		self.extract_16_32_16_32(2)
		self.skip_line()
		self.pieceimg.append(self.get_image(80)) # 7
		self.extract_16_32_16_32(1)
		self.extract_16_24_16_32(2)
		self.pieceimg.append(self.get_image(16)) # 8
		self.merge_pieces_8_7(self.pieceimg[7],self.pieceimg[6])
		self.extract_16_32_16_32(1)
		
		self.oimg.save(self.ofile)
	
	'''合并碎片4和1'''
	def merge_pieces_4_1(self,img1,img2):
		if self.opos[0] == self.oimgsize[0]:
			self.opos[0] = 0
			self.opos[1] += self.blocksize[1]
		poslist=[0,0]
		self.oimg.paste(self.get_image_by(img1,16,poslist,0),(self.opos[0] + 24,self.opos[1] + 1*self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
		self.oimg.paste(self.get_image_by(img1,16,poslist,0),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
		self.oimg.paste(self.get_image_by(img1,8,poslist,0),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 24,self.opos[1]+ 4*self.iheight))
		self.oimg.paste(self.get_image_by(img2,8,poslist,1),(self.opos[0] + 24,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
		self.oimg.paste(self.get_image_by(img2,16,poslist,1),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
		self.oimg.paste(self.get_image_by(img2,32,poslist,1),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
		self.opos[0] += self.blocksize[0]
	
	'''合并碎片3和5'''
	def merge_pieces_3_5(self,img1,img2):
		if self.opos[0] == self.oimgsize[0]:
			self.opos[0] = 0
			self.opos[1] += self.blocksize[1]
		poslist=[0,0]
		self.oimg.paste(self.get_image_by(img1,24,poslist,0),(self.opos[0] + 16,self.opos[1] + 1*self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
		self.oimg.paste(self.get_image_by(img1,16,poslist,0),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
		self.oimg.paste(self.get_image_by(img1,16,poslist,0),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
		self.oimg.paste(self.get_image_by(img2,16,poslist,1),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
		self.oimg.paste(self.get_image_by(img2,32,poslist,1),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
		self.opos[0] += self.blocksize[0]
	
	'''合并碎片6和2'''
	def merge_pieces_6_2(self,img1,img2):
		if self.opos[0] == self.oimgsize[0]:
			self.opos[0] = 0
			self.opos[1] += self.blocksize[1]
		poslist=[0,0]
		self.oimg.paste(self.get_image_by(img1,16,poslist,0),(self.opos[0] + 20,self.opos[1] + 1*self.iheight,self.opos[0] + 36,self.opos[1]+ 2*self.iheight))
		self.oimg.paste(self.get_image_by(img1,24,poslist,0),(self.opos[0] + 12,self.opos[1] + 2*self.iheight,self.opos[0] + 36,self.opos[1]+ 3*self.iheight))
		self.oimg.paste(self.get_image_by(img1,24,poslist,0),(self.opos[0] + 12,self.opos[1] + 3*self.iheight,self.opos[0] + 36,self.opos[1]+ 4*self.iheight))
		self.oimg.paste(self.get_image_by(img2,24,poslist,1),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
		self.oimg.paste(self.get_image_by(img2,32,poslist,1),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
		self.opos[0] += self.blocksize[0]
	
	'''合并碎片8和7'''
	def merge_pieces_8_7(self,img1,img2):
		if self.opos[0] == self.oimgsize[0]:
			self.opos[0] = 0
			self.opos[1] += self.blocksize[1]
		poslist=[0,0]
		self.oimg.paste(self.get_image_by(img1,16,poslist,0),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
		self.oimg.paste(self.get_image_by(img2,32,poslist,1),(self.opos[0] + 0,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
		self.oimg.paste(self.get_image_by(img2,16,poslist,1),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
		self.oimg.paste(self.get_image_by(img2,32,poslist,1),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
		self.opos[0] += self.blocksize[0]
		
	'''获得指定宽度的图片'''
	def get_image(self,width):
		if self.ipos[0] == self.isize[0]:
			self.ipos[0] = 0
			self.ipos[1] += self.iheight
		img = self.iimg.crop((self.ipos[0],self.ipos[1],self.ipos[0] + width,self.ipos[1] + self.iheight))
		self.ipos[0] += width
		return img
	def get_image_by(self,img,width,poslist,index):
		cimg = img.crop((poslist[index],0,poslist[index] + width,self.iheight))
		poslist[index] += width
		return cimg
	
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
	
	def extract_8_4x16_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(8),(self.opos[0] + 24,self.opos[1],self.opos[0] + 32,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + self.iheight,self.opos[0] + 32,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
			
	def extract_2x16_24_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1] + 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1] + 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1] + 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1] + 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_24_2x16_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(24),(self.opos[0] + 8,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1] + 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1] + 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1] + 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1] + 4*self.iheight))
			self.opos[0] += self.blocksize[0]
			
	def extract_3x16_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1] + 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1] + 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1] + 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1] + 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_4x16_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + self.iheight,self.opos[0] + 32,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_8_24_2x16_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(8),(self.opos[0] + 32,self.opos[1] + self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 40,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
			
	def extract_32_2x16_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(32),(self.opos[0] + 0,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
			
	def extract_24_2x16_32T1(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(24),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 40,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
				
	def extract_4x16_24_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1],self.opos[0] + 40,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
					
	def extract_16_32_16_24_16(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 0,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 48,self.opos[1] + self.iheight,self.opos[0] + 64,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
					
	def extract_8_3x16_24_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(8),(self.opos[0] + 24,self.opos[1],self.opos[0] + 32,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + self.iheight,self.opos[0] + 32,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
			
	def extract_8_3x24_32S(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(8),(self.opos[0] + 28,self.opos[1] + 1*self.iheight,self.opos[0] + 36,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 12,self.opos[1] + 2*self.iheight,self.opos[0] + 36,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 12,self.opos[1] + 3*self.iheight,self.opos[0] + 36,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 56,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
			
	def extract_16_24_16_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 8,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
			
	'''line5_first'''
	def extract_line5_first(self):
		if self.opos[0] == self.oimgsize[0]:
			self.opos[0] = 0
			self.opos[1] += self.blocksize[1]
		self.oimg.paste(self.get_image(8),(self.opos[0] + 72,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
		self.oimg.paste(self.get_image(24),(self.opos[0] + 16,self.opos[1] + 1*self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
		self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
		self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
		self.oimg.paste(self.get_image(8),(self.opos[0] + 48,self.opos[1] + 2*self.iheight,self.opos[0] + 56,self.opos[1]+ 3*self.iheight))
		self.oimg.paste(self.get_image(16),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 72,self.opos[1]+ 3*self.iheight))
		self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
		self.opos[0] += self.blocksize[0]
		
	def extract_3x16_24_32H(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + 1*self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
		
	def extract_2x16_2x24_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 20,self.opos[1] + 1*self.iheight,self.opos[0] + 36,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 20,self.opos[1] + 2*self.iheight,self.opos[0] + 36,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 12,self.opos[1] + 3*self.iheight,self.opos[0] + 36,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
		
	def extract_8_2x24_16_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(8),(self.opos[0] + 32,self.opos[1] + 1*self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 40,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 40,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 56,self.opos[1] + 3*self.iheight,self.opos[0] + 88,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
		
	def extract_3x16_24_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 1*self.iheight,self.opos[0] + 32,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_4x16_32T(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
		
	def extract_16_2x24_16_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + 1*self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 40,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 40,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 68,self.opos[1] + 2*self.iheight,self.opos[0] + 84,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 52,self.opos[1] + 3*self.iheight,self.opos[0] + 84,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_4x16_32S(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 56,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_8_3x16_8_24_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(8),(self.opos[0] + 32,self.opos[1] + 0*self.iheight,self.opos[0] + 40,self.opos[1]+ 1*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + 1*self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 48,self.opos[1] + 2*self.iheight,self.opos[0] + 56,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_8_4x16_32T(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(8),(self.opos[0] + 32,self.opos[1],self.opos[0] + 40,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_8_3x16_2x32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(8),(self.opos[0] + 32,self.opos[1],self.opos[0] + 40,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_8_2x16_2x8_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(8),(self.opos[0] + 32,self.opos[1] + self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 72,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 72,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_3x16_2x32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_16_24_2x16_2x32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + 0*self.iheight,self.opos[0] + 40,self.opos[1]+ 1*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 16,self.opos[1] + 1*self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
		
	def extract_3x16_24_32T(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + 1*self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
				
	def extract_8_3x16_24_32T(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(8),(self.opos[0] + 32,self.opos[1],self.opos[0] + 40,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
		
	def extract_3x16_24_32S(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + 1*self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 24,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 24,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_5x16_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1],self.opos[0] + 40,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 24,self.opos[1] + self.iheight,self.opos[0] + 40,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_8_4x16_32S(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(8),(self.opos[0] + 24,self.opos[1],self.opos[0] + 32,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 16,self.opos[1] + self.iheight,self.opos[0] + 24,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 24,self.opos[1] + self.iheight,self.opos[0] + 32,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_2x8_3x16_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(8),(self.opos[0] + 24,self.opos[1],self.opos[0] + 32,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 24,self.opos[1] + self.iheight,self.opos[0] + 32,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 72,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 72,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	'''箭'''
	def extract_arrow(self):
		self.arrow_frames=[]
		for idx in range(3):
			frames = Image.new(self.iimg.mode,(16,16))
			frames.paste(self.get_image(16),(0,0*self.iheight,16,1*self.iheight))
			frames.paste(self.get_image(16),(0,1*self.iheight,16,2*self.iheight))
			self.arrow_frames.append(frames)
		
	'''弓箭手'''
	def extract_archer(self,count,arrow = False):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 12,self.opos[1] + 2*self.iheight,self.opos[0] + 28,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 12,self.opos[1] + 3*self.iheight,self.opos[0] + 28,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 44,self.opos[1] + 2*self.iheight,self.opos[0] + 60,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 36,self.opos[1] + 3*self.iheight,self.opos[0] + 60,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 76,self.opos[1] + 2*self.iheight,self.opos[0] + 92,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 68,self.opos[1] + 3*self.iheight,self.opos[0] + 92,self.opos[1]+ 4*self.iheight))
			if arrow:
				self.extract_arrow()
			self.oimg.alpha_composite(self.arrow_frames[0],(self.opos[0]+4,self.opos[1]+8),(0,0,16,16))
			self.oimg.alpha_composite(self.arrow_frames[1],(self.opos[0]+35,self.opos[1]+16),(0,0,16,16))
			self.oimg.alpha_composite(self.arrow_frames[2],(self.opos[0]+68,self.opos[1]+16),(0,0,16,16))
			self.opos[0] += self.blocksize[0]
	
	def extract_5x16_32H(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1],self.opos[0] + 32,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + self.iheight,self.opos[0] + 32,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_8_3x16_2x32H(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(8),(self.opos[0] + 24,self.opos[1],self.opos[0] + 32,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + self.iheight,self.opos[0] + 32,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_5x16_32S(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1],self.opos[0] + 32,self.opos[1] + self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + self.iheight,self.opos[0] + 32,self.opos[1]+ 2*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 72,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 72,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
		
	def extract_2x16_2x24(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_3x24_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(24),(self.opos[0] + 8,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 8,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 48,self.opos[1] + 2*self.iheight,self.opos[0] + 72,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_16_32_16_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 0,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_16_32_16_8_24O(self,count,offest):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 0,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(8),(self.opos[0] + 48,self.opos[1] + 3*self.iheight + offest,self.opos[0] + 56,self.opos[1]+ 4*self.iheight + offest))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_16_32_16_32R(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 0,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_16_32_16_32S(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 0,self.opos[1] + 3*self.iheight,self.opos[0] + 16,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_16_2x24_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 8,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_16_32_24_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 0,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 56,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	def extract_16_24_16_32(self,count):
		for i in range(count):
			if self.opos[0] == self.oimgsize[0]:
				self.opos[0] = 0
				self.opos[1] += self.blocksize[1]
			self.oimg.paste(self.get_image(16),(self.opos[0] + 16,self.opos[1] + 2*self.iheight,self.opos[0] + 32,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(24),(self.opos[0] + 8,self.opos[1] + 3*self.iheight,self.opos[0] + 32,self.opos[1]+ 4*self.iheight))
			self.oimg.paste(self.get_image(16),(self.opos[0] + 64,self.opos[1] + 2*self.iheight,self.opos[0] + 80,self.opos[1]+ 3*self.iheight))
			self.oimg.paste(self.get_image(32),(self.opos[0] + 48,self.opos[1] + 3*self.iheight,self.opos[0] + 80,self.opos[1]+ 4*self.iheight))
			self.opos[0] += self.blocksize[0]
	
	
if __name__ == "__main__":
	ifile = None
	ofile = None
	try:
		opts,args = getopt.getopt(sys.argv[1:],"i:o:",["ifile=","ofile="])
	except getopt.GetoptError:
		print("命令行参数格式错误!")
		sys.exit(2)
	
	for opt,arg in opts:
		if opt in ("-i","--ifile"):
			ifile = arg
		elif opt in ("-o","--ofile"):
			ofile = arg
	if ifile == None and len(args) > 0:
		ifile = args[0]
		
	if ifile != None:
		AttackExtractor(ifile,ofile).do_extract()
	else:
		basepath = os.path.split(os.path.realpath(__file__))[0] + "/.."
		sourcepath = basepath + "/origins/attacks"
		destpath = basepath + "/attacks"
		for file in os.listdir(sourcepath):
			AttackExtractor(sourcepath + "/" + file,destpath + "/" + file).do_extract()
			print("提取攻击模型文件:" + file)
		os.system("pause")