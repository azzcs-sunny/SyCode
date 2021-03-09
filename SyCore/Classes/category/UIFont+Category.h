//
//  UIFont+Category.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (Category)

/** PingFangSC-Regular */
+ (UIFont *)sy_systemFontSize: (CGFloat)size;

/** PingFangSC-Medium */
+ (UIFont *)sy_mediumSystemFontSize: (CGFloat)size;

/** PingFangSC-Semibold */
+ (UIFont *)sy_boldSystemFontSize: (CGFloat)size;

@end

NS_ASSUME_NONNULL_END
