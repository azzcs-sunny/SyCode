//
//  WeChat.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/12.
//

#import "WeChat.h"
#import "LogHeader.h"

@implementation WeChat

static WeChat *_wechat = nil;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _wechat = [[super allocWithZone:NULL] init];
    });
    return _wechat;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [WeChat shared];
}

-(id)copyWithZone:(NSZone *)zone {
    return [WeChat shared];
}

#pragma mark - 微信支付回调代理方法 WXApiDelegate
//WXSuccess           =  0,   成功
//WXErrCodeCommon     = -1,   普通错误类型
//WXErrCodeUserCancel = -2,   用户点击取消并返回
//WXErrCodeSentFail   = -3,   发送失败
//WXErrCodeAuthDeny   = -4,   授权失败
//WXErrCodeUnsupport  = -5,   微信不支持
- (void)onResp:(BaseResp *)resp {
    // 判断支付类型
    if([resp isKindOfClass:[PayResp class]]){
        //支付回调
        NSInteger result = 0;
        NSString *message = resp.errStr;
        switch (resp.errCode) {
            case 0:
                message = @"支付成功";
                result = 0;
                break;
                
            case -1:
                message = @"支付失败";
                result = 10;
                break;
                
            case -2:
                message = @"用户中途取消";
                result = 10;
                break;
                
            case -3:
                message = @"发送失败";
                result = 10;
                break;
                
            case -4:
                message = @"授权失败";
                result = 10;
                break;
                
            case -5:
                message = @"微信不支持";
                result = 10;
                break;
                
            default:
                message = resp.errStr;
                result = 10;
                break;
        }
        Log(@"微信支付回调: 状态码:%ld - 描述信息: %@", result, message);
        [Event postNotificationName:WX_PAY object:@{@"resp": resp, @"result": @(result)}];
    }
}

-(void)onReq:(BaseReq *)req {
    
}

+ (void)onWeChatPay:(NSDictionary *)dictionary {
    Log(@"timestamp class = %@", [dictionary[@"timestamp"] class]);
    NSString *times = [dictionary objectForKey:@"timestamp"];
    PayReq* req             = [[PayReq alloc] init];
    req.partnerId           = [dictionary objectForKey:@"partnerid"];
    NSString *pid = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"prepayid"]];
    if ([pid isEqual:[NSNull null]] || pid == NULL || [pid isEqual:@"null"]) {
        pid = @"123";
    }
    req.prepayId            = pid;
    req.nonceStr            = [dictionary objectForKey:@"noncestr"];
    req.timeStamp           = times.intValue;
    req.package             = [dictionary objectForKey:@"package"];
    req.sign                = [dictionary objectForKey:@"sign"];
    
    [WXApi sendReq:req completion:^(BOOL success) {
        Log(@"sendReq回调： %d",success);
    }];
}

@end
