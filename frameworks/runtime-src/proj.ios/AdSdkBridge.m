//
//  AdSdkBridge.m
//  nineke
//
//  Created by 罗 崇 on 15/5/20.
//
//

#import "AdSdkBridge.h"
#import "BoyaaADSDK.h"

@implementation AdSdkBridge

+ (void) registerNewUser:(NSDictionary*)dict
{	
	
	NSString* uid = [dict objectForKey:@"uid"];
	NSLog(@"registerNewUser %@", uid);
	[[BoyaaADSDK instance] registerNewUser:uid];
}

+ (void) loginWithUserId:(NSDictionary*)dict
{
	NSString* uid = [dict objectForKey:@"uid"];
	NSLog(@"loginWithUserId %@", uid);
	[[BoyaaADSDK instance] loginWithUserId:uid];
}

+ (void) playGame
{
	NSLog(@"playGame");
	[[BoyaaADSDK instance]playGame];
}

+ (void) purchase:(NSDictionary*)dict
{
	NSString* payMoney = [dict objectForKey:@"payMoney"];
	NSString* currencyCode = [dict objectForKey:@"currencyCode"];
	[[BoyaaADSDK instance]setCurrencyCode:payMoney];
	[[BoyaaADSDK instance]purchase:currencyCode];
}

+ (void) trackEvent:(NSDictionary*)dict
{
	
	NSString* eventName = [dict objectForKey:@"eventName"];
	NSString* eventValue = [dict objectForKey:@"eventValue"];
	NSLog(@"trackEvent %@", eventName);
	
	[[BoyaaADSDK instance] trackEvent:eventName withValue:eventValue];
}

@end
