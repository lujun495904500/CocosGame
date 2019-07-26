# -*- coding: utf-8 -*-

import xlrd,os,shutil,re,getopt,sys
from toolkits import tools

CURPATH = os.path.split(os.path.realpath(__file__))[0]

# 转换映射表
TRANSLIST = (
("\r\n",	'\\n'),
("\r",		'\\n'),
("\n",		'\\n'),
("\\\\",	'\\'),
("\t",		'    ')
)

'''数据库更新器'''
class DatabaseUpdater:
	def __init__(self,config,nodename = "main"):
		self.config = config
		self.nodename = nodename
		self.nodepath = CURPATH + "/" + config["path"]["game"] + "/" + nodename
		if not os.path.isdir(self.nodepath):
			raise Exception("无法识别的节点: " + nodename + " !!!")
		self.dbpath = self.nodepath + "/origins/databases"
		self.dbrespath = self.nodepath + "/res/" + nodename + "/databases/"
		self.residxpath = self.nodepath + "/res/" + nodename + "/indexes/"
		self.residxconf = self.nodepath + "/res/" + nodename + "/indexes.json"
		
	def update(self):
		if os.path.isdir(self.dbpath):
			if not os.path.isdir(self.dbrespath):
				os.makedirs(self.dbrespath)
			tools.clear_dir(self.dbrespath)
			
			# 构建数据库文件
			self.dbindexes = { }
			for file in os.listdir(self.dbpath):
				if ( file.endswith(".xlsx") or file.endswith(".xls") ) and not file.startswith("~$"):
					self.xlsxToJson(self.dbpath + "/" + file)
			
			# 构建数据库索引
			if not os.path.isdir(self.residxpath):
				os.makedirs(self.residxpath)
			tools.write_utf8json({ "db":self.dbindexes }, self.residxpath + "/db_auto.json", self.config["debug"])
			
			# 更新资源索引表
			idxconfpath,_ = os.path.split(self.residxconf)
			if not os.path.isdir(idxconfpath):
				os.makedirs(idxconfpath)
			if os.path.isfile(self.residxconf):
				idxconf = tools.read_json(self.residxconf)
			else:
				idxconf = {}
			idxconf["db_auto"] = "$(respath)/" + self.nodename + "/indexes/db_auto.json"
			tools.write_utf8json(idxconf, self.residxconf, self.config["debug"])
	
	def xlsxToJson(self,xlsxfile):
		workbook = xlrd.open_workbook(xlsxfile)
		for sheet in workbook.sheets():
			if sheet.name in self.dbindexes:
				raise Exception('表' + sheet.name + '已经存在!!!')
			# 读取数据库类型
			keyvalue = sheet.row_values(0)[0].split('|')
			if len(keyvalue) > 0:
				if keyvalue[0] == "table":
					jsondata = self.tableToJson(sheet)
				elif keyvalue[0] == "list":
					jsondata = self.listToJson(sheet)
				elif keyvalue[0] == "map":
					jsondata = self.mapToJson(sheet)
				elif keyvalue[0] == "talk":
					jsondata = self.talkToJson(sheet)
				else:
					raise Exception("数据库(%s)类型(%s)无法识别!" % (sheet.name,keyvalue[0]))
				destdbfile = sheet.name + ".json"
				destdbpath = self.dbrespath + "/" + destdbfile
				tools.write_utf8json(jsondata,destdbpath,self.config["debug"])
				self.dbindexes[sheet.name] = [ "$(respath)/" + self.nodename + "/databases/" + destdbfile ]
				print("更新数据库:" + sheet.name)	
			
	def transferString(self,str):
		for (key,value) in TRANSLIST:
			str = str.replace(key,value)
		return str
		
	def convertValue(self,value,type,params = []):
		if value == "":
			return None
		
		if type == "string":
			cvalue=self.transferString(str(value))
		elif type == "int":
			cvalue=int(value)
		elif type == "float":
			cvalue=float(value)
		elif type == "bool":
			if isinstance(value,str):
				cvalue = value.upper() == "TRUE"
			else:
				cvalue=bool(value)
		elif type == "group":
			sepa = ","
			if len(params) > 0:
				sepa=params[0]
			cvalue=str(value).split(sepa)
		elif type == "set":
			sepa = ","
			if len(params) > 0:
				sepa=params[0]
			setkeys = str(value).split(sepa)
			cvalue = {}
			for setkey in setkeys:
				if len(setkey) > 0:
					cvalue[setkey] = True
		elif type == "map":
			sepa = ","
			if len(params) > 0:
				sepa=params[0]
			deftp = "string"
			if len(params) > 1:
				deftp=params[1]
			mapvalues = str(value).split(sepa)
			cvalue = {}
			for mapvalue in mapvalues:
				values = mapvalue.split("=")
				if len(values) > 0:
					mapkey = values[0]
					if len(values) > 1:
						mapval = values[1]
					else:
						mapval = True
					valtp = deftp
					if ":" in mapkey:
						keyvals = mapkey.split(":")
						if len(keyvals) > 0:
							mapkey = keyvals[0]
							if len(keyvals) > 1:
								valtp = keyvals[1]
					cvalue[mapkey] = self.convertValue(mapval,valtp)
					
		return cvalue

	def tableToJson(self,sheet):
		heads = sheet.row_values(0)
		keyvalue = heads[0].split('|')
		if len(keyvalue) >= 2:
			defaulttype = keyvalue[1]
		else:
			defaulttype = "string"
		
		# 处理表头类型
		HEAD = []
		HEAD.append({'name':"key",'type':"string",'params':[]})
		for index in range(1,len(heads)):
			headvalue = heads[index].split(':')
			if len(headvalue) > 1:
				headtype = headvalue[1]
			else:
				headtype = defaulttype
			HEAD.append({'name':headvalue[0],'type':headtype,'params':headvalue[2:]})
				
		# 读取数据
		DATA = {}
		
		for rowindex in range(1,sheet.nrows):
			rowvalues = sheet.row_values(rowindex)
			rowname = rowvalues[0]
			if rowname.startswith("#"):
				continue
			ROW = {}
			for colindex in range(1,len(rowvalues)):
				colvalue = rowvalues[colindex]
				colname = HEAD[colindex]["name"]
				if colname.startswith("#"):
					continue
				value = self.convertValue(colvalue,HEAD[colindex]["type"],HEAD[colindex]["params"])
				if value != None:
					ROW[colname] = value
			DATA[rowname] = ROW
			
		return DATA
	
	def listToJson(self,sheet):
		keyvalue = sheet.row_values(0)[0].split('|')
		if len(keyvalue) >= 2:
			defaulttype = keyvalue[1]
		else:
			defaulttype = "string"
			
		# 组成数据
		DATA = {}
		
		for rowindex in range(1,sheet.nrows):
			rowvalues = sheet.row_values(rowindex)
			rowname = rowvalues[0]
			if rowname.startswith("#"):
				continue
			ROW = []
			for colindex in range(1,len(rowvalues)):
				value = rowvalues[colindex]
				if len(value)==0:
					break
				ROW.append(self.convertValue(value,defaulttype))
			DATA[rowname] = ROW
		
		return DATA
	
	def mapToJson(self,sheet):
		keyvalue = sheet.row_values(0)[0].split('|')
		if len(keyvalue) >= 2:
			defaulttype = keyvalue[1]
		else:
			defaulttype = "string"
		
		# 组成数据
		DATA = {}
		
		for rowindex in range(1,sheet.nrows):
			rowvalues = sheet.row_values(rowindex)
			
			if len(rowvalues) < 2 or rowvalues[0].startswith("#"):
				continue
			
			keyvalues = rowvalues[0].split(':')
			if len(keyvalues) > 1:
				valuetype = keyvalues[1]
			else:
				valuetype = defaulttype
			DATA[keyvalues[0]] = self.convertValue(rowvalues[1],valuetype)
			
		return DATA
	
	def talkCommand(self,talk,command):
		cmds = []
		def paramIndex(param):
			if param.isdigit():
				return int(param)
			else:
				return param
		for (type,param) in re.findall(r'(\w+)[(]([^)]*)[)]',command):
			if type.upper() == "TALK":
				cmds.append({
					"type":"TALK",
					"id":param
				})
			elif type.upper() == "SELECT":
				selects=[]
				params = param.split("|")
				for selstr in params[0].split(","):
					item = selstr.split(":")
					selects.append({
						"label":item[0],
						"id":item[1]
					})
				cmd = {
					"type":"SELECT",
					"selects":selects
				}
				if len(params) > 1:
					cmd["cancel"] = params[1]
				cmds.append(cmd)
			elif type.upper() == "SCRIPT":
				params = param.split(":")
				cmd = {
					"type":"SCRIPT",
					"index":paramIndex(params[0])
				}
				if len(params) > 1:
					cmd["param"] = params[1].split(",")
				cmds.append(cmd)
			elif type.upper() == "EPOINT":
				params = param.split(":")
				cmds.append({
					"type":"EPOINT",
					"index":paramIndex(params[0]),
					"value":params[1].upper()=="TRUE"
				})
			else:
				raise Exception("无法识别的命令:%s(%s)" %(type,param))
		if len(cmds) > 0:
			talk["cmds"] = cmds
	
	def talkMessage(self,value):
		msg = None
		options = None
		if value.endswith("}"):
			opstart = value.rfind("\\{")
			if opstart != -1:
				count = 0
				indexs = range(0,opstart)
				for i in reversed(indexs):
					if value[i] == "\\":
						count += 1
					else:
						break
				if count % 2 == 0:
					msg = value[:opstart]
					options = value[opstart+2:-1].replace(' ', '').split(',')	
		if msg == None:
			msg = self.convertValue(value,"string")
		if options == None:
			options = []
		return (msg,options)
	
	def talkToJson(self,sheet):
		DATA = {}
		
		for rowindex in range(1,sheet.nrows):
			rowvalues = sheet.row_values(rowindex)
			rowname = rowvalues[0]
			if rowname.startswith("#"):
				continue
			ROW = []
			for colindex in range(1,len(rowvalues)):
				value = rowvalues[colindex]
				if len(value)==0:
					break
				else:
					if value.startswith('&'):
						talk = ROW[-1]
						self.talkCommand(talk,value[1:].replace(' ', ''))
					elif value.startswith('$'):
						talk = {}
						ROW.append(talk)
						self.talkCommand(talk,value[1:].replace(' ', ''))
					else:
						talk = {}
						ROW.append(talk)
						(msg,options) = self.talkMessage(value)
						talk["msg"] = msg
						for opt in options:
							talk[opt] = True
			DATA[rowname] = ROW
		
		return DATA
	
def updateDatabases():
	config = tools.get_scriptconfig()
	dopacks = config['update']['dopacks']
	
	# 更新节点
	def updateNode(nodename):
		print(">>>>>>>>>>>>>>>>>>>[%s]数据库>>>>>>>>>>>>>>>>>>" % nodename)
		try:
			DatabaseUpdater(config,nodename).update()
			print("<<<<<<<<<<<<<<<<<<更新完成<<<<<<<<<<<<<<<<<<<\n")
		except Exception as e:
			print(e)
			print("<<<<<<<<<<<<<<<<<<<更新失败!!!<<<<<<<<<<<<<<<<<<<\n")
	
	# 遍历所有包
	for nodename in os.listdir(CURPATH + "/" + config["path"]["game"]):
		if os.path.isdir(CURPATH + "/" + config["path"]["game"] + "/" + nodename) and tools.wildcard_matchs(dopacks,nodename):
			updateNode(nodename)
	
if __name__ == "__main__":
	updateDatabases()
	os.system("pause")