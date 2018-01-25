//
//  AdSdkBridge.h
//  nineke
//
//  Created by 罗 崇 on 15/5/20.
//
//



@interface AdSdkBridge : NSObject

+ (void) registerNewUser:(NSDictionary*)dict;
+ (void) loginWithUserId:(NSDictionary*)dict;
+ (void) playGame;
+ (void) purchase:(NSDictionary*)dict;
+ (void) trackEvent:(NSDictionary*)dict;

@end