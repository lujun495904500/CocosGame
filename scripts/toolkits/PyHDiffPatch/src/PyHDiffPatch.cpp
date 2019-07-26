/**
 *	@file	PyHDiffPatch.cpp
 *	@date	2018/12/19
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	HDiffPatch Python库程序
 */

#include <Python.h>
#include "HDiff/diff.h"
#include "HPatch/patch.h"
#include <memory>

static PyObject *HDiffPatchError;

static long stream_read(hpatch_TStreamInputHandle streamHandle,
	const hpatch_StreamPos_t readFromPos,
	unsigned char* out_data, unsigned char* out_data_end) {
	FILE *file = (FILE*)streamHandle;
	fseek(file, readFromPos, SEEK_SET);
	return fread(out_data, 1, out_data_end - out_data, file);
}

static long stream_write(hpatch_TStreamOutputHandle streamHandle,
	const hpatch_StreamPos_t writeToPos,
	const unsigned char* data, const unsigned char* data_end) {
	FILE *file = (FILE*)streamHandle;
	fseek(file, writeToPos, SEEK_SET);
	return fwrite(data, 1, data_end - data, file);
}

/*
 *	创建补丁文件
 */
static PyObject * create_diff(PyObject *self, PyObject *args) {
	const char *newpath,*oldpath,*diffpath;
	if (!PyArg_ParseTuple(args, "sss", &newpath, &oldpath, &diffpath))
		return NULL;
	
	FILE *newfile = nullptr;
	FILE *oldfile = nullptr;
	FILE *difffile = nullptr;
	do {
		newfile = fopen(newpath,"rb");
		oldfile = fopen(oldpath, "rb");
		difffile = fopen(diffpath, "wb");
		if (!newfile || !oldfile || !difffile) break;

		hpatch_TStreamInput		newData;
		hpatch_TStreamInput		oldData;
		hpatch_TStreamOutput	out_diff;

		newData.streamHandle = newfile;
		fseek(newfile,0,SEEK_END);
		newData.streamSize = ftell(newfile);
		newData.read = stream_read;

		oldData.streamHandle = oldfile;
		fseek(oldfile, 0, SEEK_END);
		oldData.streamSize = ftell(oldfile);
		oldData.read = stream_read;

		out_diff.streamHandle = difffile;
		out_diff.streamSize = 0;
		out_diff.write = stream_write;

		create_compressed_diff_stream(&newData, &oldData, &out_diff,0);

		fclose(newfile);
		fclose(oldfile);
		fclose(difffile);
		return Py_None;
	} while (0);

	if (newfile) fclose(newfile);
	if (oldfile) fclose(oldfile);
	if (difffile) fclose(difffile);
	return NULL;
}

/*
*	检查补丁文件
*/
static PyObject * check_diff(PyObject *self, PyObject *args) {
	const char *newpath, *oldpath, *diffpath;
	if (!PyArg_ParseTuple(args, "sss", &newpath, &oldpath, &diffpath))
		return NULL;

	FILE *newfile = nullptr;
	FILE *oldfile = nullptr;
	FILE *difffile = nullptr;
	do {
		newfile = fopen(newpath, "rb");
		oldfile = fopen(oldpath, "rb");
		difffile = fopen(diffpath, "rb");
		if (!newfile || !oldfile || !difffile) break;

		hpatch_TStreamInput		newData;
		hpatch_TStreamInput		oldData;
		hpatch_TStreamInput		diffData;

		newData.streamHandle = newfile;
		fseek(newfile, 0, SEEK_END);
		newData.streamSize = ftell(newfile);
		newData.read = stream_read;

		oldData.streamHandle = oldfile;
		fseek(oldfile, 0, SEEK_END);
		oldData.streamSize = ftell(oldfile);
		oldData.read = stream_read;

		diffData.streamHandle = difffile;
		fseek(difffile, 0, SEEK_END);
		diffData.streamSize = ftell(difffile);
		diffData.read = stream_read;

		hpatch_BOOL retval = check_compressed_diff_stream(&newData, &oldData, &diffData, 0);

		fclose(newfile);
		fclose(oldfile);
		fclose(difffile);
		return PyBool_FromLong(retval);
	} while (0);

	if (newfile) fclose(newfile);
	if (oldfile) fclose(oldfile);
	if (difffile) fclose(difffile);
	return NULL;
}

/*
*	打补丁
*/
static PyObject * patch(PyObject *self, PyObject *args) {
	const char *newpath, *oldpath, *diffpath;
	int bufsize = 1024 * 10;
	if (!PyArg_ParseTuple(args, "sss|i", &newpath, &oldpath, &diffpath,&bufsize))
		return NULL;

	FILE *newfile = nullptr;
	FILE *oldfile = nullptr;
	FILE *difffile = nullptr;
	do {
		newfile = fopen(newpath, "wb");
		oldfile = fopen(oldpath, "rb");
		difffile = fopen(diffpath, "rb");
		if (!newfile || !oldfile || !difffile) break;

		hpatch_TStreamOutput	out_new;
		hpatch_TStreamInput		oldData;
		hpatch_TStreamInput		diffData;

		diffData.streamHandle = difffile;
		fseek(difffile, 0, SEEK_END);
		diffData.streamSize = ftell(difffile);
		diffData.read = stream_read;

		hpatch_compressedDiffInfo diffInfo;
		if(!getCompressedDiffInfo(&diffInfo, &diffData)) break;

		oldData.streamHandle = oldfile;
		fseek(oldfile, 0, SEEK_END);
		oldData.streamSize = ftell(oldfile);
		oldData.read = stream_read;

		out_new.streamHandle = newfile;
		out_new.streamSize = diffInfo.newDataSize;
		out_new.write = stream_write;

		std::auto_ptr<char> patchbuff(new char[bufsize]);
		hpatch_BOOL retval = patch_decompress_with_cache(&out_new, &oldData, &diffData,0,
			(unsigned char*)(patchbuff.get()), (unsigned char*)(patchbuff.get()+ bufsize));
		
		fclose(newfile);
		fclose(oldfile);
		fclose(difffile);
		return PyBool_FromLong(retval);
	} while (0);

	if (newfile) fclose(newfile);
	if (oldfile) fclose(oldfile);
	if (difffile) fclose(difffile);
	return NULL;
}

static PyMethodDef HDiffPatchMethods[] = {
	{ "create_diff",  create_diff, METH_VARARGS, "create patch file" },
	{ "check_diff",  check_diff, METH_VARARGS, "check patch file" },
	{ "patch",  patch, METH_VARARGS, "patch file" },
	{NULL, NULL, 0, NULL}        /* Sentinel */
};

static struct PyModuleDef HDiffPatchModule = {
	PyModuleDef_HEAD_INIT,
	"HDiffPatch",
	NULL,
	-1,
	HDiffPatchMethods
};

extern "C" __declspec(dllexport) void PyInit_HDiffPatch() {
	PyModule_Create(&HDiffPatchModule);
}
