/****************************************************************************
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#include "AppDelegate.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "cocos2d.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"
#include "cocos/L/FileManager.h"
#include "cocos/L/LUtils.h"

// #define USE_AUDIO_ENGINE 1
// #define USE_SIMPLE_AUDIO_ENGINE 1

#if USE_AUDIO_ENGINE && USE_SIMPLE_AUDIO_ENGINE
#error "Don't use AudioEngine and SimpleAudioEngine at the same time. Please just select one in your game!"
#endif

#if USE_AUDIO_ENGINE
#include "audio/include/AudioEngine.h"
using namespace cocos2d::experimental;
#elif USE_SIMPLE_AUDIO_ENGINE
#include "audio/include/SimpleAudioEngine.h"
using namespace CocosDenshion;
#endif

/*
 *	init extra lua
 */
void initExtraLua(lua_State* L) {
	LuaStack::initExtraLua(L, { "~/src","src" });
	register_external_module(L);
}

USING_NS_CC;
using namespace std;
using namespace L;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
#if USE_AUDIO_ENGINE
    AudioEngine::end();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::end();
#endif

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    RuntimeEngine::getInstance()->end();
#endif

}

// if you want a different context, modify the value of glContextAttrs
// it will affect all platforms
void AppDelegate::initGLContextAttrs()
{
    // set OpenGL context attributes: red,green,blue,alpha,depth,stencil,multisamplesCount
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8, 0 };

    GLView::setGLContextAttrs(glContextAttrs);
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 60.0f);

    // register lua module
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);

    LuaStack* stack = engine->getLuaStack();
    //stack->setXXTEAKeyAndSign("2dxLua", strlen("2dxLua"), "XXTEA", strlen("XXTEA"));
	stack->addSearchPath("~/src");
	stack->addSearchPath("src");
#if CC_64BITS
	stack->addSearchPath("~/64bit/src");
	stack->addSearchPath("64bit/src");
#endif

    //register custom function
    //LuaStack* stack = engine->getLuaStack();
    //register_custom_function(stack->getLuaState());
    
	FileUtils::getInstance()->addSearchPath("src");
#if CC_64BITS
	FileUtils::getInstance()->addSearchPath("64bit/src");
#endif
    FileUtils::getInstance()->addSearchPath("res");

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID 
	FileManager::getInstance()->loadFilePack(FileUtils::getInstance()->getWritablePath() + "boot.pack");
#else
	FileManager::getInstance()->loadFilePack("boot.pack");
#endif
	
	/*
	std::string test = "LUJUN";
	std::string encdata;
	std::string decdata;
	L::RSA_privateEncrypt((const unsigned char*)test.c_str(),test.size(), encdata, "res/secrets/rsa/private_key_pkcs8.pem");
	L::RSA_publicDecrypt((const unsigned char*)encdata.c_str(), encdata.size(), decdata, "res/secrets/rsa/public_key.pem");
	CCLOG("%s", decdata.c_str());
	*/

	/*
	std::string key = "\x16\xC3\xE8\x23\x08\xE9\x05\xEF\x53\xFA\x82\xCC\x1B\x14\xFD\x90";
	std::string iv = "\x44\xB9\x3E\x5B\x97\xBE\xDA\xFF\x82\xF5\x54\x54\xFE\xC6\x3A\x0F";
	std::string test = "1234567890123456";
	std::string encdata(32, 0);
	std::string decdata(32, 0);
	size_t bufsize = 32;
	L::AES_encrypt((const unsigned char *)key.c_str(), (const unsigned char *)iv.c_str(), (const unsigned char *)test.c_str(),test.size(), (unsigned char *)encdata.c_str(), bufsize);
	encdata.resize(bufsize);
	bufsize = 32;
	L::AES_decrypt((const unsigned char *)key.c_str(), (const unsigned char *)iv.c_str(), (const unsigned char *)encdata.c_str(), encdata.size(), (unsigned char *)decdata.c_str(), bufsize);
	decdata.resize(bufsize);
	CCLOG("%s", decdata.c_str());
	*/

	/*
	const char *test = "zlib compress and uncompress test\nturingo@163.com\n2012-11-05\n";
	std::string cmpdata;
	std::string uncdata;
	size_t tlen = strlen(test) + 1;
	L::Zlib_compress(test, tlen, cmpdata);
	L::Zlib_uncompress(cmpdata.c_str(), cmpdata.size(), tlen, uncdata);
	CCLOG("%s", uncdata.c_str());
	*/
	
    if (engine->executeScriptFile("boot.lua"))
    {
        return false;
    }
	
    return true;
}

// This function will be called when the app is inactive. Note, when receiving a phone call it is invoked.
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

#if USE_AUDIO_ENGINE
    AudioEngine::pauseAll();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    SimpleAudioEngine::getInstance()->pauseAllEffects();
#endif
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

#if USE_AUDIO_ENGINE
    AudioEngine::resumeAll();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    SimpleAudioEngine::getInstance()->resumeAllEffects();
#endif
}
