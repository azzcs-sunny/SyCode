//
//  UIView+Extensions.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Extensions)

/// 缩放动画
- (void)scale: (CGPoint)offset animated: (BOOL)animated duration: (CFTimeInterval)duration completion: (void (^ _Nullable)(BOOL))completion;

/// 添加边框
- (void)layerBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius;

///添加圆角
- (void)addCornerRadius:(CGFloat)radius;

///添加阴影
- (void)addShadowForRadius:(CGFloat)radius shadowOpacity:(CGFloat)shadowOpacity shadowOffset:(CGSize)shadowOffset shadowColor:(UIColor*)shadowColor;

/// 渐变色
- (void)setGradientLayer: (UIColor *)startColor startPoint: (CGPoint)startPoint endColor: (UIColor *)endColor endPoint: (CGPoint)endPoint;

/// 贝塞尔实现某个或多个圆角
- (void)customRadius: (UIRectCorner)corner cornerRadii: (CGSize)cornerRadii;

@end

NS_ASSUME_NONNULL_END
