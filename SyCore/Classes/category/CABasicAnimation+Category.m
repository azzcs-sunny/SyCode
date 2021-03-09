//
//  CABasicAnimation+Category.m
//  ImageEditView
//
//  Created by 肖志强 on 2020/10/27.
//

#import "CABasicAnimation+Category.h"

@implementation CABasicAnimation (Category)

+ (CABasicAnimation *)createKeyPath: (NSString *)keyPath duration: (CFTimeInterval )duration fromValue: (CGPathRef)fromValue  toValue: (CGPathRef)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.duration = duration;
    animation.fromValue = (__bridge id _Nullable)(fromValue);
    animation.toValue = (__bridge id _Nullable)(toValue);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return  animation;
}

@end
