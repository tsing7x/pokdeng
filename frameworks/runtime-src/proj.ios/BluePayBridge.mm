//
//  BluePayBridge.m
//  nineke
//
//  Created by jonah on 16/3/14.
//
//

#import "BluePayBridge.h"
#import "CCLuaBridge.h"
#import "LuaOCBridge.h"
#import "platform/ios/CCLuaObjcBridge.h"
USING_NS_CC;

static int setupCompleteCallbackMethodId;
static int purchaseCompleteCallbackMethodId;
static BluePayBridge * bluepayPlugin;

@implementation BluePayBridge

+ (void) callLuaCallback:(int)functionId withString:(const char*)params
{
	LuaBridge::pushLuaFunctionById(functionId);
	LuaBridge::getStack()->pushString(params);
	LuaBridge::getStack()->executeFunction(1);
	LuaBridge::releaseLuaFunctionById(functionId);
}

+(BluePayBridge *) getPlugin
{
	if(bluepayPlugin == nil)
	{
		bluepayPlugin = [[BluePayBridge alloc] init];
	}
	return bluepayPlugin;
}

+(BOOL) isSetupComplete
{
	BluePayBridge* plugin = [BluePayBridge getPlugin];
	return plugin->isSetupComplete;
}

+ (BOOL) isSupported
{
	BluePayBridge* plugin = [BluePayBridge getPlugin];
	return plugin->isSupported;
}
+ (void) setup
{
	BluePayBridge* plugin = [BluePayBridge getPlugin];
	[plugin startSetUp];
}

+ (void) setSetupCompleteCallback:(NSDictionary*)dict
{
	setupCompleteCallbackMethodId = [[dict objectForKey:@"listener"] intValue];
}

+ (void) setPurchaseCompleteCallback:(NSDictionary*)dict
{
	purchaseCompleteCallbackMethodId = [[dict objectForKey:@"listener"] intValue];
}

+ (void) payBySMS:(NSDictionary*)dict
{
	BluePayBridge* plugin = [BluePayBridge getPlugin];
	NSString* uid = [dict objectForKey:@"uid"];
	NSString* pid = [dict objectForKey:@"pid"];
	NSString* transactionId = [dict objectForKey:@"transactionId"];
	NSString* currency = [dict objectForKey:@"currency"];
	NSString* price = [[dict objectForKey:@"price"] stringValue];
	NSUInteger smsId = [[dict objectForKey:@"smsId"] integerValue];
	NSString* propsName = [dict objectForKey:@"propsName"];
	BOOL isShowDialog = [[dict objectForKey:@"isShowDialog"] boolValue];
	[plugin payBySms:transactionId currency:currency price:price smsid:smsId prpsName:propsName isShowDialog:isShowDialog];
}

+ (void) payByCashcard:(NSDictionary *)dict
{
	BluePayBridge* plugin = [BluePayBridge getPlugin];
	NSString* uid = [dict objectForKey:@"uid"];
	NSString* pid = [dict objectForKey:@"pid"];
	NSString* transactionId = [dict objectForKey:@"transactionId"];
//	NSString* currency = [dict objectForKey:@"currency"];
//	NSString* price = [[dict objectForKey:@"price"] stringValue];
//	NSUInteger smsId = [[dict objectForKey:@"smsId"] integerValue];
	NSString* propsName = [dict objectForKey:@"propsName"];
	BOOL isShowDialog = [[dict objectForKey:@"isShowDialog"] boolValue];
	NSString *publisher = [dict objectForKey:@"publisher"];
	NSString *cardNo = [dict objectForKey:@"cardNo"];
	NSString *serialNo = [dict objectForKey:@"serialNo"];
	[plugin payByCashCard:transactionId customerId:uid  publisher:publisher prpsName:propsName
			  cardNo:cardNo serialNo:serialNo isShowDialog:isShowDialog];
}

- (void) startSetUp
{
	if(!isSetupComplete)
	{
		if(!isSetuping){
			isSetuping = true;
			retryLimit = 4;
			[self initSDK];
		}
		
	}
	
}

- (void) initSDK
{
	_client = [Client getInstance];
	_client.initDelegate = self;
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.1) {
		isSetupComplete = true;
		isSetuping = false;
		isSupported = false;
		isPurchasing = false;
		[BluePayBridge callLuaCallback:setupCompleteCallbackMethodId withString:"false"];
		return;
	}
	[_client initSDK:110 promotion:@"1000" key:@"2_5F689284876D4C68605DBBF7E2C3407F" language:@"en" showLoading:NO];
}

- (void) payBySms:(NSString *)transationId currency:(NSString *)currency price:(NSString *)price smsid:(NSUInteger)smsId prpsName:(NSString *)propsName isShowDialog:(BOOL)isShowDialog
{
	if(isSetupComplete && isSupported && !isPurchasing){
		isPurchasing = true;
		RootViewController* rootVC = [LuaOCBridge getRoomViewController];
		[BluePay payBySms:self context:(UIViewController*)rootVC transationId:transationId currency:currency price:price smsid:smsId prpsName:propsName isShowDialog:isShowDialog];
	}
	
}

- (void) payByCashCard:(NSString*) transactionId customerId:(NSString*) cusId  publisher:(NSString*) publisher prpsName:(NSString*) propsName
				cardNo:( NSString*) cardNo serialNo:(NSString*) serialNo isShowDialog :(BOOL) isShowDialog
{
	if ([publisher  isEqual: @"12Call"]) {
		publisher = PUBLISHER_12CALL;
	}else if([publisher  isEqual: @"trueMoney"]) {
		publisher = PUBLISHER_TRUEMONEY;
	}
	
	if(isSetupComplete && isSupported && !isPurchasing){
		isPurchasing = true;
		RootViewController* rootVC = [LuaOCBridge getRoomViewController];
		[BluePay payByCashCard:self context:(UIViewController*)rootVC transactionId:transactionId customerId:cusId publisher:publisher prpsName:propsName cardNo:cardNo serialNo:serialNo isShowDialog:isShowDialog];
		
	}
	
}

-(void) complete:(int)result :(NSString *)msg
{
	
	NSLog(@"code:%d",result);
	NSLog(@"msg:%@",msg);
	if(result == 1) {
		isSetupComplete = true;
		isSetuping = false;
		isSupported = true;
		isPurchasing = false;
		[BluePayBridge callLuaCallback:setupCompleteCallbackMethodId withString:"true"];
	}
	else
	{
		if(retryLimit-- > 0)
		{
			[self initSDK];
		}
		else
		{
			isSetupComplete = true;
			isSetuping = false;
			isSupported = false;
			[BluePayBridge callLuaCallback:setupCompleteCallbackMethodId withString:"false"];
		}
	}
}

-(void) onComplete:(int)code message:(BlueMessage *)msg
{
	NSLog(@"code:%d",code);
	NSLog(@"result code:%ld message:%@",(long)[msg code],msg.desc);
	NSString* title = @"";
	NSString* result = @"";
	isPurchasing = false;
	NSInteger bcode = 0;
	bool isSuccess = false;
	NSString* transationID = msg.transactionId;
	NSString* desc = msg.desc;
	if (code == RESULT_SECCESS) {
		title = [NSString stringWithFormat:@"购买道具：[ %@ ] 成功！", msg.propsName];
		bcode = msg.code;
		result = [NSString stringWithFormat:@"bcode:%ld 账单ID:%@", (long)bcode,transationID];
		isSuccess = true;
	}else if (code == RESULT_FAILED){
		title = [NSString stringWithFormat:@"购买道具：[ %@ ] 失败！", msg.propsName];
		bcode = msg.code;
		result = [NSString stringWithFormat:@"bcode:%ld 账单ID:%@", (long)bcode,transationID];
		isSuccess = false;
	} else if (code == RESULT_CANCEL) {
		title = [NSString stringWithFormat:@"购买道具：[ %@ ] 取消！", msg.propsName];
		bcode = msg.code;
		result = [NSString stringWithFormat:@"bcode:%ld 账单ID:%@", (long)bcode,transationID];
		isSuccess = false;
	}
	NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
	[dic setValue:result forKey:@"result"];
	[dic setValue:(isSuccess?@"true":@"false") forKey:@"isSuccess"];
	[dic setValue:title forKey:@"title"];
	[dic setValue:[NSNumber numberWithInt:code] forKey:@"code"];
	[dic setValue:desc forKey:@"desc"];
	[dic setValue:transationID forKey:@"transationID"];
	[dic setValue:[NSString stringWithFormat:@"%ld",(long)bcode] forKey:@"bcode"];
	
	if([NSJSONSerialization isValidJSONObject:dic]) {
		NSError* error;
		NSData *jsondata = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
		NSString *str = [[NSString alloc]initWithData:jsondata encoding:NSUTF8StringEncoding];
		[BluePayBridge callLuaCallback:purchaseCompleteCallbackMethodId withString:[str UTF8String]];
	} else {
		[BluePayBridge callLuaCallback:purchaseCompleteCallbackMethodId withString:"{}"];
	}
	
	
}

@end
