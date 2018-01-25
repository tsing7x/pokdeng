//
//  BluePay.h
//  BluePay
//
//  Created by guojianmin on 16/1/13.
//  Copyright © 2016年 alvin. All rights reserved.
//

#ifndef BluePay_h
#define BluePay_h


#import <Foundation/Foundation.h>
#import "PayDelegate.h"
#import <UIKit/UIKit.h>
#import "PublisherCode.h"
#endif /* BluePay_h */


enum result
{
    RESULT_FAILED,
    RESULT_SECCESS,
    RESULT_CANCEL
};
@interface BluePay : NSObject
/*!
 @param id delegate the callback of payment,your must implementation PayDelegate protocol
 @param id Context  the view controller of your view
 @param NSString transactionId 
 @param NSString customerId
 @param NSString currency
 @param NSString price
 @param NSInteger  smsId
 @param NSString propsName
 @param BOOL isShowDialog
 @return if return false ,payDelegate is nil,please implete PayDelegate.
 */
+(bool) payBySms:(id)delegate context:(UIViewController*)context transationId:(NSString*) transactionId  currency:(NSString*) currency price:(NSString*) price smsid:(NSUInteger) smsId prpsName:(NSString*) propsName   isShowDialog :(BOOL) isShowDialog ;
/*!
 @param delegate id, the callback of payment.
 @param context  controller of your view.
 @param  NSString customId,
 @param  NSString transactionId,
 @param  NSString propsName, 
 @param NSString publisher,
 @param NSString cardNo, 
 @param NSString serialNo, 
 @param boolean isShowLoading
 @return bool return false ,means that your delegate  or contextis nil,please implementation PayDelegate
 */
+(bool)payByCashCard:(id)delegate context:(UIViewController*) context transactionId:(NSString*) transactionId customerId:(NSString*) cusId  publisher:(NSString*) publisher prpsName:(NSString*) propsName
       cardNo:( NSString*) cardNo serialNo:(NSString*) serialNo isShowDialog :(BOOL) isShowDialog;
//+(id) getInstance;
+(bool)payByBank:(id)delegate ctx:(UIViewController*) context tId:(NSString*) transactionId currency:(NSString*)currency price:(NSString*) price propsName:(NSString*)propsName isShowDialog:(BOOL)isShowDialog;
/*!
 @description
 @param delegate id, the callback of payment.
 @param context  controller of your view.
 @param  NSString customId,
 @param  NSString transactionId,
 @param  NSString propsName,
 @param NSString publisher,
 @param NSString cardNo,
 @param NSString serialNo,
 @param boolean isShowLoading
 @return bool return false ,means that your delegate  or contextis nil,please implementation PayDelegate
 */

+(bool) payByOffline:(id)delegate ctx:(UIViewController*)context tId:(NSString *)transactionId customerId:(NSString *)cstId price:(NSString *)price propsName:(NSString *)propsName isShowDialog:(BOOL)isShowDialog;
/**
 @param delegate (PayDelegate --> id) the protocol for callback.
 @param contexxt (UIView*) the view which you call this interface.
 @param transcactionId (NSString*) the transactionId for this transaction.
 @param price (NSString *) the price you want to pay.the price must be 1:1 ,for example, pay for 1THB ,the price=@"1",of cause you can use the tarrif id replace the price..
 @param propsName (NSString*) the propsName.
 @param publisher (NSString*) now that we just support PUBLISHER_LINE,if this param's value is other, will finish this payment.
 @param scheme (NSString*) the scheme for the appcation where you want to go when this payment finished.
 @param isShowDialog YES or NO.
 @return bool   true or false . if return false ,it means that delegate or context containt nil value.
 */
+(bool) payByWallet:(id)delegate context:(UIViewController*)context transationId:(NSString*) transactionId currency:(NSString*)currency price:(NSString*) price prpsName:(NSString*) propsName  publisher:(NSString*)publisher schceme:(NSString*)scheme isShowDialog :(BOOL) isShowDialog ;
+(bool)payByUI:(id)delegate context:(UIViewController*) ctx transationId:(NSString*) transactionId cumstomerId:(NSString*)cid currency:(NSString*)currency price:(NSString*) price smsid:(NSUInteger) smsId  prpsName:(NSString*) propsName publisher:(NSString*)publisher schceme:(NSString*)scheme isShowDialog :(BOOL) isShowDialog ;
+(void) queryTrans:(NSString*)transcactionId publisher:(NSString*)publisher num:(NSInteger) num isShow:(BOOL)isShow;
/**
 *@decription  configure the loading dialog ,
 @param BOOL  if YES ,will show the loading dialog ,else will not.
 */
+(void)setShowCardLoading:(BOOL)isOrNot;

@end
//static  BluePay* bluePay = nil;