/**
 *	@file	FileManager.cpp
 *	@date	2018/12/14
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	�ļ�������
 */

#include <algorithm>
#include "FileManager.h"
#include "BufferReader.h"
#include "FileReader.h"
#include "LUtils.h"
#include "L/aeskeys.h"
#include <zlib.h>
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
#include "cocos/platform/win32/CCFileUtils-win32.h"
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "cocos/platform/android/CCFileUtils-android.h"
#else
#include "cocos/platform/apple/CCFileUtils-apple.h"
#endif

using namespace L;

FileManager	*FileManager::g_instance = nullptr;
const std::string NATIVEPATH = "~/";

static bool FM_AES_decrypt(size_t keyindex, ResizableBuffer *srcbuff, size_t contentsize, ResizableBuffer*destbuff) {
	const unsigned char* aeskey = nullptr;
	const unsigned char* aesiv = nullptr;
	if (!L::getAESKey(keyindex, aeskey, aesiv)) return false;

	size_t outsize = contentsize;
	destbuff->resize(outsize);
	if (!L::AES_decrypt(aeskey, aesiv, (const unsigned char*)srcbuff->buffer(), contentsize,
		(unsigned char *)destbuff->buffer(), outsize)) return false;
	destbuff->resize(outsize);
	return true;
}

class MgrFile : public cocos2d::File{
public:
	MgrFile(Data &&data):
		m_data(data),
		m_cursor(0)
	{}
	~MgrFile() {}
	ssize_t read(void *buf, size_t count) {
		count = MIN(count, m_data.getSize() - m_cursor);
		memcpy(buf, m_data.getBytes() + m_cursor, count);
		m_cursor += count;
		return count;
	}
	size_t write(const void *buf, size_t count) {
		return (size_t)-1;
	}
	off_t seek(off_t offset, int whence) {
		size_t lastcur = m_cursor;
		switch (whence) {
		case SEEK_SET: m_cursor = offset; break;
		case SEEK_CUR: m_cursor += offset; break;
		case SEEK_END: m_cursor = m_data.getSize() + offset; break;
		default: return -1;
		}
		if (m_cursor < 0 || m_cursor > m_data.getSize()) {
			m_cursor = lastcur;
			return -1;
		}
		//return 0;
		return m_cursor;
	}
	size_t tell() {
		return m_cursor;
	}
private:
	Data	m_data;
	size_t	m_cursor;
};

FileUtils* FileUtils::getInstance() {
	if (s_sharedFileUtils == nullptr) {
		s_sharedFileUtils = FileManager::getInstance();
	}
	return s_sharedFileUtils;
}

void FileUtils::destroyInstance() {
	CC_SAFE_DELETE(FileManager::g_instance);
	s_sharedFileUtils = nullptr;
}

FileManager* FileManager::getInstance() {
	if (g_instance == nullptr) {
		g_instance = new FileManager();
		if (!g_instance->init()) {
			delete g_instance;
			g_instance = nullptr;
			CCLOG("ERROR: Could not init FileManager");
		}
	}
	return g_instance;
}

FileManager::FileManager():
	m_nativeFileUtils(nullptr)
{}

FileManager::~FileManager() {
	CC_SAFE_DELETE(m_nativeFileUtils);
	for (PackMap::iterator pitr = m_packMap.begin(); pitr!= m_packMap.end();++pitr) {
		closePackFile(m_packFiles[pitr->second]);
	}
	m_packMap.clear();
	m_packFiles.clear();
	m_fileMap.clear();
}

bool FileManager::init() {
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
	m_nativeFileUtils = new FileUtilsWin32();
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	m_nativeFileUtils = new FileUtilsAndroid();
#else
	m_nativeFileUtils = new FileUtilsApple();
#endif
	if (!m_nativeFileUtils->init()) {
		delete m_nativeFileUtils;
		m_nativeFileUtils = nullptr;
		CCLOG("ERROR: Could not init nativeFileUtils");
		return false;
	}
	_defaultResRootPath = "/";
	return FileUtils::init();
}

bool FileManager::isNativePath(const std::string &filepath) const {
	return !strncmp(filepath.c_str(), NATIVEPATH.c_str(), NATIVEPATH.size());
}

std::string FileManager::_removeNativeFlag(const std::string &filepath) const {
	return filepath.substr(NATIVEPATH.size());
}

std::string FileManager::removeNativeFlag(const std::string &filepath) const {
	if (isNativePath(filepath)) {
		return _removeNativeFlag(filepath);
	} else {
		return filepath;
	}
}

std::string FileManager::getNativeRootPath() const {
	return NATIVEPATH;
}

const FileConfig* FileManager::getMapFileInternal(const std::string& strPath) const {
	if (!strPath.empty()) {
		std::string filepath = strPath;
		if (filepath[filepath.size() - 1] == '/') {
			filepath.pop_back();
		}
		FileMap::const_iterator fitr = m_fileMap.find(filepath);
		if (fitr != m_fileMap.end()) {
			return &(fitr->second);
		}
	}
	return nullptr;
}

File* FileManager::open(const std::string& filename, const std::string &mode) {
	if (isNativePath(filename)) {
		return m_nativeFileUtils->open(_removeNativeFlag(filename), mode);
	}
	std::string fullPath = fullPathForFilename(filename);
	if (fullPath.empty() || mode.find('r') == std::string::npos || !isFileExist(fullPath)){
		return nullptr;
	} else {
		return new MgrFile(getDataFromFile(fullPath));
	}
}

void FileManager::addSearchPath(const std::string & path, const bool front){
	if (isNativePath(path)) {
		m_nativeFileUtils->addSearchPath(path, front);
	} else {
		return FileUtils::addSearchPath(path, front);
	}
}

FileUtils::Status FileManager::getContents(const std::string& filename, ResizableBuffer* buffer) const {
	if (isNativePath(filename)) {
		return m_nativeFileUtils->getContents(_removeNativeFlag(filename), buffer);
	}
	const FileConfig *fconfig = getMapFileInternal(fullPathForFilename(filename));
	if (fconfig && !fconfig->isdir) {
		int steps = 0;
		if (fconfig->u.f.flag & FileConfig::FF_COMPRESS) steps++;
		if (fconfig->u.f.flag & FileConfig::FF_CRYPTO) steps++;

		Data tempdata;
		ResizableBufferAdapter<Data> tempbuff(&tempdata);
		ResizableBuffer *pdestbuff = buffer;
		ResizableBuffer *ptempbuff = &tempbuff;
		size_t contentsize = 0;

		// ��ȡ����
		if (0 != steps % 2) {
			std::swap(pdestbuff, ptempbuff);
		}
		pdestbuff->resize(fconfig->contentsize);
		contentsize = fconfig->contentsize;
		if (!readPackData(m_packFiles[fconfig->packindex], fconfig->offest, pdestbuff->buffer(), fconfig->contentsize)) {
			return Status::OpenFailed;
		}
		
		if (fconfig->u.f.flag & FileConfig::FF_COMPRESS) {
			std::swap(pdestbuff, ptempbuff);	// ����
			uLongf uncompsize = BufferReader(ptempbuff->buffer(), contentsize).readLong();
			pdestbuff->resize(uncompsize);
			if (Z_OK != uncompress((Bytef *)pdestbuff->buffer(), &uncompsize, (Bytef *)((char*)ptempbuff->buffer() + 4), contentsize - 4)) {
				return Status::ReadFailed;
			}
			contentsize = uncompsize;
		}

		if (fconfig->u.f.flag & FileConfig::FF_CRYPTO) {
			std::swap(pdestbuff, ptempbuff);
			if (!FM_AES_decrypt(fconfig->u.f.keyindex, ptempbuff, contentsize, pdestbuff)) {
				return Status::ReadFailed;
			}
		}
		
		return Status::OK;
	} else {
		return Status::NotExists;
	}
}

unsigned char* FileManager::getFileDataFromZip(const std::string& zipFilePath, const std::string& filename, ssize_t *size) const {
	if (isNativePath(zipFilePath)) {
		return m_nativeFileUtils->getFileDataFromZip(_removeNativeFlag(zipFilePath), filename, size);
	} else {
		CCLOG("ERROR: FileManager not support getFileDataFromZip");
		*size = 0;
		return nullptr;
	}
}

std::string FileManager::fullPathForFilename(const std::string &filename) const {
	if (isNativePath(filename)) {
		return NATIVEPATH + m_nativeFileUtils->fullPathForFilename(_removeNativeFlag(filename));
	} else {
		return FileUtils::fullPathForFilename(filename);
	}
}

std::string FileManager::getWritablePath() const {
	return NATIVEPATH + m_nativeFileUtils->getWritablePath();
}

void FileManager::setWritablePath(const std::string& writablePath) {
	m_nativeFileUtils->setWritablePath(removeNativeFlag(writablePath));
}

bool FileManager::writeToFile(const ValueMap& dict, const std::string& fullPath) const {
	if (isNativePath(fullPath)) {
		return m_nativeFileUtils->writeToFile(dict,_removeNativeFlag(fullPath));
	} else {
		CCLOG("ERROR: FileManager not support writeToFile");
		return false;
	}
}

bool FileManager::writeStringToFile(const std::string& dataStr, const std::string& fullPath) const {
	if (isNativePath(fullPath)) {
		return m_nativeFileUtils->writeStringToFile(dataStr, _removeNativeFlag(fullPath));
	} else {
		CCLOG("ERROR: FileManager not support writeStringToFile");
		return false;
	}
}

bool FileManager::writeDataToFile(const Data& data, const std::string& fullPath) const {
	if (isNativePath(fullPath)) {
		return m_nativeFileUtils->writeDataToFile(data, _removeNativeFlag(fullPath));
	} else {
		CCLOG("ERROR: FileManager not support writeDataToFile");
		return false;
	}
}

bool FileManager::appendStringToFile(const std::string& dataStr, const std::string& fullPath) const {
	if (isNativePath(fullPath)) {
		return m_nativeFileUtils->appendStringToFile(dataStr, _removeNativeFlag(fullPath));
	} else {
		CCLOG("ERROR: FileManager not support writeStringToFile");
		return false;
	}
}

bool FileManager::appendDataToFile(const Data& data, const std::string& fullPath) const {
	if (isNativePath(fullPath)) {
		return m_nativeFileUtils->appendDataToFile(data, _removeNativeFlag(fullPath));
	} else {
		CCLOG("ERROR: FileManager not support writeDataToFile");
		return false;
	}
}

bool FileManager::writeValueMapToFile(const ValueMap& dict, const std::string& fullPath) const {
	if (isNativePath(fullPath)) {
		return m_nativeFileUtils->writeValueMapToFile(dict, _removeNativeFlag(fullPath));
	} else {
		CCLOG("ERROR: FileManager not support writeValueMapToFile");
		return false;
	}
}

bool FileManager::writeValueVectorToFile(const ValueVector& vecData, const std::string& fullPath) const {
	if (isNativePath(fullPath)) {
		return m_nativeFileUtils->writeValueVectorToFile(vecData, _removeNativeFlag(fullPath));
	} else {
		CCLOG("ERROR: FileManager not support writeValueVectorToFile");
		return false;
	}
}

std::string FileManager::getSuitableFOpen(const std::string& filenameUtf8) const {
	return filenameUtf8;
}

bool FileManager::isFileExist(const std::string& filename) const {
	if (isNativePath(filename)) {
		return m_nativeFileUtils->isFileExist(_removeNativeFlag(filename));
	} else {
		return FileUtils::isFileExist(filename);
	}
}

bool FileManager::isAbsolutePath(const std::string& strPath) const {
	if (isNativePath(strPath)) {
		return m_nativeFileUtils->isAbsolutePath(_removeNativeFlag(strPath));
	} else {
		return (strPath.size() > 0 && strPath[0] == '/');
	}
}

bool FileManager::isDirectoryExist(const std::string& dirPath) const {
	if (isNativePath(dirPath)) {
		return m_nativeFileUtils->isDirectoryExist(_removeNativeFlag(dirPath));
	} else {
		return FileUtils::isDirectoryExist(dirPath);
	}
}

bool FileManager::createDirectory(const std::string& dirPath) const {
	if (isNativePath(dirPath)) {
		return m_nativeFileUtils->createDirectory(_removeNativeFlag(dirPath));
	} else {
		CCLOG("ERROR: FileManager not support createDirectory");
		return false;
	}
}

bool FileManager::removeDirectory(const std::string& dirPath) const {
	if (isNativePath(dirPath)) {
		return m_nativeFileUtils->removeDirectory(_removeNativeFlag(dirPath));
	} else {
		CCLOG("ERROR: FileManager not support removeDirectory");
		return false;
	}
}

bool FileManager::removeFile(const std::string &filepath) const {
	if (isNativePath(filepath)) {
		return m_nativeFileUtils->removeFile(_removeNativeFlag(filepath));
	} else {
		CCLOG("ERROR: FileManager not support removeFile");
		return false;
	}
}

bool FileManager::renameFile(const std::string &oldfullpath, const std::string &newfullpath) const {
	if (isNativePath(oldfullpath) || isNativePath(newfullpath)) {
		return m_nativeFileUtils->renameFile(removeNativeFlag(oldfullpath), removeNativeFlag(newfullpath));
	} else {
		CCLOG("ERROR: FileManager not support renameFile");
		return false;
	}
}

long FileManager::getFileSize(const std::string &filepath) const {
	if (isNativePath(filepath)) {
		return m_nativeFileUtils->getFileSize(_removeNativeFlag(filepath));
	}
	const FileConfig *fconfig = getMapFileInternal(fullPathForFilename(filepath));
	if (fconfig && !fconfig->isdir) {
		return fconfig->u.f.filesize;
	}
	return -1;
}

std::vector<std::string> FileManager::listFiles(const std::string& dirPath) const {
	if (isNativePath(dirPath)) {
		std::vector<std::string> files = m_nativeFileUtils->listFiles(_removeNativeFlag(dirPath));
		for (std::string &file : files) {
			file.insert(0, NATIVEPATH);
		}
		return files;
	}
	std::vector<std::string> files;
	std::string fullpath = fullPathForFilename(dirPath);
	const FileConfig *fconfig = getMapFileInternal(fullpath);
	if (fconfig && fconfig->isdir) {
		do {
			int steps = 0;
			if (fconfig->u.d.flag & FileConfig::FF_CRYPTO) steps++;

			Data tempdata1;
			ResizableBufferAdapter<Data> tempbuff1(&tempdata1);
			Data tempdata2;
			ResizableBufferAdapter<Data> tempbuff2(&tempdata2);
			ResizableBuffer *pdestbuff = &tempbuff1;
			ResizableBuffer *ptempbuff = &tempbuff2;
			size_t contentsize = 0;

			// ��ȡ����
			pdestbuff->resize(fconfig->contentsize);
			contentsize = fconfig->contentsize;
			if (!readPackData(m_packFiles[fconfig->packindex], fconfig->offest, pdestbuff->buffer(), fconfig->contentsize)) break;

			// ����
			if (fconfig->u.d.flag & FileConfig::FF_CRYPTO) {
				std::swap(pdestbuff, ptempbuff);
				if (!FM_AES_decrypt(fconfig->u.d.keyindex, ptempbuff, contentsize, pdestbuff)) break;
			}

			if (fullpath[fullpath.size() - 1] != '/') {
				fullpath += '/';
			}
			BufferReader reader(pdestbuff->buffer(), contentsize);
			size_t filecount = reader.readShort();
			for (int i = 0; i < filecount; ++i) {
				files.push_back(fullpath + reader.readString());
			}

		} while (0);
	}
	return files;
}

void FileManager::listFilesRecursively(const std::string& dirPath, std::vector<std::string> *files) const {
	if (isNativePath(dirPath)) {
		m_nativeFileUtils->listFilesRecursively(_removeNativeFlag(dirPath), files);
		for (std::string &file : *files) {
			file.insert(0, NATIVEPATH);
		}
	}
	std::string fullpath = fullPathForFilename(dirPath);
	const FileConfig *fconfig = getMapFileInternal(fullpath);
	if (fconfig && fconfig->isdir) {
		do {
			int steps = 0;
			if (fconfig->u.d.flag & FileConfig::FF_CRYPTO) steps++;

			Data tempdata1;
			ResizableBufferAdapter<Data> tempbuff1(&tempdata1);
			Data tempdata2;
			ResizableBufferAdapter<Data> tempbuff2(&tempdata2);
			ResizableBuffer *pdestbuff = &tempbuff1;
			ResizableBuffer *ptempbuff = &tempbuff2;
			size_t contentsize = 0;

			// ��ȡ����
			pdestbuff->resize(fconfig->contentsize);
			contentsize = fconfig->contentsize;
			if (!readPackData(m_packFiles[fconfig->packindex], fconfig->offest, pdestbuff->buffer(), fconfig->contentsize)) break;

			// ����
			if (fconfig->u.d.flag & FileConfig::FF_CRYPTO) {
				std::swap(pdestbuff, ptempbuff);
				if (!FM_AES_decrypt(fconfig->u.d.keyindex, ptempbuff, contentsize, pdestbuff)) break;
			}

			if (fullpath[fullpath.size() - 1] != '/') {
				fullpath += '/';
			}
			BufferReader reader(pdestbuff->buffer(), contentsize);
			size_t filecount = reader.readShort();
			for (int i = 0; i < filecount; ++i) {
				std::string filename = fullpath + reader.readString();
				if (isDirectoryExist(filename)) {
					files->push_back(filename + '/');
					listFilesRecursively(filename, files);
				} else {
					files->push_back(filename);
				}
			}

		} while (0);
	}
}

bool FileManager::isFileExistInternal(const std::string& strPath) const {
	const FileConfig *fconfig = getMapFileInternal(strPath);
	return (fconfig != nullptr);
}

bool FileManager::isDirectoryExistInternal(const std::string& dirPath) const {
	const FileConfig *fconfig = getMapFileInternal(dirPath);
	return (fconfig != nullptr && fconfig->isdir);
}

std::string FileManager::getFileName(const std::string &filepath) {
	size_t pos = filepath.find_last_of("/\\");
	if (pos != std::string::npos) {
		return filepath.substr(pos + 1);
	}
	return filepath;
}

std::string FileManager::getPackName(const std::string &packpath) {
	std::string packname;
	size_t spos = packpath.find_last_of("/\\");
	if (spos != std::string::npos) {
		packname = packpath.substr(spos + 1);
	} else {
		packname = packpath;
	}
	size_t epos = packname.find_last_of(".");
	if (epos != std::string::npos){
		return packname.substr(0, epos);
	} else {
		return packname;
	}
}

std::string FileManager::getFileDirectory(const std::string &filepath) {
	size_t pos = filepath.find_last_of("/\\");
	if (pos != std::string::npos) {
		return filepath.substr(0,pos);
	}
	return filepath;
}

int FileManager::getEmptyFileIndex() {
	for (int i = 0;i<m_packFiles.size();++i) {
		if (!m_packFiles[i].file) {
			return i;
		}
	}
	m_packFiles.resize(m_packFiles.size() + 1);
	return m_packFiles.size() - 1;
}

bool FileManager::readPackData(const PackFile &pack, unsigned long offest, void *buff, size_t size) const {
	if (pack.file){
		std::lock_guard<std::mutex> locker(*pack.mutex);

		if (fseek(pack.file, offest, SEEK_SET)) return false;
		if (fread(buff, 1, size, pack.file) != size) return false;
		return true;
	}
	return false;
}

void FileManager::closePackFile(PackFile &pack) {
	if (pack.file) {
		fclose(pack.file);
		pack.file = nullptr;
	}
	CC_SAFE_DELETE(pack.mutex);
}

bool FileManager::setFilePack(const std::string &pname, int pindex, FILE *pfile) {
	if (m_packMap.find(pname) != m_packMap.end()){
		CCLOG("Error:file pack %s conflict", pname.c_str());
		return false;
	}
	if (pindex >= m_packFiles.size()) {
		m_packFiles.resize(pindex + 1);
	}
	m_packMap[pname] = pindex;
	PackFile &pack = m_packFiles[pindex];
	pack.file = pfile;
	pack.mutex = new std::mutex();
	return true;
}

void FileManager::unsetFilePack(const std::string &pname) {
	PackMap::iterator pitr = m_packMap.find(pname);
	if (pitr != m_packMap.end()) {
		PackFile &pack = m_packFiles[pitr->second];
		pack.file = nullptr;
		CC_SAFE_DELETE(pack.mutex);
		
		m_packMap.erase(pitr);
	}
}

bool FileManager::setupPackFile(int pindex, FILE *pfile) {
	FileReader preader(pfile);
	m_packFiles[pindex].version = preader.readLong();
	unsigned short version = preader.readShort();
	switch (version) {
	case 1:
	{
		{
			size_t headsize = preader.readLong();
			unsigned char hkeyindex = preader.readByte();

			Data headdata;
			ResizableBufferAdapter<Data> headbuff(&headdata);
			Data tempdata;
			ResizableBufferAdapter<Data> tempbuff(&tempdata);

			tempbuff.resize(headsize);
			preader.readBlock((char*)tempbuff.buffer(), headsize);
			if (!FM_AES_decrypt(hkeyindex, &tempbuff, headsize, &headbuff)){
				return false;
			}

			size_t offest = preader.getOffest();
			BufferReader hreader(headdata.getBytes(), headdata.getSize());
			size_t filecount = hreader.readLong();
			for (int i = 0; i < filecount; ++i) {
				std::string fpath = hreader.readString();
				if (m_fileMap.find(fpath) != m_fileMap.end()) {
					CCLOG("Error:pack file %s conflict", fpath.c_str());
					return false;
				}
				FileConfig fconfig;
				fconfig.isdir = hreader.readByte();
				if (fconfig.isdir) {
					fconfig.u.d.flag = hreader.readShort();
					fconfig.u.d.keyindex = hreader.readByte();
				}
				else {
					fconfig.u.f.filesize = hreader.readLong();
					fconfig.u.f.flag = hreader.readShort();
					fconfig.u.f.keyindex = hreader.readByte();
				}
				fconfig.packindex = pindex;
				fconfig.contentsize = hreader.readLong();
				fconfig.offest = offest;
				offest += fconfig.contentsize;
				m_fileMap[fpath] = fconfig;
			}
		}

		return true;
	}
	default:
		CCLOG("Error:can't read pack ?VERSION %d", version);
		return false;
	}
}

void FileManager::deletePackFile(int pindex) {
	for (FileMap::const_iterator fitr = m_fileMap.begin(); fitr!= m_fileMap.end();) {
		if (fitr->second.packindex == pindex){
			fitr = m_fileMap.erase(fitr);
		} else {
			++fitr;
		}
	}
}

bool FileManager::loadFilePack(const std::string& packPath) {
	std::string filepath = removeNativeFlag(packPath);
	FILE *pfile = fopen(filepath.c_str(),"rb");
	if (!pfile) {
		CCLOG("Error:can't open pack %s", filepath.c_str());
		return false;
	}
	std::string pname = getPackName(filepath);
	int pindex = getEmptyFileIndex();
	
	if (!setFilePack(pname, pindex, pfile)){
		fclose(pfile);
		return false;
	}

	if (!setupPackFile(pindex,pfile)){
		deletePackFile(pindex);
		unsetFilePack(pname);
		fclose(pfile);
		return false;
	}
	return true;
}

void FileManager::releaseFilePack(const std::string& packName) {
	PackMap::iterator pitr = m_packMap.find(packName);
	if (pitr != m_packMap.end()){
		closePackFile(m_packFiles[pitr->second]);
		deletePackFile(pitr->second);
		m_packMap.erase(pitr);
	}
}

unsigned long FileManager::getPackVersion(const std::string& packName) {
	PackMap::iterator pitr = m_packMap.find(packName);
	if (pitr != m_packMap.end()) {
		return m_packFiles[pitr->second].version;
	}
	return 0;
}

unsigned long FileManager::lookPackVersion(const std::string& packPath) {
	std::string filepath = removeNativeFlag(packPath);
	FILE *pfile = fopen(filepath.c_str(), "rb");
	if (!pfile) {
		CCLOG("Error:can't open pack %s", filepath.c_str());
		return 0;
	}

	FileReader preader(pfile);
	unsigned long version = preader.readLong();
	fclose(pfile);

	return version;
}
