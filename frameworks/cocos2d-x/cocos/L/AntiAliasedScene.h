/**
 *	@file	AntiAliasedScene.h
 *	@date	2018/03/31
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	反锯齿场景
 */

#ifndef __ANTIALIASEDSCENE_20180331134534_H
#define __ANTIALIASEDSCENE_20180331134534_H

#include "2d/CCScene.h"
#include "2d/CCRenderTexture.h"

USING_NS_CC;

namespace L {

/** 
 *	@brief 反锯齿场景
 */
class CC_DLL AntiAliasedScene : public Scene
{
public:
    static AntiAliasedScene *create();
    static AntiAliasedScene *createWithSize(const Size& size);
	virtual void render(Renderer* renderer, const Mat4* eyeTransforms, const Mat4* eyeProjections, unsigned int multiViewCount);

CC_CONSTRUCTOR_ACCESS:
	AntiAliasedScene();
    virtual ~AntiAliasedScene();

protected:
    
	RenderTexture	*renderCache;
	Sprite			*screenSprite;

private:
    CC_DISALLOW_COPY_AND_ASSIGN(AntiAliasedScene);

#if (CC_USE_PHYSICS || (CC_USE_3D_PHYSICS && CC_ENABLE_BULLET_INTEGRATION))
public:
	static AntiAliasedScene *createWithPhysics();
#endif

};

}

#endif // __ANTIALIASEDSCENE_20180331134534_H
