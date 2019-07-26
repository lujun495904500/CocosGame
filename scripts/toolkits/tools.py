# -*- coding: utf-8 -*-

import os,sys,itertools,json,configparser,math,struct,subprocess
import hashlib,re,uuid,zlib

CURPATH = os.path.split(os.path.realpath(__file__))[0]

# 配置文件
CONFIG_FILE = CURPATH + "/../config.json"

#openssl命令目录
if sys.platform == 'win32':
	OPENSSL_CMD=os.path.join(CURPATH,r'openssl/openssl')
else:
	OPENSSL_CMD = "openssl"

def all_equal(elements):  
    first_element = elements[0]  
    for other_element in elements[1:]:  
        if other_element != first_element : return False  
    return True  
  
def common_prefix(*sequences):  
    if not sequences: return[],[]  
    common = []  
    for elements in itertools.zip_longest(*sequences):  
        if not all_equal(elements):break  
        common.append(elements[0])  
    return common,[sequence[len(common):] for sequence in sequences]  
  
def relpath(p1,p2, sep=os.path.sep, pardir=os.path.pardir):  
    common,(u1,u2) = common_prefix(p1.split(sep),p2.split(sep))  
    if not common:  
        return p2      
    return sep.join([pardir] * len(u1) + u2) 

def read_json(jfile):
	with open(jfile, 'r') as f:
		return json.load(f)
		
def write_json(jobj,jfile,debug=False):
	with open(jfile, 'w') as f:
		if debug:
			f.write(json.dumps(jobj,indent=4, separators=(',', ': ')))
		else:
			f.write(json.dumps(jobj,separators=(',', ':')))
		
def write_utf8json(jobj,jfile,debug=False):
	with open(jfile, 'wb') as f:
		if debug:
			f.write(json.dumps(jobj,indent=4, separators=(',', ': ')).
				encode('utf-8').decode("unicode-escape").encode('utf-8'))
		else:
			f.write(json.dumps(jobj,separators=(',', ':')).
				encode('utf-8').decode("unicode-escape").encode('utf-8'))

def read_file(file, mode = "r" ,encoding = 'utf-8'):
	with open(file, mode, encoding = encoding) as f:
		return f.read()
		
def write_file(data, file, mode = "w" ,encoding = 'utf-8'):
	with open(file, mode, encoding = encoding) as f:
		f.write(data)

def read_config(cfile,fencding='utf-8'):
	config = configparser.ConfigParser()
	config.read(cfile, encoding=fencding)
	return config

def wildcard_match(wcs,str):
	widx = 0
	sidx = 0
	while True:
		if widx >= len(wcs):
			return sidx >= len(str)
		if wcs[widx] == "?":
			widx += 1
			sidx += 1
		elif wcs[widx] == "*":
			widx += 1
			while sidx < len(str):
				if wildcard_match(wcs[widx:],str[sidx:]):
					return True
				sidx += 1
			return widx >= len(wcs)
		else:
			if widx>=len(wcs) or sidx>=len(str) or wcs[widx] != str[sidx]:
				return False
			widx += 1
			sidx += 1

def wildcard_matchs(wcslist,str):
	for wcs in wcslist:
		if wildcard_match(wcs,str):
			return True
	return False
			
def pack_texture(sheet,data,repsrc,repdest,packpath,oldver = False):
	subprocess.call([
		"TexturePacker", 
		"--sheet",  sheet,
		"--data",  data,
		"--replace", "%s=%s" % (repsrc,repdest),
		"--prepend-folder-name",
		"--format", ("cocos2d-v2" if oldver else "cocos2d"),
		"--trim-sprite-names",
		"--allow-free-size",
		"--max-size", "1024",
		"--no-trim",
		packpath
	])
	#"--size-constraints","POT",
	
def compile_lua(srcfile,is64 = True,isjit = True,destfile = None):
	if destfile == None:
		destfile = srcfile + "c"
	bit_prefix =  "64bit" if is64 else "32bit"
	if isjit:
		if sys.platform == 'win32':
			exepath =  CURPATH + "/luacompile/" + bit_prefix + "/luajit-win32.exe"
		elif sys.platform == 'darwin':
			exepath =  CURPATH + "/luacompile/" + bit_prefix + "/luajit-mac"
		elif 'linux' in sys.platform:
			exepath =  CURPATH + "/luacompile/" + bit_prefix + "/luajit-linux"
	else:
		if sys.platform == 'win32':
			exepath =  CURPATH + "/luacompile/" + bit_prefix + "/lua-win32.exe"
		elif sys.platform == 'darwin':
			raise Exception("not found luac in mac")
		elif 'linux' in sys.platform:
			raise Exception("not found luac in linux")
	oldcwd = os.getcwd()
	os.chdir(CURPATH + "/luacompile/" + bit_prefix)
	if isjit:
		subprocess.call([
			exepath,
			"-b",
			srcfile,
			destfile
		])
	else:
		subprocess.call([
			exepath,
			"-o",
			destfile,
			srcfile
		])
	os.chdir(oldcwd)
	
def encrypto_aes(key,iv,infile,outfile = None):
	if outfile == None:
		outfile = infile + "_en"
	subprocess.call([
		OPENSSL_CMD,
		'enc','-aes-128-cbc',
		'-in',infile,
		'-out',outfile,
		'-K',key,
		'-iv',iv
	])
	
def decrypto_aes(key,iv,infile,outfile = None):
	if outfile == None:
		outfile = infile + "_de"
	subprocess.call([
		OPENSSL_CMD,
		'enc','-aes-128-cbc','-d',
		'-in',infile,
		'-out',outfile,
		'-K',key,
		'-iv',iv
	])
	
def make_aeskey(passwd,salt = None):
	if salt == None:
		salt = str(uuid.uuid4()).replace("-","").upper()[8:24]
	retdata = subprocess.check_output([OPENSSL_CMD,
		'enc','-aes-128-cbc',
		'-pass','pass:' + passwd,
		'-S',salt,'-P']).decode('gbk')
	key = None
	iv = None
	keymatch = re.compile(r'^\s*key\s*=\s*(.+)\s*$',re.M).search(retdata)
	if keymatch != None:
		key = keymatch.group(1)
	ivmatch = re.compile(r'^\s*iv\s*=\s*(.+)\s*$',re.M).search(retdata)
	if ivmatch != None:
		iv = ivmatch.group(1)
	return (key,iv)
		
def format_filesize(filesize,width = 8):
	if filesize <= math.pow(1024,1):
		return ("%" + str(width) + "d B ") % filesize
	elif filesize <= math.pow(1024,2):
		return ("%" + str(width) + ".2f KB") % (filesize/math.pow(1024,1))
	elif filesize <= math.pow(1024,3):
		return ("%" + str(width) + ".2f MB") % (filesize/math.pow(1024,2))
	else:
		return ("%" + str(width) + ".2f GB") % (filesize/math.pow(1024,3))
	
def copyFiles(sourceDir,  targetDir):
	if sourceDir.find(".svn") > 0: 
		return 
	for file in os.listdir(sourceDir): 
		sourceFile = os.path.join(sourceDir,  file) 
		targetFile = os.path.join(targetDir,  file) 
		if os.path.isfile(sourceFile): 
			if not os.path.exists(targetDir):  
				os.makedirs(targetDir)  
			open(targetFile, "wb").write(open(sourceFile, "rb").read()) 
		elif os.path.isdir(sourceFile): 
			First_Directory = False 
			copyFiles(sourceFile, targetFile)
	
def getVersionName(vercode):
	verps = []
	while True:
		verps.insert(0,vercode % 1000)
		if vercode < 1000:
			break
		else:
			vercode /= 1000
	vername = ""
	for ver in verps:
		if len(vername) > 0:
			vername += "."
		vername += "%d" % ver
	return vername
	
def getVersionCode(vername):
	vercode = 0
	verss = vername.split(".")
	for ver in verss:
		vercode *= 1000
		vercode += int(ver)
	return vercode
	
def file_md5(file,offest = 0, block_size=2**20):
	md5 = hashlib.md5()
	with open(file,'rb') as cf:
		cf.seek(offest)
		while True:
			data = cf.read(block_size)
			if not data:
				break
			md5.update(data)
	md5 = struct.unpack("BBBBBBBBBBBBBBBB",md5.digest())
	return "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x" % \
		(md5[0],md5[1],md5[2],md5[3],md5[4],md5[5],md5[6],md5[7],md5[8],md5[9],md5[10],md5[11],md5[12],md5[13],md5[14],md5[15])

def split_file(infile,outdir,outfmt,maxsize,tozlib = False,zlevel = 9):
	filecount = 0
	insize = 0
	filesize = os.path.getsize(infile)
	while insize < filesize:
		with open(infile,"rb") as inf:
			outsize = 0
			sppath = outdir + "/" + (outfmt %filecount)
			if tozlib:
				compress = zlib.compressobj(zlevel)
			with open(sppath,"wb") as outf:
				while outsize < maxsize and insize < filesize:
					readsize = min(maxsize-outsize,filesize-insize,1024)
					inf.seek(insize)
					indata = inf.read(readsize)
					if tozlib:
						indata = compress.compress(indata)
					outf.write(indata)
					outsize += readsize
					insize += readsize
				if tozlib:
					outf.write(compress.flush())
			filecount += 1
	return filecount
	
def merge_file(indir,outfile,infmt,iszlib):
	filecount = 0
	
	with open(outfile,"wb") as outf:
		while True:
			inpath = indir + "/" + (infmt % filecount)
			if not os.path.isfile(inpath):
				break
			else:
				with open(inpath,"rb") as inf:
					indata = inf.read()
					if not iszlib:
						outf.write(indata)
					else:
						outf.write(zlib.decompress(indata))
			filecount += 1
	
def clear_dir(path):
	for file in os.listdir(path):
		filepath = path + "/" + file
		if os.path.isfile(filepath):
			os.remove(filepath)
		else:
			shutil.rmtree(filepath)
	
##------------------二进制块--------------------
def getLongBlock(integer):
	return struct.pack("<I",integer)
	
def getLongValue(block):
	return struct.unpack("<I",block)[0]
	
def getShortBlock(long):
	return struct.pack("<H",long)
	
def getByteBlock(byte):
	return struct.pack("<B",byte)
	
def getStringBlock(str):
	str = str.encode("utf-8")
	return struct.pack("%dsc" % len(str),str,b'\0')

def getLengthStringBlock(str):
	str = str.encode("utf-8")
	return struct.pack("H%ds" % len(str),len(str),str)
	
##------------------------------------------------

# 脚本配置
def get_scriptconfig():
	return read_json(CONFIG_FILE)
def save_scriptconfig(config):
	write_json(config,CONFIG_FILE,True)
	