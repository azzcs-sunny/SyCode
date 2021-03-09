//
//  NSString+Category.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/15.
//

#import "NSString+Category.h"

@implementation NSString (Category)

+ (NSString *)decimalNumber: (NSString *)str {
    double conversionValue = [str doubleValue];
    NSString *doubleString = [NSString stringWithFormat:@"%lf", conversionValue];
    NSDecimalNumber *decNumber = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}

@end
