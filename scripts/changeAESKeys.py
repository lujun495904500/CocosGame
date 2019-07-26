# -*- coding: utf-8 -*-

import os,re,random
from toolkits import tools

CURPATH = os.path.split(os.path.realpath(__file__))[0]

DEFAULT_COUNT = 5

# cpp文件模板
CPP_TEMPLATE = '''/**
 *	@file	aeskeys.cpp
 *	@date	2018/12/14
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	AES密钥文件
 */
 
#include "aeskeys.h"
 
bool L::getAESKey(int index, const unsigned char* &retkey, const unsigned char* &retiv) {
	switch (index) {
%s
	}
	return false;
}

bool L::getConfAESKey(const unsigned char* &retkey, const unsigned char* &retiv){
	return getAESKey(%d,retkey,retiv);
}

'''

# 索引分支模板
INDEXBRANCH_TEMPLATE = '''	case %d:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
%s
			
			// IV
%s
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}'''

# KEY分支模板
KEYBRANCH_TEMPLATE = '''			key[%d] = \'%s\';'''

# IV分支模板
IVBRANCH_TEMPLATE = '''			iv[%d] = \'%s\';'''

'''AES密钥更新器'''
class AESKeysUpdater:
	def update(self):
		count = input("需要生成多少AES密钥:")
		if count.isdigit():
			count = int(count)
		else:
			count = DEFAULT_COUNT
		self.aeskeys = []
		for i in range(count):
			(key,iv) = tools.make_aeskey(str(i))
			self.aeskeys.append({
				"key":key,
				"iv":iv
			})
		self.confaes = random.randint(0,len(self.aeskeys)-1)
		self.saveConfig()
		self.saveCpp()
	
	def saveConfig(self):
		config = tools.get_scriptconfig()
		config["aes"]["confindex"] = self.confaes
		config["aes"]["keys"] = self.aeskeys
		tools.save_scriptconfig(config)
		
	def saveCpp(self):
		indexbranchs = []
		index = 0
		for aes in self.aeskeys:
			keybranchs = []
			ivbranchs = []
			for i in range(16):
				keybranchs.append(KEYBRANCH_TEMPLATE % (i,"\\x"+aes["key"][i*2:i*2+2]))
				ivbranchs.append(IVBRANCH_TEMPLATE % (i,"\\x"+aes["iv"][i*2:i*2+2]))
			indexbranchs.append(INDEXBRANCH_TEMPLATE % (index,"\n".join(keybranchs),"\n".join(ivbranchs)))
			index += 1
		cppfile = tools.get_scriptconfig()["path"]["aeskeyscpp"]
		with open(cppfile,"w") as f:
			f.write(CPP_TEMPLATE % ("\n".join(indexbranchs),self.confaes))

if __name__ == "__main__":
	ensure = input("更新密钥影响很大，请确保所有后果知晓，真的需要更新吗?(Y/y)")
	if ensure.upper() == "Y":
		AESKeysUpdater().update()
	os.system("pause")
