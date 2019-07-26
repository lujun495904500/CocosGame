# -*- coding: utf-8 -*-

import sys,getopt,os,re
from enum import Enum
from toolkits import tools

REG_DEC_NAME = re.compile(r'(.+)_dec')

def get_configaes():
	config = tools.get_scriptconfig()
	return config["aes"]["keys"][config["aes"]["confindex"]]

#解密文件
def crypto_file(opertype,infile,outfile):
	confaes = get_configaes()
	if opertype == "E":
		tools.encrypto_aes(confaes["key"],confaes["iv"],infile,outfile)
	elif opertype == "D":
		tools.decrypto_aes(confaes["key"],confaes["iv"],infile,outfile)

# 操作加密解密
def do_crypto(opertype,infile,outfile,*args):
	if infile == None and len(args)>0:
		infile = args[0]
	if infile == None:
		print('未识别加密或解密文件!!!')
		sys.exit(3)
	
	# 分析输入文件路径
	findir,finname = os.path.split(infile)
	finmain,finext = os.path.splitext(finname)
	
	# 判断文件操作类型
	if opertype == "U":
		if REG_DEC_NAME.match(finmain):
			opertype = "E"
		else:
			opertype = "D"
	
	# 判断输出文件路径
	if outfile == None:
		mpair = REG_DEC_NAME.match(finmain)
		if mpair:
			outfile = os.path.join(findir,mpair.group(1)+finext)
		else:
			outfile = os.path.join(findir,finmain+'_dec'+finext)
	
	# 执行加密解密文件
	crypto_file(opertype,infile,outfile)
	
# 执行函数
if __name__== '__main__' :
	opertype = "U"
	infile = None
	outfile = None
	
	# 解析命令行
	try:
		opts, args = getopt.getopt(sys.argv[1:], "i:o:ed", ["infile=","outfile=","encode","decode"])
	except getopt.GetoptError as err:
		print(err)
		sys.exit(1)
		
	for o, a in opts:
		if o in ("-i", "--infile"):
			infile = a
		elif o in ("-o", "--outfile"):
			outfile = a
		elif o in ("-e", "--encode"):
			opertype = "E"
		elif o in ("-d", "--decode"):
			opertype = "D"
	
	# 执行命令
	do_crypto(opertype,infile,outfile,*args)
	#os.system('pause')
