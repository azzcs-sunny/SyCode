//
//  AliPay.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/12.
//

#import "AliPay.h"
#import <AlipaySDK/AlipaySDK.h>
#import "LogHeader.h"

@implementation AliPay

static AliPay *_alipay = nil;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _alipay = [[super allocWithZone:NULL] init];
    });
    return _alipay;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [AliPay shared];
}

-(id)copyWithZone:(NSZone *)zone {
    return [AliPay shared];
}

#pragma mark - iOS 9.0 & iOS 10.0 微信&支付宝回调函数
/**
 *返回码    含义
 *9000    订单支付成功
 *8000    正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
 *4000    订单支付失败
 *5000    重复请求
 *6001    用户中途取消
 *6002    网络连接出错
 *6004    支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
 *其它    其它支付错误
 */
- (BOOL)onAlipaySDKOpenURL:(NSURL *)url {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        Log(@"alipay_resultDic=== %@", resultDic);
        
        NSString *resultStatus = resultDic[@"resultStatus"];
        NSString *message = [NSString string];
        NSInteger result = 0;
        switch (resultStatus.integerValue) {
                
            case 9000:    //支付成功
                result = 0;
                message = @"支付成功";
                break;
                
            case 8000:
                result = 10;
                message = @"正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态";
                break;
                
            case 4000:
                result = 10;
                message = @"订单支付失败";
                break;
                
            case 5000:
                result = 10;
                message = @"重复请求";
                break;
                
            case 6001:
                result = 10;
                message = @"用户中途取消";
                break;
                
                
            case 6002:
                result = 10;
                message = @"网络连接出错";
                break;
                
            case 6004:
                result = 10;
                message = @"支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态";
                break;
                
            default:
                result = 10;
                message = @"支付失败";
                break;
        }
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            Log(@"授权结果 authCode = %@", authCode?:@"");
        }];
        
        Log(@"AlipaySDK支付回调: 状态码:%ld - 描述信息: %@", result, message);
        [Event postNotificationName:ALI_PAY object:@{@"resultDic": resultDic, @"result": @(result)}];
    }];
    
    return YES;
}

+ (void)onAliPay:(NSString *)orderStr scheme: (NSString *)schemeStr {
    ///调起支付
    if (orderStr != nil) {
        [[AlipaySDK defaultService] payOrder:orderStr fromScheme:schemeStr callback:^(NSDictionary *resultDic) {
            Log(@"resultDic=== %@", resultDic);
            NSInteger result = 0;
            NSString *message = @"";
            NSString *resultStatus = resultDic[@"resultStatus"];
            switch (resultStatus.integerValue) {
                case 9000:    //支付成功
                    result = 0;
                    message = @"支付成功";
                    break;
                    
                case 8000:
                    result = 10;
                    message = @"正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态";
                    break;
                    
                case 4000:
                    result = 10;
                    message = @"订单支付失败";
                    break;
                    
                case 5000:
                    result = 10;
                    message = @"重复请求";
                    break;
                    
                case 6001:
                    result = 10;
                    message = @"用户中途取消";
                    break;
                    
                    
                case 6002:
                    result = 10;
                    message = @"网络连接出错";
                    break;
                    
                case 6004:
                    result = 10;
                    message = @"支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态";
                    break;
                    
                default:
                    result = 10;
                    message = @"支付失败";
                    break;
            }
            [Event postNotificationName:ALI_PAY object:@{@"resultDic": resultDic, @"result": @(result)}];
        }];
    }
}

@end
