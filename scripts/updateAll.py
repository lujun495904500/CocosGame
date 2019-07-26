# -*- coding: utf-8 -*-

import os
from updateCSBPlist import updateCSBPlist
from updateDatabases import updateDatabases
from updateEffects import updateEffects
from updateModels import updateModels
from updateProtocols import updateProtocols

if __name__ == "__main__":
	updateCSBPlist()
	print("--------------------------------------------------------\n")
	updateDatabases()
	print("--------------------------------------------------------\n")
	updateEffects()
	print("--------------------------------------------------------\n")
	updateModels()
	print("--------------------------------------------------------\n")
	updateProtocols()
	
	os.system("pause")