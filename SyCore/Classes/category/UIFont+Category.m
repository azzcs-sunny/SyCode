//
//  UIFont+Category.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/10.
//

#import "UIFont+Category.h"

@implementation UIFont (Category)

+ (UIFont *)sy_systemFontSize: (CGFloat)size {
    CGFloat s = [UIScreen mainScreen].bounds.size.width * size / 375.0f;
    return [UIFont fontWithName:@"PingFangSC-Regular" size: s];
}

+ (UIFont *)sy_mediumSystemFontSize: (CGFloat)size {
    CGFloat s = [UIScreen mainScreen].bounds.size.width * size / 375.0f;
    return [UIFont fontWithName:@"PingFangSC-Medium" size: s];
}

+ (UIFont *)sy_boldSystemFontSize: (CGFloat)size {
    CGFloat s = [UIScreen mainScreen].bounds.size.width * size / 375.0f;
    return [UIFont fontWithName:@"PingFangSC-Semibold" size: s];
}

@end
