//
//  UILabel+Category.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/15.
//

#import "UILabel+Category.h"

@implementation UILabel (Category)

- (void)addTextFont:(UIFont *)font textColor:(UIColor *)color text:(NSString *)text {
    self.font = font;
    self.textColor = color;
    self.text = text;
}

@end
