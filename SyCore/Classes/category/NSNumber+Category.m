//
//  NSNumber+Category.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/11/9.
//

#import "NSNumber+Category.h"

@implementation NSNumber (Category)

+ (NSNumber *)getNSNumberWithString:(NSString *)string {
    NSInteger integer = [string integerValue];
    NSNumber *number = @(integer);
    return number;
}

@end
