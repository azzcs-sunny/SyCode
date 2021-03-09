//
//  Regular.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Regular : NSObject

/** 手机号码正则*/
+ (BOOL)mobileRegular:(NSString *)mobile;

/** 密码正则8～24位*/
+ (BOOL)passwordRegular:(NSString *)password;

/** 身份证正则*/
+ (BOOL)isIDCard:(NSString *)ID;

@end

NS_ASSUME_NONNULL_END
