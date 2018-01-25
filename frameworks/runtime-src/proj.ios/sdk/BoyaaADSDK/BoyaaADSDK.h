//
//  BoyaaAD.h
//  Poker
//
//  Created by RayDeng on 14-8-27.
//  Copyright (c) 2014年 Boyaa iPhone Texas Poker. All rights reserved.
//

#import <Foundation/Foundation.h>



#if ! __has_feature(objc_arc)
#define BYAutorelease(__v) ([__v autorelease]);
#define BYRetain(__v) ([__v retain]);
#define BYRelease(__v) ([__v release]);
#else
#define BYAutorelease(__v)
#define BYRetain(__v)
#define BYRelease(__v)
#endif


@interface BoyaaADSDK : NSObject
@property (nonatomic)BOOL isDebug;
+(BoyaaADSDK*)instance;

/*
 * 注意要添加 appsFlyer sdk （AppsFlyerTracker.h & libAppsFlyerLib.a）
 * @param key  Use this property to set your AppsFlyer's dev key.
 * @param itunesID Use this property to set your app's Apple ID (taken from the app's page on iTunes Connect)
 */
-(void)initAppFlyerWithKey:(NSString *)key andAppleItunesID:(NSString*)itunesID;

/*
 * 设置支付币种，默认为 @"USD"
 * In case of in app purchase events, you can set the currency code your user has purchased with.
 * The currency code is a 3 letter code according to ISO standards. Example: "USD" ,"RMB"。default @"USD"
 */
@property (nonatomic,strong) NSString* currencyCode;

/*
 * applicationDidBecomeActive 时调用。调用前注意 先 初始化。
 */
-(void)appDidBecomeActive;
/*
 * 新用户注册，传入用户的 id。
 * @param userId  用来区分用户的 id
 */
-(void)registerNewUser:(NSString *)userId;
/*
 * 用户登陆，传入用户的 id。
 * @param userId  用来区分用户的 id
 */
-(void)loginWithUserId:(NSString*)userId;
/*
 * 每局游戏开始时调用
 *
 */
-(void)playGame;
/*
 * 新用户注册，传入用户的 id。
 * @param money  金额，如 @"1" ,@"0.99"
 */
-(void)purchase:(NSString*)money;

/*
 * 自定义事件记录
 * @param eventName  事件名
 * @param value 值
 * eg  [instance trackEvent:@"purchase" withValue:@"10"];
 * eg  [instance trackEvent:@"logout" withValue:@""];
 *
 */
- (void)trackEvent:(NSString*)eventName withValue:(NSString*)value;
@end
