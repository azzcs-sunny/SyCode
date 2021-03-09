//
//  WeChat.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/12.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
NS_ASSUME_NONNULL_BEGIN

@interface WeChat : NSObject<NSCopying, WXApiDelegate>

+ (instancetype)shared;

- (void)onResp: (BaseResp *)resp;

- (void)onReq:(BaseReq*)req;

+ (void)onWeChatPay:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
