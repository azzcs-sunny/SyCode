//
//  UIView+Editor.m
//  ImageEditView
//
//  Created by 肖志强 on 2020/10/29.
//

#import "UIView+Editor.h"

@implementation UIView (Editor)

- (UIImage *)screenshotImageSize: (CGSize)imagSize {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGSize size = CGSizeMake([self roundToPlaces:5 length:width], [self roundToPlaces:5 length: height]);
    if (@available(iOS 10.0, *)) {
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc]init];
        if (CGSizeEqualToSize(imagSize, CGSizeZero)) {
            renderer = [[UIGraphicsImageRenderer alloc]initWithSize:size];
        }else {
            UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc]init];
            format.scale = imagSize.width / size.width;
            renderer = [[UIGraphicsImageRenderer alloc]initWithSize:size format:format];
        }
        return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [self.layer renderInContext:rendererContext.CGContext];
        }];
    } else {
        NSLog(@"暂未兼容iOS9.0的图片截取");
        // Fallback on earlier versions
    }
    return [UIImage new];
}

- (CGFloat)roundToPlaces: (NSInteger)places length: (CGFloat)length {
    CGFloat divisor = pow(10.0, (CGFloat)places);
    return round(length * divisor) / divisor;
}

@end
