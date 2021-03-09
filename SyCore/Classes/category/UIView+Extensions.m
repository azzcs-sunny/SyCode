//
//  UIView+Extensions.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/13.
//

#import "UIView+Extensions.h"

@implementation UIView (Extensions)

- (void)scale:(CGPoint)offset animated:(BOOL)animated duration:(CFTimeInterval)duration completion:(void (^ _Nullable)(BOOL))completion {
    if (animated) {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.transform = CGAffineTransformMakeScale(offset.x, offset.y);
        } completion:completion];
    }else {
        self.transform = CGAffineTransformMakeScale(offset.x, offset.y);
        if (completion) {
            completion(true);
        }
    }
}

/// 添加边框
- (void)layerBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius {
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = borderColor.CGColor;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

///添加圆角
- (void)addCornerRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
    self.clipsToBounds = true;
}

///添加阴影
- (void)addShadowForRadius:(CGFloat)radius shadowOpacity:(CGFloat)shadowOpacity shadowOffset:(CGSize)shadowOffset shadowColor:(UIColor*)shadowColor {
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOffset = shadowOffset;
    self.layer.shadowOpacity = shadowOpacity;
    self.layer.shadowRadius = radius;
    self.layer.cornerRadius = radius;
    self.clipsToBounds = NO;
}

- (void)setGradientLayer: (UIColor *)startColor startPoint: (CGPoint)startPoint endColor: (UIColor *)endColor endPoint: (CGPoint)endPoint {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    gradientLayer.colors = @[(__bridge  id)startColor.CGColor, (__bridge  id)endColor.CGColor];
    gradientLayer.locations = @[@(0), @(1.0f)];
    [self.layer addSublayer:gradientLayer];
}

- (void)customRadius: (UIRectCorner)corner cornerRadii: (CGSize)cornerRadii {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:cornerRadii];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

@end
