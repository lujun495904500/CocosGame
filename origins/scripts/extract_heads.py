# -*- coding: utf-8 -*-

import sys,getopt,os
from PIL import Image

# 块大小
blocksize = (48,8)

# 块数量
blocknum = 6

# 提取点
extp = [0,0]

# 获得图像区块
def get_image_blocks(iimg):
	global extp
	blocks = []
	remain = blocksize[0]
	while remain > 0:
		if extp[0] == iimg.size[0]:
			extp[0] = 0
			extp[1] += blocksize[1]
		imgx = extp[0]
		imgy = extp[1]
		if extp[0] + remain <= iimg.size[0]:
			imgwidth = remain
			extp[0] += remain
		else:
			imgwidth = iimg.size[0] - extp[0]
			extp[0] = iimg.size[0]
		remain -= imgwidth
		blocks.append(iimg.crop((imgx,imgy,imgx + imgwidth,imgy + blocksize[1])))
	return blocks
	
# 放置头像区块
def put_head_blocks(oimg,index,blocks):
	imgy = index * blocksize[1]
	imgx = 0
	for block in blocks:
		bsize = block.size
		oimg.paste(block,(imgx,imgy,imgx + bsize[0],imgy + blocksize[1]))
		imgx += bsize[0]
	
# 提取指定数量的头像
def do_extract(iimg,odir,count,prefix):
	global extp
	for index in range(count):
		oimg = Image.new(iimg.mode,(blocksize[0],blocksize[1]*blocknum))
		put_head_blocks(oimg,0,get_image_blocks(iimg))
		put_head_blocks(oimg,1,get_image_blocks(iimg))
		put_head_blocks(oimg,2,get_image_blocks(iimg))
		put_head_blocks(oimg,3,get_image_blocks(iimg))
		put_head_blocks(oimg,4,get_image_blocks(iimg))
		put_head_blocks(oimg,5,get_image_blocks(iimg))
		oimg.save(odir + "/" + prefix + str(index) + "." + iimg.format.lower())
	
# 跳过指定宽度
def skip_width(iimg,width):
	global extp
	extp[0] += width
	extp[1] += (extp[0] // iimg.size[0]) * blocksize[1]
	extp[0] %= iimg.size[0]

# 提取头像
def extract_heads(ifile,odir=None):
	if odir == None:
		dir,file = os.path.split(ifile)
		fname,fext = os.path.splitext(file)
		odir = dir + "/" + fname + "_heads"
	
	# 传教文件夹
	if not os.path.exists(odir):
		os.makedirs(odir)
	
	iimg = Image.open(ifile)
	
	do_extract(iimg,odir,28,"p1_")
	skip_width(iimg,128)
	do_extract(iimg,odir,28,"p2_")
	skip_width(iimg,128)
	do_extract(iimg,odir,5,"p3_")
	
if __name__ == "__main__":
	ifile = None
	odir = None
	try:
		opts,args = getopt.getopt(sys.argv[1:],"i:d:",["ifile=","odir="])
	except getopt.GetoptError:
		print("命令行参数格式错误!")
		sys.exit(2)
	
	for opt,arg in opts:
		if opt in ("-i","--ifile"):
			ifile = arg
		elif opt in ("-d","--odir"):
			odir = arg
	if ifile == None and len(args) > 0:
		ifile = args[0]
	
	if ifile != None:
		extract_heads(ifile,odir)
	else:
		basepath = os.path.split(os.path.realpath(__file__))[0] + "/.."
		sourcefile = basepath + "/origins/heads.png"
		destdir = basepath + "/heads"
		extract_heads(sourcefile,destdir)
		print("提取头像文件:" + sourcefile)
		
		os.system("pause")
