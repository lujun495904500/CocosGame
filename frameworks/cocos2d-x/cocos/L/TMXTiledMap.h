/**
 *	@file	TMXTiledMap.h
 *	@date	2018/01/24
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	实现Tiled编辑的地图
 */

#ifndef __TMXTILEDMAP_20180124231701_H
#define __TMXTILEDMAP_20180124231701_H

#include "base/CCValue.h"
#include "2d/CCNode.h"
#include "external/rapidxml/rapidxml.hpp"
#include "TMXTileSet.h"
#include "TMXLayer.h"
#include "TMXObjectGroup.h"

USING_NS_CC;
using namespace rapidxml;

namespace L {

enum TMXOrientation {
	TMXOrientationOrtho,
	TMXOrientationHex,
	TMXOrientationIso,
	TMXOrientationStaggered,
};

enum TMXStaggerAxis {
	TMXStaggerAxis_X,
	TMXStaggerAxis_Y,
};

enum TMXStaggerIndex {
	TMXStaggerIndex_Odd,
	TMXStaggerIndex_Even,
};

class TMXTileSet;
class TMXLayer;

/** 
 *	@brief TMX地图
 */
class CC_DLL TMXTiledMap : public Node {
public:
	static TMXTiledMap* create(const std::string& tmxFile, bool fillAll = false);

	const Size& getMapSize() const { return _mapSize; }
	const Size& getTileSize() const { return _tileSize; }
	const ValueMap& getProperties() const { return _properties; }
	const Value& getProperty(const std::string &name) { return _properties[name]; }
	int getLayerCount() const { return _layerCount; }
	int getOrientation() const { return _orientation; }
	int getStaggerAxis() const { return _staggerAxis; }
	int getStaggerIndex() const { return _staggerIndex; }
	int getHexSideLength() const { return _hexSideLength; }
	const Vector<TMXTileSet*>& getTileSets() const { return _tileSets; }
	const Vector<TMXLayer*>& getLayers() const { return _layers; }
	const Vector<TMXObjectGroup*>& getObjectGroups() const { return _objectGroups; }
	TMXTileSet* getTileSet(const std::string &name) const;
	TMXLayer* getLayer(const std::string &name) const;
	TMXObjectGroup* getTMXObjectGroup(const std::string &name) const;
	void showRegion(const Rect &region);

	virtual void visit(Renderer *renderer, const Mat4& parentTransform, uint32_t parentFlags) override;

protected:
	TMXTiledMap(bool antiAlias = false);
	virtual ~TMXTiledMap();

	bool initWithTMXFile(const std::string& tmxFile);
	void parseTiledMap(xml_node<> *node);
	TMXTiledMap* build();
	TMXTileSet* serachTileSet(TMXLayer *layer);

	bool isAnimesValid();
	void updateAnimes(float dt);
	void renderAnimes();

protected:
	bool			_fillAll;
	Rect			_tilesRect;

	Size			_mapSize;
	Size			_tileSize;
	Size			_size;
	ValueMap		_properties;
	std::string		_tmxFile;
	std::string		_resPath;
	int				_layerCount;

	TMXOrientation	_orientation;
	TMXStaggerAxis  _staggerAxis;
	TMXStaggerIndex _staggerIndex;
	int				_hexSideLength;

	Vector<TMXTileSet*>		_tileSets;
	Vector<TMXLayer*>		_layers;
	Vector<TMXObjectGroup*>	_objectGroups;

private:
	CC_DISALLOW_COPY_AND_ASSIGN(TMXTiledMap);
};

}

#endif //!__TMXTILEDMAP_20180124231701_H
