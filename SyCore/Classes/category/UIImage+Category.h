//
//  UIImage+Category.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Category)

+ (UIImage *)createImageWithColor: (UIColor *)color;

+ (UIImage *)imageCompressImage:(UIImage *)sourceImage targetSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
