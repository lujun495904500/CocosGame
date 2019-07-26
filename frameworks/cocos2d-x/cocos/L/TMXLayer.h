/**
 *	@file	TMXLayer.h
 *	@date	2018/02/04
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	ÍßÆ¬µØÍ¼²ã
 */

#ifndef __TMXLAYER_20180204173521_H
#define __TMXLAYER_20180204173521_H

#include <unordered_set>
#include "2d/CCSpriteBatchNode.h"
#include "base/CCValue.h"
#include "2d/CCLayer.h"
#include "math/CCGeometry.h"
#include "base/ccCArray.h"
#include "external/rapidxml/rapidxml.hpp"
#include "TMXTileSet.h"
#include "TMXTiledMap.h"

USING_NS_CC;
using namespace rapidxml;

namespace L {

class TMXTiledMap;
class TMXTileSet;

typedef std::unordered_map<int, std::tuple<Vec2, Sprite*>> SetupMap;

/**
*	@brief TMXµØÍ¼²ã
*/
class CC_DLL TMXLayer : public Node {
public:
	TMXLayer();
	virtual ~TMXLayer();

	// ½âÎöµØÍ¼²ã
	bool parseLayer(xml_node<> *node);
	TMXLayer* build(TMXTiledMap *tilemap, TMXTileSet *tileset, bool fillAll = true);

	const std::string& getName() const { return _name; }
	const Size& getLayerSize() const { return _layerSize; }
	const ValueMap& getProperties() const { return _properties; }
	const Value& getProperty(const std::string &name) { return _properties[name]; }
	const std::vector<int>& getTiles() const { return _tiles; }
	const Size& getTileSize() const { return _mapTileSize; }
	TMXTileSet* getTileSet() { return _tileset; }
	int	getOrder() const { return _order; }
	virtual void setVisible(bool visible) override;
	virtual bool isVisible() const override { return _visible; }

	void updateTileRect(const Rect &rect);

protected:
	Vec2 calculateLayerOffset(const Vec2& pos);
	void setupAllTiles();
	Sprite * setupTile(const Vec2& pos, uint32_t gid);
	void deleteTile(const Vec2& pos);
	SetupMap::iterator deleteTile(SetupMap::iterator &itr);

	intptr_t getZForPos(const Vec2& pos) const;
	Vec2 getPositionAt(const Vec2& pos);

	Vec2 getPositionForOrthoAt(const Vec2& pos);
	Vec2 getPositionForIsoAt(const Vec2& pos);
	Vec2 getPositionForHexAt(const Vec2& pos);
	Vec2 getPositionForStaggeredAt(const Vec2 &pos);
	int getVertexZForPos(const Vec2& pos);
	Layer* getTilesLayer(bool create = false);
	Layer* getAnimesLayer(bool create = false);

	int					_order;
	std::string			_name;
	Size				_layerSize;
	ValueMap			_properties;
	std::vector<int>	_tiles;
	bool                _visible;
	unsigned char       _opacity;
	Vec2				_offset;

	Size				_mapTileSize;
	int					_layerOrientation;
	int					_staggerAxis;
	int					_staggerIndex;
	int					_hexSideLength;

	Layer				*_tilesLayer;
	Layer				*_animesLayer;
	SetupMap			_setupmap;

	TMXTileSet			*_tileset;
};

}

#endif //!__TMXLAYER_20180204173521_H
