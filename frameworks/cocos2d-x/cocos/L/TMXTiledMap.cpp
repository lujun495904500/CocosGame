/**
 *	@file	TMXTiledMap.cpp
 *	@date	2018/01/24
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	实现Tiled编辑的地图
 */

#include "TMXTiledMap.h"
#include "platform/CCFileUtils.h"

L::TMXTiledMap* L::TMXTiledMap::create(const std::string& tmxFile, bool fillTiles) {
	TMXTiledMap *ret = new (std::nothrow) TMXTiledMap(fillTiles);
	if (ret->initWithTMXFile(tmxFile)) {
		ret->autorelease();
		return ret;
	}
	CC_SAFE_DELETE(ret);
	return nullptr;
}

L::TMXTiledMap::TMXTiledMap(bool fillAll):
	_fillAll(fillAll),
	_tilesRect(Rect::ZERO),
	_mapSize(Size::ZERO),
	_tileSize(Size::ZERO),
	_size(Size::ZERO),
	_orientation(TMXOrientationOrtho),
	_staggerAxis(TMXStaggerAxis_Y),
	_staggerIndex(TMXStaggerIndex_Even),
	_layerCount(0)
{}

L::TMXTiledMap::~TMXTiledMap(){
	unschedule(schedule_selector(L::TMXTiledMap::updateAnimes));
	CCLOGINFO("deallocing TMXTiledMap: %p", this);
}

bool L::TMXTiledMap::initWithTMXFile(const std::string& tmxFile) {
	CCASSERT(tmxFile.size() > 0, "TMXTiledMap: tmx file should not be empty");

	_tmxFile = FileUtils::getInstance()->fullPathForFilename(tmxFile);
	if (_tmxFile.find_last_of("/") != std::string::npos) {
		_resPath = _tmxFile.substr(0, _tmxFile.find_last_of("/") + 1);
	}
	setContentSize(Size::ZERO);

	xml_document<> tmxDoc;
	Data data = FileUtils::getInstance()->getDataFromFile(_tmxFile);
	tmxDoc.parse<0>((char*)data.getBytes(), (int)data.getSize());
	parseTiledMap(tmxDoc.first_node());

	if (build() == nullptr) {
		return false;
	}

	// 开启动画计时器
	if (isAnimesValid()) {
		schedule(schedule_selector(L::TMXTiledMap::updateAnimes), 0.1f);
	}

	return true;
}

bool L::TMXTiledMap::isAnimesValid() {
	for (auto& tileset : _tileSets) {
		if (tileset->isAnimesValid()) return true;
	}
	return false;
}

void L::TMXTiledMap::updateAnimes(float dt) {
	for (auto& tileset : _tileSets) {
		tileset->updateAnimes(dt);
	}
}

void L::TMXTiledMap::renderAnimes() {
	for (auto& tileset : _tileSets) {
		tileset->renderAnimes();
	}
}

void L::TMXTiledMap::parseTiledMap(xml_node<> *node) {
	CCASSERT(node && !strcmp(node->name(), "map"), "TMXTiledMap: invalid node");

	{
		xml_attribute<> *attr = nullptr;
		attr = node->first_attribute("version");
		if (attr) {
			if (strcmp(attr->value(),"1.0")){
				CCLOG("cocos2d: TMXFormat: Unsupported TMX version: %s", attr->value());
			}
		}
		attr = node->first_attribute("orientation");
		if (attr) {
			const char *orientation = attr->value();
			if (!strcmp(orientation,"orthogonal")){
				_orientation = TMXOrientationOrtho;
			}
			else if (!strcmp(orientation, "isometric")) {
				_orientation = TMXOrientationIso;
			}
			else if (!strcmp(orientation, "hexagonal")) {
				_orientation = TMXOrientationHex;
			}
			else if (!strcmp(orientation, "staggered")) {
				_orientation = TMXOrientationStaggered;
			}
			else {
				CCLOG("cocos2d: TMXFomat: Unsupported orientation: %s", orientation);
			}
		}
		attr = node->first_attribute("staggeraxis");
		if (attr) {
			const char *staggeraxis = attr->value();
			if (!strcmp(staggeraxis, "x")) {
				_staggerAxis = TMXStaggerAxis_X;
			} else if (!strcmp(staggeraxis, "y")) {
				_staggerAxis = TMXStaggerAxis_Y;
			}
		}
		attr = node->first_attribute("staggerindex");
		if (attr) {
			const char *staggerindex = attr->value();
			if (!strcmp(staggerindex, "odd")) {
				_staggerIndex = TMXStaggerIndex_Odd;
			} else if (!strcmp(staggerindex, "even")) {
				_staggerIndex = TMXStaggerIndex_Even;
			}
		}
		attr = node->first_attribute("hexsidelength");
		if (attr) {
			_hexSideLength = std::atoi(attr->value());
		}
		attr = node->first_attribute("width");
		if (attr) {
			_mapSize.width = std::atof(attr->value());
		}
		attr = node->first_attribute("height");
		if (attr) {
			_mapSize.height = std::atof(attr->value());
		}
		attr = node->first_attribute("tilewidth");
		if (attr) {
			_tileSize.width = std::atof(attr->value());
		}
		attr = node->first_attribute("tilewidth");
		if (attr) {
			_tileSize.height = std::atof(attr->value());
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

	// 瓦片集合
	for (xml_node<> *tilesetnode = node->first_node("tileset"); tilesetnode;
		tilesetnode = tilesetnode->next_sibling("tileset")) {
		xml_attribute<> *fgidattr = tilesetnode->first_attribute("firstgid");
		int firstgid = fgidattr ? std::atoi(fgidattr->value()) : 1;

		std::string source = tilesetnode->first_attribute("source")->value();
		if (_resPath.size() > 0) {
			source = _resPath + source;
		}

		xml_document<> tsxDoc;
		Data data = FileUtils::getInstance()->getDataFromFile(source);
		tsxDoc.parse<0>((char*)data.getBytes(), (int)data.getSize());

		TMXTileSet * tileset = new (std::nothrow) TMXTileSet();
		tileset->parseTileSet(tsxDoc.first_node(), _resPath, firstgid);
		_tileSets.pushBack(tileset);
		tileset->release();
	}

	// 地图层
	for (xml_node<> *layernode = node->first_node("layer"); layernode;
		layernode = layernode->next_sibling("layer")) {
		TMXLayer *layer = new (std::nothrow) TMXLayer();
		layer->parseLayer(layernode);
		_layers.pushBack(layer);
		layer->release();
	}

	// 对象组
	for (xml_node<> *objgrpnode = node->first_node("objectgroup"); objgrpnode;
		objgrpnode = objgrpnode->next_sibling("objectgroup")) {
		TMXObjectGroup *objgrp = new (std::nothrow) TMXObjectGroup();
		objgrp->parseObjectGroup(objgrpnode);
		_objectGroups.pushBack(objgrp);
		objgrp->release();
	}
}

L::TMXTiledMap* L::TMXTiledMap::build() {
	_size.width = _mapSize.width * _tileSize.width;
	_size.height = _mapSize.height * _tileSize.height;

	for (auto &layer : _layers) {
		TMXTileSet *tileset = serachTileSet(layer);
		TMXLayer *child = layer->build(this, tileset, _fillAll);
		if (child == nullptr)  continue;

		addChild(child, child->getOrder());
		// update content size with the max size
		const Size& childSize = child->getContentSize();
		Size currentSize = this->getContentSize();
		currentSize.width = std::max(currentSize.width, childSize.width);
		currentSize.height = std::max(currentSize.height, childSize.height);
		this->setContentSize(currentSize);
	}
	return this;
}

void L::TMXTiledMap::showRegion(const Rect &region) {
	if (!_fillAll){
		int minX = region.getMinX() - _tileSize.width;
		int minY = region.getMinY() - _tileSize.height;
		int maxX = region.getMaxX() + _tileSize.width;
		int maxY = region.getMaxY() + _tileSize.height;
		if (minX < 0) minX = 0;
		if (minY < 0) minY = 0;
		if (maxX > _size.width) maxX = _size.width;
		if (maxY > _size.height) maxY = _size.height;
		Rect srect(minX / _tileSize.width,
			(_size.height - maxY)/ _tileSize.height,
			(maxX - minX) / _tileSize.width,
			(maxY - minY) / _tileSize.height);

		if (!_tilesRect.containsRect(srect)){
			minX = srect.getMinX() - srect.size.width / 4;
			minY = srect.getMinY() - srect.size.height / 4;
			maxX = srect.getMaxX() + srect.size.width / 4;
			maxY = srect.getMaxY() + srect.size.height / 4;
			if (minX < 0) minX = 0;
			if (minY < 0) minY = 0;
			if (maxX > _mapSize.width) maxX = _mapSize.width;
			if (maxY > _mapSize.height) maxY = _mapSize.height;
			Rect trect(minX, minY, maxX - minX, maxY - minY);

			for (auto &layer : _layers) {
				layer->updateTileRect(trect);
			}
			_tilesRect = trect;
			//CCLOG("update tiles rect (%f,%f,%f,%f)", trect.origin.x, trect.origin.y,trect.size.width, trect.size.height);
		}
	}
}

L::TMXTileSet* L::TMXTiledMap::serachTileSet(L::TMXLayer *layer) {
	for (auto tileset : _tileSets) {
		for (auto gid : layer->getTiles()) {
			if (gid != 0 && tileset->containGID(gid)) {
				return tileset;
			}
		}
	}
	return nullptr;
}

L::TMXTileSet* L::TMXTiledMap::getTileSet(const std::string &name) const {
	for (auto itr = _tileSets.begin(); itr != _tileSets.end();++ itr) {
		if ((*itr)->getName() == name) return *itr;
	}
	return nullptr;
}

L::TMXLayer* L::TMXTiledMap::getLayer(const std::string &name) const {
	for (auto itr = _layers.begin(); itr != _layers.end(); ++itr) {
		if ((*itr)->getName() == name) return *itr;
	}
	return nullptr;
}

L::TMXObjectGroup* L::TMXTiledMap::getTMXObjectGroup(const std::string &name) const {
	for (auto itr = _objectGroups.begin(); itr != _objectGroups.end(); ++itr) {
		if ((*itr)->getName() == name) return *itr;
	}
	return nullptr;
}

void L::TMXTiledMap::visit(Renderer *renderer, const Mat4& parentTransform, uint32_t parentFlags) {
	renderAnimes();
	Node::visit(renderer, parentTransform, parentFlags);
}
