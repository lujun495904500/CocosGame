/**
 *	@file	AntiAliasedScene.cpp
 *	@date	2018/03/31
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	·´¾â³Ý³¡¾°
 */

#include "L/AntiAliasedScene.h"
#include "cocos2d.h"
#include "platform/CCGL.h"

namespace L {

AntiAliasedScene* AntiAliasedScene::create() {
	AntiAliasedScene *ret = new (std::nothrow) AntiAliasedScene();
	if (ret && ret->init()) {
		ret->autorelease();
		return ret;
	} else {
		CC_SAFE_DELETE(ret);
		return nullptr;
	}
}

AntiAliasedScene* AntiAliasedScene::createWithSize(const Size& size) {
	AntiAliasedScene *ret = new (std::nothrow) AntiAliasedScene();
	if (ret && ret->initWithSize(size)) {
		ret->autorelease();
		return ret;
	} else {
		CC_SAFE_DELETE(ret);
		return nullptr;
	}
}

#if (CC_USE_PHYSICS || (CC_USE_3D_PHYSICS && CC_ENABLE_BULLET_INTEGRATION))

AntiAliasedScene* AntiAliasedScene::createWithPhysics() {
	AntiAliasedScene *ret = new (std::nothrow) AntiAliasedScene();
	if (ret && ret->initWithPhysics()) {
		ret->autorelease();
		return ret;
	} else {
		CC_SAFE_DELETE(ret);
		return nullptr;
	}
}

#endif

AntiAliasedScene::AntiAliasedScene():
	renderCache(nullptr),
	screenSprite(nullptr)
{
	auto glview = Director::getInstance()->getOpenGLView();

	auto designsize = glview->getDesignResolutionSize();
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
	renderCache = RenderTexture::create(designsize.width, designsize.height, Texture2D::PixelFormat::BGRA8888, CC_GL_DEPTH24_STENCIL8);
#else
	renderCache = RenderTexture::create(designsize.width, designsize.height, Texture2D::PixelFormat::BGRA8888, GL_DEPTH24_STENCIL8_OES);
#endif
	CC_SAFE_RETAIN(renderCache);

	auto texture = renderCache->getSprite()->getTexture();
	texture->setAntiAliasTexParameters();
	screenSprite = Sprite::createWithTexture(texture);
	screenSprite->setFlippedY(true);
	//screenSprite->setAnchorPoint(Vec2(0.5, 0.5));
	screenSprite->setPosition(Vec2(designsize.width/2, designsize.height/2));
	CC_SAFE_RETAIN(screenSprite);
}

AntiAliasedScene::~AntiAliasedScene() {
	CC_SAFE_RELEASE(renderCache);
	CC_SAFE_RELEASE(screenSprite);
}

void AntiAliasedScene::render(Renderer* renderer, const Mat4* eyeTransforms, const Mat4* eyeProjections, unsigned int multiViewCount) {
	renderCache->beginWithClear(0, 0, 0, 1);
	visit();
	renderCache->end();
	screenSprite->visit();
}

}
