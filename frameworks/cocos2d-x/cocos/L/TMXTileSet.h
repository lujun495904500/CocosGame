/**
 *	@file	TMXTileSet.h
 *	@date	2018/02/04
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	TMX 瓦片集
 */

#ifndef __TMXTILESET_20180204015130_H
#define __TMXTILESET_20180204015130_H

#include <tuple>
#include "base/CCRef.h"
#include "base/CCValue.h"
#include "2d/CCRenderTexture.h"
#include "math/CCGeometry.h"
#include "external/rapidxml/rapidxml.hpp"
#include "TMXLayer.h"

USING_NS_CC;
using namespace rapidxml;

namespace L {

class TMXLayer;
class TMXTileSet;

typedef std::vector<std::tuple<int, int>>	GIDAnimeFrames;

/** 
 *	@brief TMX 动画
 */
class CC_DLL TMXTileAnime {
public:
	TMXTileAnime();
	virtual ~TMXTileAnime();

	// 解析瓦片动画
	void parseAnime(TMXTileSet *tileset,xml_node<> *node, int firstGid = 1);
	void prepareAnime(const Vec2 &pos);
	Vec2 getAnimePos() const { return _frameSprite->getPosition(); }

	void setAnimeFrame(int index);
	bool update(float dt);
	void render() const { _frameSprite->visit(); }

protected:
	TMXTileSet		*_tileset;
	Sprite			*_frameSprite;
	GIDAnimeFrames	_frames;
	int				_curFrame;
	int				_frameTime;
};

typedef std::unordered_map<int, TMXTileAnime> GIDAnimesMap;
typedef std::unordered_map<int, ValueMap> GIDPropsMap;

/**
*	@brief TMX瓦片集合
*/
class CC_DLL TMXTileSet : public Ref {
public:
	TMXTileSet();
	virtual ~TMXTileSet();

	// 解析瓦片集合
	void parseTileSet(xml_node<> *node, const std::string &respath = "", int firstGid = 1);

	bool containGID(int gid) const {
		return (gid >= _firstGid) && (gid < _firstGid + _tileCount);
	}
	
	const std::string& getSourceImage() const{
		return _sourceImage;
	}
	Rect getOriginRect(uint32_t gid);
	Rect getRect(uint32_t gid);
	Vec2 getOffest() const {
		return _offset;
	}
	bool isAnimesValid() const { return !_animesmap.empty(); }
	void updateAnimes(float dt);
	void renderAnimes();
	
	const std::string& getName() const { return _name; }
	const Size& getTileSize() const { return _tileSize; }
	int getMargin() const { return _margin; }
	int getSpacing() const { return _spacing; }
	const std::string& getSourceImage() { return _sourceImage; }
	const Size& getImageSize() const { return _imageSize; }
	const ValueMap& getProperties(int gid) { return _propsmap[gid]; }
	const Value& getProperty(int gid, const std::string &name) { return _propsmap[gid][name];}
	bool isAnimeTile(int gid) { return _animesmap.find(gid) != _animesmap.end(); }
	Sprite* getSprite(int gid, bool *isAnime = nullptr);
	Texture2D* getTexture();

protected:
	void initAnimes();
	
	std::string		_name;
	Vec2            _offset;
	Size            _tileSize;
	int             _spacing;
	int             _margin;
	std::string     _sourceImage;
	Size            _imageSize;

	int				_firstGid;
	int				_tileCount;

	Texture2D		*_texture;
	GIDPropsMap		_propsmap;

	GIDAnimesMap	_animesmap;
	RenderTexture	*_animeCache;
	bool			_animeDirty;
};

}

#endif //!__TMXTILESET_20180204015130_H
