//
//  BluePayBridge.h
//  nineke
//
//  Created by jonah on 16/3/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluePay/CoreBluePay.h>

@interface BluePayBridge : NSObject<InitSDKProtocal,PayDelegate>
{
	Client* _client;
	BOOL isSetupComplete;
	BOOL isSetuping;
	BOOL isSupported;
	BOOL isPurchasing;
	int retryLimit;
}

+ (void) callLuaCallback:(int)functionId withString:(const char*)params;
+ (BluePayBridge*) getPlugin;
+ (BOOL) isSetupComplete;
+ (BOOL) isSupported;
+ (void) setup;
+ (void) setSetupCompleteCallback:(NSDictionary*)dict;
+ (void) setPurchaseCompleteCallback:(NSDictionary*)dict;
+ (void) payBySMS:(NSDictionary*)dict;
+ (void) payByCashcard:(NSDictionary*)dict;

- (void) startSetUp;
- (void) initSDK;
- (void) payBySms:(NSString*) transationId currency:(NSString*) currency price:(NSString*) price smsid:(NSUInteger) smsId prpsName:(NSString*) propsName   isShowDialog :(BOOL) isShowDialog;
- (void) payByCashCard:(NSString*) transactionId customerId:(NSString*) cusId  publisher:(NSString*) publisher prpsName:(NSString*) propsName
				cardNo:( NSString*) cardNo serialNo:(NSString*) serialNo isShowDialog :(BOOL) isShowDialog;


@property(nonatomic ,retain) Client* client;
@end
