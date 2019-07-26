# -*- coding: utf-8 -*-

import os,itertools,json,configparser

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

def read_config(cfile,fencding='utf-8'):
	config = configparser.ConfigParser()
	config.read(cfile, encoding=fencding)
	return config

# 获得脚本配置
def get_scriptconfig():
	return read_json(os.path.split(os.path.realpath(__file__))[0] + "/config.json")
	
	