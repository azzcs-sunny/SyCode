//
//  NSString+Category.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Category)

/** 获取金额精度 */
+ (NSString *)decimalNumber: (NSString *)str;

@end

NS_ASSUME_NONNULL_END
