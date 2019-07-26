# -*- coding: utf-8 -*-

import sys,getopt,os
from PIL import Image

# 高度偏移
heightoffest = 0 #0 38

# 复制区域
copysize = (8,8)

# 粘贴区域
pastesize = (16,16)

# 移除黑色背景
def remove_blackbg(iimg):
	iimg = iimg.convert(mode="RGBA")
	for y in range(iimg.size[1]):
		for x in range(iimg.size[0]):
			p = iimg.getpixel((x,y))
			if p[0] == 0 and p[1] == 0 and p[2] == 0:
				iimg.putpixel((x,y),(0,0,0,0))
	return iimg

# 获得图像区块
def get_image_block(img,bwidth,index,hoffest):
	sx = index % bwidth
	sy = index // bwidth
	#print("<",sx,sy,">")
	return img.crop((sx * copysize[0],sy * copysize[1] + hoffest,
			(sx + 1) * copysize[0],(sy + 1) * copysize[1] + hoffest))

# 设置图像区块
def set_image_block(img,pwidth,index,zs,zx,ys,yx):
	sx = index % pwidth
	sy = index // pwidth
	#print("[",sx,sy,"]")
	img.paste(zs,(sx * pastesize[0],sy * pastesize[1],sx * pastesize[0] + copysize[0],sy * pastesize[1] + copysize[1]))
	img.paste(zx,(sx * pastesize[0],sy * pastesize[1] + copysize[1],sx * pastesize[0] + copysize[0],sy * pastesize[1] + 2*copysize[1]))
	img.paste(ys,(sx * pastesize[0] + copysize[0],sy * pastesize[1],sx * pastesize[0] + 2*copysize[0],sy * pastesize[1] + copysize[1]))
	img.paste(yx,(sx * pastesize[0] + copysize[0],sy * pastesize[1] + copysize[1],sx * pastesize[0] + 2*copysize[0],sy * pastesize[1] + 2*copysize[1]))

# 提取行走图
def extract_walk(infile,hoffest=0,outfile=None):
	if outfile == None:
		dir,file = os.path.split(infile)
		fname,fext = os.path.splitext(file)
		outfile = dir + "/" + fname + "_walk" + fext
	# 输出文件
	iimg = Image.open(infile)
	iimg = remove_blackbg(iimg)
	oimg = Image.new(iimg.mode,iimg.size)
	
	bwidth = iimg.size[0] // copysize[0]
	bheight = (iimg.size[1] - hoffest) // copysize[1]
	
	pwidth = iimg.size[0] // pastesize[0]
	pheight = iimg.size[1] // pastesize[1]
	
	# 遍历所有块
	for i in range(0,bwidth*bheight,4):
		zs = get_image_block(iimg,bwidth,i,hoffest)
		zx = get_image_block(iimg,bwidth,i+1,hoffest)
		ys = get_image_block(iimg,bwidth,i+2,hoffest)
		yx = get_image_block(iimg,bwidth,i+3,hoffest)
		set_image_block(oimg,pwidth,i//4,zs,zx,ys,yx)
	
	oimg.save(outfile)
	
if __name__ == "__main__":
	infile = None
	outfile = None
	hoffest = heightoffest
	try:
		opts,args = getopt.getopt(sys.argv[1:],"i:o:h:",["ifile=","ofile=","hoffest="])
	except getopt.GetoptError:
		print("命令行参数格式错误!")
		sys.exit(2)
	
	for opt,arg in opts:
		if opt in ("-i","--ifile"):
			infile = arg
		elif opt in ("-o","--ofile"):
			outfile = arg
		elif opt in ("-h","--hoffest"):
			hoffest = int(arg)
	if infile == None and len(args) > 0:
		infile = args[0]
	
	if infile != None:
		extract_walk(infile,hoffest,outfile)
	else:
		basepath = os.path.split(os.path.realpath(__file__))[0] + "/.."
		sourcepath = basepath + "/origins/walks"
		destpath = basepath + "/walks"
		for file in os.listdir(sourcepath):
			extract_walk(sourcepath + "/" + file,hoffest,destpath + "/" + file)
			print("提取行走模型文件:" + file)
		os.system("pause")
