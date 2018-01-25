//
//  BlueMessage.h
//  BluePay
//
//  Created by guojianmin on 16/1/13.
//  Copyright © 2016年 alvin. All rights reserved.
//

#ifndef BlueMessage_h
#define BlueMessage_h


#endif /* BlueMessage_h */

@interface BlueMessage : NSObject
{
    NSInteger _code;
    NSString* _desc;
    NSString* _price;
    NSString* _propsName;
    NSString* _transactionId;
    NSString* _paymentCode;

}
@property(nonatomic, retain) NSString* desc,*price,*propsName ,*transactionId,*paymentCode;
@property(nonatomic) NSInteger code;
@end