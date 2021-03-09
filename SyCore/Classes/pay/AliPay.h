//
//  AliPay.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliPay : NSObject<NSCopying>

+ (instancetype)shared;

- (BOOL)onAlipaySDKOpenURL:(NSURL *)url;

/// schemeStr       调用支付的app注册在info.plist中的scheme
+ (void)onAliPay:(NSString *)orderStr scheme: (NSString *)schemeStr;

@end

NS_ASSUME_NONNULL_END
