/**
 *	@file	TMXTileSet.cpp
 *	@date	2018/02/04
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	瓦片集合
 */

#include "TMXTileSet.h"
#include "LUtils.h"

L::TMXTileAnime::TMXTileAnime():
	_curFrame(0),
	_frameTime(0),
	_frameSprite(nullptr)
{}

L::TMXTileAnime::~TMXTileAnime() {
	CC_SAFE_RELEASE(_frameSprite);
	CCLOGINFO("deallocing TMXTileAnime: %p", this);
}

void L::TMXTileAnime::parseAnime(TMXTileSet *tileset, xml_node<> *node, int firstGid){
	CCASSERT(tileset && node && !strcmp(node->name(),"animation"), "TMXTileAnimation: invalid node");

	_tileset = tileset;
	for (xml_node<> *framenode = node->first_node("frame"); framenode;
		framenode = framenode->next_sibling("frame")) {
		_frames.emplace_back(std::make_tuple(
			std::atoi(framenode->first_attribute("tileid")->value()) + firstGid,
			std::atoi(framenode->first_attribute("duration")->value())));
	}
}

void L::TMXTileAnime::prepareAnime(const Vec2 &pos) {
	if (!_frameSprite){
		_frameSprite = Sprite::createWithTexture(_tileset->getTexture());
		_frameSprite->setAnchorPoint(Vec2::ZERO);
		_frameSprite->setPosition(pos);
		CC_SAFE_RETAIN(_frameSprite);
		setAnimeFrame(_curFrame);
	}
}

void L::TMXTileAnime::setAnimeFrame(int index) {
	int tileid = std::get<0>(_frames[index]);
	_frameSprite->setTextureRect(_tileset->getOriginRect(tileid));
}

bool L::TMXTileAnime::update(float dt) {
	_frameTime += int(dt * 1000);
	if (_frameTime >= std::get<1>(_frames[_curFrame])) {
		_frameTime = 0;
		_curFrame++;
		if (_curFrame >= (int)_frames.size()) {
			_curFrame = 0;
		}
		setAnimeFrame(_curFrame);
		return true;
	}
	return false;
}

//---------------------------------------------

L::TMXTileSet::TMXTileSet():
	_offset(Vec2::ZERO),
	_tileSize(Size::ZERO),
	_spacing(0),
	_margin(0),
	_imageSize(Size::ZERO),
	_firstGid(0),
	_tileCount(0),
	_texture(nullptr),
	_animeCache(nullptr),
	_animeDirty(true)
{}

L::TMXTileSet::~TMXTileSet(){
	CC_SAFE_RELEASE(_animeCache);
	CC_SAFE_RELEASE(_texture);
	CCLOGINFO("deallocing TMXTileSet: %p", this);
}

// 解析瓦片集合
void L::TMXTileSet::parseTileSet(xml_node<> *node, const std::string &respath, int firstGid){
	CCASSERT(node && !strcmp(node->name(), "tileset"), "TMXTileSet: invalid node");

	_firstGid = firstGid;
	{
		xml_attribute<> *attr = nullptr;
		attr = node->first_attribute("name");
		if (attr) {
			_name = attr->value();
		}
		attr = node->first_attribute("spacing");
		if (attr) {
			_spacing = std::atoi(attr->value());
		}
		attr = node->first_attribute("margin");
		if (attr) {
			_margin = std::atoi(attr->value());
		}
		attr = node->first_attribute("tilewidth");
		if (attr) {
			_tileSize.width = std::atof(attr->value());
		}
		attr = node->first_attribute("tileheight");
		if (attr) {
			_tileSize.height = std::atof(attr->value());
		}
		attr = node->first_attribute("tilecount");
		if (attr) {
			_tileCount = std::atoi(attr->value());
		}
	}
	
	xml_node<> *offestnode = node->first_node("tileoffset");
	if (offestnode) {
		xml_attribute<> *attr = nullptr;
		attr = offestnode->first_attribute("x");
		if (attr) {
			_offset.x = std::atof(attr->value());
		}
		attr = offestnode->first_attribute("y");
		if (attr) {
			_offset.y = std::atof(attr->value());
		}
	}
	
	xml_node<> *imagenode = node->first_node("image");
	if (imagenode){
		xml_attribute<> *attr = nullptr;
		attr = imagenode->first_attribute("source");
		if (attr) {
			_sourceImage = standardPath(respath + (respath.size() ? "/" : "") + attr->value());
		}
		attr = imagenode->first_attribute("width");
		if (attr) {
			_imageSize.width = std::atof(attr->value());
		}
		attr = imagenode->first_attribute("height");
		if (attr) {
			_imageSize.height = std::atof(attr->value());
		}
	}

	for (xml_node<> *tilenode = node->first_node("tile"); tilenode;
		tilenode = tilenode->next_sibling("tile")) {
		int gid = firstGid + std::atoi(tilenode->first_attribute("id")->value());

		// 属性
		xml_node<> *propertiesnode = tilenode->first_node("properties");
		if (propertiesnode) {
			for (xml_node<> *propnode = propertiesnode->first_node("property"); propnode;
				propnode = propnode->next_sibling("property")) {
				_propsmap[gid][propnode->first_attribute("name")->value()] =
					propnode->first_attribute("value")->value();
			}
		}
		
		// 动画
		xml_node<> *animationnode = tilenode->first_node("animation");
		if (animationnode){
			_animesmap[gid].parseAnime(this,animationnode, firstGid);
		}
	}
}

Rect L::TMXTileSet::getRect(uint32_t gid) {
	Rect rect;
	rect.size = _tileSize;
	gid = gid - _firstGid;
	// max_x means the column count in tile map
	// in the origin:
	// max_x = (int)((_imageSize.width - _margin*2 + _spacing) / (_tileSize.width + _spacing));
	// but in editor "Tiled", _margin variable only effect the left side
	// for compatible with "Tiled", change the max_x calculation
	int max_x = (int)((_imageSize.width - _margin + _spacing) / (_tileSize.width + _spacing));

	rect.origin.x = (gid % max_x) * (_tileSize.width + _spacing) + _margin;
	rect.origin.y = (gid / max_x) * (_tileSize.height + _spacing) + _margin;
	return rect;
}

Rect L::TMXTileSet::getOriginRect(uint32_t gid) {
	Rect rect;
	gid = gid - _firstGid;
	// max_x means the column count in tile map
	// in the origin:
	// max_x = (int)((_imageSize.width - _margin*2 + _spacing) / (_tileSize.width + _spacing));
	// but in editor "Tiled", _margin variable only effect the left side
	// for compatible with "Tiled", change the max_x calculation
	int max_x = (int)((_imageSize.width - _margin + _spacing) / (_tileSize.width + _spacing));

	rect.origin.x = (gid % max_x) * (_tileSize.width + _spacing);
	rect.origin.y = (gid / max_x) * (_tileSize.height + _spacing);
	rect.size.width = _tileSize.width + 2 * _margin;
	rect.size.height = _tileSize.height + 2 * _margin;
	return rect;
}

Texture2D* L::TMXTileSet::getTexture() {
	if (_texture == nullptr) {
		_texture = Director::getInstance()->getTextureCache()->
			addImage(_sourceImage);
		CC_SAFE_RETAIN(_texture);
	}
	return _texture;
}

void L::TMXTileSet::initAnimes() {
	if (!_animeCache){
		int tilewidth = _tileSize.width + 2 * _margin;
		int tileheight = _tileSize.height + 2 * _margin;
		int max_x = _imageSize.width / tilewidth;
		int r_width = _animesmap.size() > max_x ? max_x : _animesmap.size();
		int r_height = (_animesmap.size() + max_x - 1) / max_x;

		_animeCache = RenderTexture::create(r_width * tilewidth, r_height * tileheight);
		CC_SAFE_RETAIN(_animeCache);

		int index = 0;
		for (auto itr = _animesmap.begin(); itr != _animesmap.end(); ++itr, ++index) {
			itr->second.prepareAnime(Vec2((index % r_width)*tilewidth,(index/ r_width)*tileheight));
		}
	}
}

void L::TMXTileSet::updateAnimes(float dt) {
	if (_animeCache){
		for (auto itr = _animesmap.begin(); itr != _animesmap.end(); ++itr) {
			if (itr->second.update(dt)){
				_animeDirty = true;
			}
		}
	}
}

void L::TMXTileSet::renderAnimes() {
	if (_animeCache) {
		if (_animeDirty) {
			_animeDirty = false;
			_animeCache->beginWithClear(0, 0, 0, 0);
			for (auto itr = _animesmap.begin(); itr != _animesmap.end(); ++itr) {
				itr->second.render();
			}
			_animeCache->end();
		}
	}
}

Sprite* L::TMXTileSet::getSprite(int gid, bool *isAnime) {
	if (isAnimeTile(gid)){
		initAnimes();
		if (_animeCache) {
			auto itr = _animesmap.find(gid);
			if (itr != _animesmap.end()) {
				Vec2 pos = itr->second.getAnimePos();
				auto sprite = _animeCache->createSprite();
				sprite->setFlippedY(true);
				sprite->setTextureRect(cocos2d::Rect(pos.x + _margin, pos.y + _margin, _tileSize.width, _tileSize.height));
				if (isAnime) *isAnime = true;
				return sprite;
			}
		}
	} else {
		if (isAnime) *isAnime = false;
		return Sprite::createWithTexture(getTexture(), getRect(gid));
	}
	return nullptr;
}
