//
//  UIColor+Category.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Category)

+ (UIColor *)rgb:(NSString *)grb;

+ (UIColor *)rgb:(NSString *)rgb alpha:(CGFloat)a;

+ (UIColor*) colorWithRGB:(NSUInteger)rgb alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
