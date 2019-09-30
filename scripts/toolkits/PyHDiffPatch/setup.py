# -*- coding: utf-8 -*-

import platform
from distutils.core import setup,Extension

MODNAME = 'HDiffPatch'

extra_compile_args = []
if platform.system() == "Darwin":
	extra_compile_args.append("-std=c++11")
	extra_compile_args.append("-fdeclspec")

setup(
	name=MODNAME,
	ext_modules=[Extension(MODNAME,
		sources=[
			'src/PyHDiffPatch.cpp',
			'src/HPatch/patch.cpp',
			'src/HDiff/diff.cpp',
			'src/HDiff/private_diff/bytes_rle.cpp',
			'src/HDiff/private_diff/compress_detect.cpp',
			'src/HDiff/private_diff/suffix_string.cpp',
			'src/HDiff/private_diff/libdivsufsort/divsufsort.cpp',
			'src/HDiff/private_diff/libdivsufsort/divsufsort64.cpp',
			'src/HDiff/private_diff/limit_mem_diff/stream_serialize.cpp',
			'src/HDiff/private_diff/limit_mem_diff/digest_matcher.cpp',
			'src/HDiff/private_diff/limit_mem_diff/adler_roll.cpp'
		],
		extra_compile_args = extra_compile_args)]) 
