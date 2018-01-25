#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "lua_module_register.h"
#include "MobClickCpp.h"

// extra lua module
#include "cocos2dx_extra.h"
#include "lua_extensions/lua_extensions_more.h"
#include "luabinding/lua_cocos2dx_extension_filter_auto.hpp"
#include "luabinding/lua_cocos2dx_extension_nanovg_auto.hpp"
#include "luabinding/lua_cocos2dx_extension_nanovg_manual.hpp"
#include "luabinding/cocos2dx_extra_luabinding.h"
#include "luabinding/HelperFunc_luabinding.h"
#include "umeng/umeng_lua_binding.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "luabinding/cocos2dx_extra_ios_iap_luabinding.h"
#endif

using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

static void quick_module_register(lua_State *L)
{
    luaopen_lua_extensions_more(L);

    lua_getglobal(L, "_G");
    if (lua_istable(L, -1))//stack:...,_G,
    {
        register_all_quick_manual(L);
        // extra
        luaopen_cocos2dx_extra_luabinding(L);
        register_all_cocos2dx_extension_filter(L);
        register_all_cocos2dx_extension_nanovg(L);
        register_all_cocos2dx_extension_nanovg_manual(L);
        luaopen_HelperFunc_luabinding(L);
        lua_register_mobclick_module(L);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        luaopen_cocos2dx_extra_ios_iap_luabinding(L);
#endif
    }
    lua_pop(L, 1);
}

//
AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = { 8, 8, 8, 8, 24, 8 };

    GLView::setGLContextAttrs(glContextAttrs);
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director
    auto director = Director::getInstance();
    director->setProjection(Director::Projection::_2D);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    MOBCLICKCPP_START_WITH_APPKEY_AND_CHANNEL("55c1c89667e58e6b6e001118", "AppStore");
#endif
    auto glview = director->getOpenGLView();    
    if(!glview) {
        string title = "pokdeng";
        glview = cocos2d::GLViewImpl::create(title.c_str());
        director->setOpenGLView(glview);
        director->startAnimation();
    }
   
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);

    // use Quick-Cocos2d-X
    quick_module_register(L);

    LuaStack* stack = engine->getLuaStack();
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	// load framework
	
#ifdef CC_TARGET_OS_IPHONE
    if (sizeof(long) == 4) {
        stack->loadChunksFromZIP("res/framework_precompiled.zip");
    } else {
        stack->loadChunksFromZIP("res/framework_precompiled64.zip");
    }
#else
    stack->loadChunksFromZIP("res/framework_precompiled.zip");
#endif
#endif

    int x=0;
    char y[14];
    char *z = y;
    *(z++)=0x50;         //P  50
    *(z++)=y[x++]+0x1F;  //o  6F
    *(z++)=y[x++]-0x04;  //k  6B
    *(z++)=y[x++]-0x27;  //D  44
    *(z++)=y[x++]+0x21;  //e  65
    *(z++)=y[x++]+0x09;  //n  6E
    *(z++)=y[x++]-0x07;  //g  67
    *(z++)=y[x++]-0x31;  //6  36
    *(z++)=y[x++]-0x01;  //5  35
    *(z++)=y[x++]+0x00;  //5  35
    *(z++)=y[x++]-0x02;  //3  33
    *(z++)=y[x++]+0x02;  //5  35
    *(z++)=y[x++]-0x00;  //5  35
    *(z++)=y[x]-0x35;    //0  0
    //    x=*(--z);
    stack->setXXTEAKeyAndSign(y, "pokdeng@boyaa2015");

#ifdef CC_TARGET_OS_IPHONE
	if (sizeof(long) == 4) {
		stack->loadChunksFromZIP("res/game.zip");
	} else {
		stack->loadChunksFromZIP("res/game64.zip");
	}
#else
    
    stack->loadChunksFromZIP("res/game.zip");
    /* ** end ** */
#endif
	stack->executeString("require 'main'");

	// use discrete files
	// engine->executeScriptFile("src/main.lua");

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();
    Director::getInstance()->pause();

    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    SimpleAudioEngine::getInstance()->pauseAllEffects();

    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("APP_ENTER_BACKGROUND_EVENT");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->resume();
    Director::getInstance()->startAnimation();

    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    SimpleAudioEngine::getInstance()->resumeAllEffects();

    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("APP_ENTER_FOREGROUND_EVENT");
}
