//
//  CABasicAnimation+Category.h
//  ImageEditView
//
//  Created by 肖志强 on 2020/10/27.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CABasicAnimation (Category)

+ (CABasicAnimation *)createKeyPath: (NSString *)keyPath duration: (CFTimeInterval )duration fromValue: (CGPathRef)fromValue  toValue: (CGPathRef)toValue;

@end

NS_ASSUME_NONNULL_END
