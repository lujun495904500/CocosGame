/**
 *	@file	TMXLayer.cpp
 *	@date	2018/02/04
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	TMX地图层
 */

#include "base/CCDirector.h"
#include "TMXLayer.h"
#include "2d/CCSprite.h"
#include "renderer/CCTextureCache.h"

USING_NS_CC;

L::TMXLayer::TMXLayer():
	_order(0),
	_layerSize(Size::ZERO),
	_visible(true),
	_opacity(255),
	_offset(Vec2::ZERO),
	_tileset(nullptr),
	_mapTileSize(Size::ZERO),
	_layerOrientation(TMXOrientationOrtho),
	_staggerAxis(TMXStaggerAxis_Y), 
	_staggerIndex(TMXStaggerIndex_Even), 
	_hexSideLength(0),
	_tilesLayer(nullptr),
	_animesLayer(nullptr)
{}

L::TMXLayer::~TMXLayer(){
	CC_SAFE_RELEASE(_tileset);

	CCLOGINFO("deallocing TMXLayer: %p", this);
}

bool L::TMXLayer::parseLayer(xml_node<> *node) {
	CCASSERT(node && !strcmp(node->name(), "layer"), "TMXLayer: invalid node");

	{
		xml_attribute<> *attr = nullptr;
		attr = node->first_attribute("name");
		if (attr) {
			_name = attr->value();
		}
		attr = node->first_attribute("width");
		if (attr) {
			_layerSize.width = std::atof(attr->value());
		}
		attr = node->first_attribute("height");
		if (attr) {
			_layerSize.height = std::atof(attr->value());
		}
		attr = node->first_attribute("visible");
		if (attr) {
			_visible = std::atoi(attr->value()) != 0;
		}
		attr = node->first_attribute("opacity");
		if (attr) {
			_opacity = (unsigned char)(255.0f * std::atof(attr->value()));
		}
		attr = node->first_attribute("offsetx");
		if (attr) {
			_offset.x = std::atof(attr->value());
		}
		attr = node->first_attribute("offsety");
		if (attr) {
			_offset.y = -std::atof(attr->value());
		}
	}

	// 属性
	xml_node<> *propsnode = node->first_node("properties");
	if (propsnode) {
		for (xml_node<> *prop = propsnode->first_node("property"); prop;
			prop = prop->next_sibling("property")) {
			_properties.emplace(prop->first_attribute("name")->value(),
				prop->first_attribute("value")->value());
		}
	}

	// 瓦片数据
	xml_node<> *datanode = node->first_node("data");
	if (datanode){
		_tiles.reserve(_layerSize.width * _layerSize.height);
		for (xml_node<> *tilenode = datanode->first_node("tile"); tilenode;
			tilenode = tilenode->next_sibling("tile")) {
			_tiles.push_back(std::atoi(tilenode->first_attribute("gid")->value()));
		}
	}

	const Value &zorder = _properties["zorder"];
	if (zorder.getType() == Value::Type::STRING){
		_order = zorder.asInt();
	}

	return true;
}

Layer* L::TMXLayer::getTilesLayer(bool create) {
	if (_tilesLayer == nullptr && create){
		_tilesLayer = Layer::create();
		addChild(_tilesLayer);
	}
	return _tilesLayer;
}

Layer* L::TMXLayer::getAnimesLayer(bool create) {
	if (_animesLayer == nullptr && create) {
		_animesLayer = Layer::create();
		addChild(_animesLayer,10);
	}
	return _animesLayer;
}

L::TMXLayer* L::TMXLayer::build(TMXTiledMap *tilemap, TMXTileSet *tileset, bool fillAll) {
	// tilesetInfo
	_tileset = tileset;
	CC_SAFE_RETAIN(_tileset);

	// mapInfo
	_mapTileSize = tilemap->getTileSize();
	_layerOrientation = tilemap->getOrientation();
	_staggerAxis = tilemap->getStaggerAxis();
	_staggerIndex = tilemap->getStaggerIndex();
	_hexSideLength = tilemap->getHexSideLength();

	// offset (after layer orientation is set);
	this->setPosition(CC_POINT_PIXELS_TO_POINTS(calculateLayerOffset(_offset)));

	float width = 0;
	float height = 0;
	if (_layerOrientation == TMXOrientationHex) {
		if (_staggerAxis == TMXStaggerAxis_X) {
			height = _mapTileSize.height * (_layerSize.height + 0.5);
			width = (_mapTileSize.width + _hexSideLength) * ((int)(_layerSize.width / 2)) + _mapTileSize.width * ((int)_layerSize.width % 2);
		} else {
			width = _mapTileSize.width * (_layerSize.width + 0.5);
			height = (_mapTileSize.height + _hexSideLength) * ((int)(_layerSize.height / 2)) + _mapTileSize.height * ((int)_layerSize.height % 2);
		}
	} else {
		width = _layerSize.width * _mapTileSize.width;
		height = _layerSize.height * _mapTileSize.height;
	}
	this->setContentSize(CC_SIZE_PIXELS_TO_POINTS(Size(width, height)));

	setVisible(_visible);

	if(fillAll) setupAllTiles();
		
	return this;
}

void L::TMXLayer::setVisible(bool visible) {
	_visible = visible;
	Node::setVisible(_visible);
}

Vec2 L::TMXLayer::calculateLayerOffset(const Vec2& pos) {
	Vec2 ret;
	switch (_layerOrientation) {
	case TMXOrientationOrtho:
		ret.set(pos.x, pos.y);
		break;
	case TMXOrientationIso:
		ret.set((_mapTileSize.width / 2) * (pos.x - pos.y),
			(_mapTileSize.height / 2) * (-pos.x - pos.y));
		break;
	case TMXOrientationHex:
	{
		if (_staggerAxis == TMXStaggerAxis_Y) {
			int diffX = (_staggerIndex == TMXStaggerIndex_Even) ? _mapTileSize.width / 2 : 0;
			ret.set(pos.x * _mapTileSize.width + diffX, -pos.y * (_mapTileSize.height - (_mapTileSize.width - _hexSideLength) / 2));
		} else if (_staggerAxis == TMXStaggerAxis_X) {
			int diffY = (_staggerIndex == TMXStaggerIndex_Odd) ? _mapTileSize.height / 2 : 0;
			ret.set(pos.x * (_mapTileSize.width - (_mapTileSize.width - _hexSideLength) / 2), -pos.y * _mapTileSize.height + diffY);
		}
		break;
	}
	case TMXOrientationStaggered:
	{
		float diffX = 0;
		if ((int)std::abs(pos.y) % 2 == 1) {
			diffX = _mapTileSize.width / 2;
		}
		ret.set(pos.x * _mapTileSize.width + diffX,
			(-pos.y) * _mapTileSize.height / 2);
	}
	break;
	}
	return ret;
}

void L::TMXLayer::setupAllTiles() {
	for (int y = 0; y < _layerSize.height; y++) {
		for (int x = 0; x < _layerSize.width; x++) {
			int newX = x;
			// fix correct render ordering in Hexagonal maps when stagger axis == x
			if (_staggerAxis == TMXStaggerAxis_X && _layerOrientation == TMXOrientationHex) {
				if (_staggerIndex == TMXStaggerIndex_Odd) {
					if (x >= _layerSize.width / 2)
						newX = (x - std::ceil(_layerSize.width / 2)) * 2 + 1;
					else
						newX = x * 2;
				} else {
					// TMXStaggerIndex_Even
					if (x >= static_cast<int>(_layerSize.width / 2))
						newX = (x - static_cast<int>(_layerSize.width / 2)) * 2;
					else
						newX = x * 2 + 1;
				}
			}

			int pos = static_cast<int>(newX + _layerSize.width * y);
			int gid = _tiles[pos];

			// FIXME:: gid == 0 --> empty tile
			if (gid != 0) {
				setupTile(Vec2(newX, y), gid);
			}
		}
	}
}

void L::TMXLayer::updateTileRect(const Rect &rect) {
	// 移除多余
	for (auto itr = _setupmap.begin(); itr!= _setupmap.end();) {
		if (rect.containsPoint(std::get<0>(itr->second))){
			++itr;
		} else {
			itr = deleteTile(itr);
		}
	}

	// 添加缺少
	int min_x = rect.getMinX();
	int max_x = rect.getMaxX();
	int min_y = rect.getMinY();
	int max_y = rect.getMaxY();
	for (int y = min_y; y < max_y; ++y) {
		for (int x = min_x; x < max_x; ++x) {
			auto pos = Vec2(x,y);
			intptr_t z = getZForPos(pos);
			if (_setupmap.find(z) == _setupmap.end()){
				setupTile(pos, _tiles[z]);
			}
		}
	}
}

Sprite * L::TMXLayer::setupTile(const Vec2& pos, uint32_t gid) {
	if (gid != 0 && _tileset->containGID(gid)) {
		intptr_t z = getZForPos(pos);
		if (_setupmap.find(z) == _setupmap.end()){
			bool isAnime = false;
			Sprite *sprite = _tileset->getSprite(gid, &isAnime);
			if (sprite){
				sprite->setTag(z);
				sprite->setPosition(getPositionAt(pos));
				sprite->setPositionZ(0.0f);
				sprite->setAnchorPoint(Vec2::ZERO);
				sprite->setOpacity(_opacity);
				if (isAnime) {
					auto animesLayer = getAnimesLayer(true);
					animesLayer->addChild(sprite, z);
				} else {
					auto tilesLayer = getTilesLayer(true);
					tilesLayer->addChild(sprite, z);
				}

				_setupmap.insert(std::make_pair(z, std::make_tuple(pos, sprite)));
				return sprite;
			}
		}
	}
	return nullptr;
}

void L::TMXLayer::deleteTile(const Vec2& pos) {
	CCASSERT(pos.x < _layerSize.width && pos.y < _layerSize.height && pos.x >= 0 && pos.y >= 0, "TMXLayer: invalid position");

	intptr_t z = getZForPos(pos);
	auto setitr = _setupmap.find(z);
	if (setitr != _setupmap.end()){
		deleteTile(setitr);
	}
}

L::SetupMap::iterator L::TMXLayer::deleteTile(L::SetupMap::iterator &itr) {
	std::get<1>(itr->second)->removeFromParent();
	return _setupmap.erase(itr);
}

intptr_t L::TMXLayer::getZForPos(const Vec2& pos) const {
	intptr_t z = -1;
	// fix correct render ordering in Hexagonal maps when stagger axis == x
	if (_staggerAxis == TMXStaggerAxis_X && _layerOrientation == TMXOrientationHex) {
		if (_staggerIndex == TMXStaggerIndex_Odd) {
			if (((int)pos.x % 2) == 0)
				z = pos.x / 2 + pos.y * _layerSize.width;
			else
				z = pos.x / 2 + std::ceil(_layerSize.width / 2) + pos.y * _layerSize.width;
		} else {
			// TMXStaggerIndex_Even
			if (((int)pos.x % 2) == 1)
				z = pos.x / 2 + pos.y * _layerSize.width;
			else
				z = pos.x / 2 + std::floor(_layerSize.width / 2) + pos.y * _layerSize.width;
		}
	} else {
		z = (pos.x + pos.y * _layerSize.width);
	}

	CCASSERT(z != -1, "Invalid Z");
	return z;
}

Vec2 L::TMXLayer::getPositionAt(const Vec2& pos) {
	Vec2 ret;
	switch (_layerOrientation) {
	case TMXOrientationOrtho:
		ret = getPositionForOrthoAt(pos);
		break;
	case TMXOrientationIso:
		ret = getPositionForIsoAt(pos);
		break;
	case TMXOrientationHex:
		ret = getPositionForHexAt(pos);
		break;
	case TMXOrientationStaggered:
		ret = getPositionForStaggeredAt(pos);
		break;
	}
	ret = CC_POINT_PIXELS_TO_POINTS(ret);
	return ret;
}

Vec2 L::TMXLayer::getPositionForOrthoAt(const Vec2& pos) {
	return Vec2(pos.x * _mapTileSize.width,
		(_layerSize.height - pos.y - 1) * _mapTileSize.height);
}

Vec2 L::TMXLayer::getPositionForIsoAt(const Vec2& pos) {
	return Vec2(_mapTileSize.width / 2 * (_layerSize.width + pos.x - pos.y - 1),
		_mapTileSize.height / 2 * ((_layerSize.height * 2 - pos.x - pos.y) - 2));
}

Vec2 L::TMXLayer::getPositionForHexAt(const Vec2& pos) {
	Vec2 xy;
	Vec2 offset = _tileset->getOffest();

	int odd_even = (_staggerIndex == TMXStaggerIndex_Odd) ? 1 : -1;
	switch (_staggerAxis) {
	case TMXStaggerAxis_Y:
	{
		float diffX = 0;
		if ((int)pos.y % 2 == 1) {
			diffX = _mapTileSize.width / 2 * odd_even;
		}
		xy = Vec2(pos.x * _mapTileSize.width + diffX + offset.x,
			(_layerSize.height - pos.y - 1) * (_mapTileSize.height - (_mapTileSize.height - _hexSideLength) / 2) - offset.y);
		break;
	}

	case TMXStaggerAxis_X:
	{
		float diffY = 0;
		if ((int)pos.x % 2 == 1) {
			diffY = _mapTileSize.height / 2 * -odd_even;
		}

		xy = Vec2(pos.x * (_mapTileSize.width - (_mapTileSize.width - _hexSideLength) / 2) + offset.x,
			(_layerSize.height - pos.y - 1) * _mapTileSize.height + diffY - offset.y);
		break;
	}
	}
	return xy;
}

Vec2 L::TMXLayer::getPositionForStaggeredAt(const Vec2 &pos) {
	float diffX = 0;
	if ((int)pos.y % 2 == 1) {
		diffX = _mapTileSize.width / 2;
	}
	return Vec2(pos.x * _mapTileSize.width + diffX,
		(_layerSize.height - pos.y - 1) * _mapTileSize.height / 2);
}
