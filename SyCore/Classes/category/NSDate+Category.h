//
//  NSDate+Category.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Category)

/** yyyy-MM-dd HH:mm:ss */
+ (NSString *)nowUntilisecond;

/** yyyy-MM-dd HH:mm */
+ (NSString *)nowUntilMinute;

/** yyyy-MM-dd HH:mm:ss.SSSSSS */
+ (NSString *)nowUntilMillisecond;

+ (NSString *)nowSeconds;

+ (NSString *)nowMilliseconds;

@end

NS_ASSUME_NONNULL_END
