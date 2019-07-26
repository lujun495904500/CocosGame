/**
 *	@file	FileManager.h
 *	@date	2018/12/14
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	�ļ�������
 */

#ifndef __FILEMANAGER_20181214220759_H
#define __FILEMANAGER_20181214220759_H

#include "platform/CCFileUtils.h"
#include <unordered_map>
#include <string>
#include <vector>
#include <mutex>

USING_NS_CC;

namespace L {

struct FileConfig {
	enum FileFlag {
		FF_CRYPTO = 1,		// ����
		FF_COMPRESS = 2,		// ѹ��
	};
	unsigned char	isdir;
	union {
		struct {
			unsigned long	filesize;
			unsigned short	flag;
			unsigned char	keyindex;
		}f;
		struct {
			unsigned short	flag;
			unsigned char	keyindex;
		}d;
	}u;
	unsigned char	packindex;
	unsigned long	offest;
	unsigned long	contentsize;
};

struct PackFile {
	FILE			*file;
	unsigned long	version;
	std::mutex		*mutex;
	PackFile():
		file(nullptr),
		version(0),
		mutex(nullptr){}
};

typedef std::unordered_map<std::string, int> PackMap;
typedef std::unordered_map<std::string, FileConfig> FileMap;

class CC_DLL FileManager : public FileUtils {
	friend class FileUtils;
protected:
	FileManager();
	~FileManager();
public:
	static FileManager* getInstance();
	/* override functions */
	virtual bool init() override;
	
	bool isNativePath(const std::string &filepath) const;
	std::string removeNativeFlag(const std::string &filepath) const;
	FileUtils* getNativeFileUtils() const { return m_nativeFileUtils; }
	virtual std::string getNativeRootPath() const;

	virtual File* open(const std::string& filename, const std::string &mode) override;
	virtual void addSearchPath(const std::string & path, const bool front = false) override;
	virtual FileUtils::Status getContents(const std::string& filename, ResizableBuffer* buffer) const override;
	virtual unsigned char* getFileDataFromZip(const std::string& zipFilePath, const std::string& filename, ssize_t *size) const override;
	virtual std::string fullPathForFilename(const std::string &filename) const override;
	virtual std::string getWritablePath() const override;
	virtual void setWritablePath(const std::string& writablePath) override;
	virtual bool writeToFile(const ValueMap& dict, const std::string& fullPath) const override;
	virtual bool writeStringToFile(const std::string& dataStr, const std::string& fullPath) const override;
	virtual bool writeDataToFile(const Data& data, const std::string& fullPath) const override;
	virtual bool appendStringToFile(const std::string& dataStr, const std::string& fullPath) const override;
	virtual bool appendDataToFile(const Data& data, const std::string& fullPath) const override;
	virtual bool writeValueMapToFile(const ValueMap& dict, const std::string& fullPath) const override;
	virtual bool writeValueVectorToFile(const ValueVector& vecData, const std::string& fullPath) const override;
	virtual std::string getSuitableFOpen(const std::string& filenameUtf8) const override;
	virtual bool isFileExist(const std::string& filename) const override;
	virtual bool isAbsolutePath(const std::string& strPath) const override;
	virtual bool isDirectoryExist(const std::string& dirPath) const override;
	virtual bool createDirectory(const std::string& dirPath) const override;
	virtual bool removeDirectory(const std::string& dirPath) const override;
	virtual bool removeFile(const std::string &filepath) const override;
	virtual bool renameFile(const std::string &oldfullpath, const std::string &newfullpath) const override;
	virtual long getFileSize(const std::string &filepath) const override;
	virtual std::vector<std::string> listFiles(const std::string& dirPath) const override;
	virtual void listFilesRecursively(const std::string& dirPath, std::vector<std::string> *files) const override;

	static std::string getFileName(const std::string &filepath);
	static std::string getPackName(const std::string &packpath);
	static std::string getFileDirectory(const std::string &filepath);

	virtual bool loadFilePack(const std::string& packPath);
	virtual void releaseFilePack(const std::string& packName);
	virtual unsigned long getPackVersion(const std::string& packName);
	virtual unsigned long lookPackVersion(const std::string& packPath);

protected:
	virtual bool isFileExistInternal(const std::string& strPath) const override;
	virtual bool isDirectoryExistInternal(const std::string& dirPath) const override;

	std::string _removeNativeFlag(const std::string &filepath) const;
	const FileConfig* getMapFileInternal(const std::string& strPath) const;
	int getEmptyFileIndex();
	bool readPackData(const PackFile &pack, unsigned long	offest, void *buff, size_t size) const;
	void closePackFile(PackFile &pack);
	bool setFilePack(const std::string &pname, int pindex, FILE *pfile);
	void unsetFilePack(const std::string &pname);
	bool setupPackFile(int pindex, FILE *pfile);
	void deletePackFile(int pindex);
private:
	static FileManager		*g_instance;
	FileUtils				*m_nativeFileUtils;
	PackMap					m_packMap;
	std::vector<PackFile>	m_packFiles;
	FileMap					m_fileMap;
};

}

#endif //!__FILEMANAGER_20181214220759_H
