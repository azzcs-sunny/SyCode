//
//  NSDate+Category.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/11.
//

#import "NSDate+Category.h"

@implementation NSDate (Category)

+ (NSString *)nowUntilisecond {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

+ (NSString *)nowUntilMinute {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *dataStr = [formatter stringFromDate:[NSDate date]];
    return dataStr;
}

+ (NSString *)nowUntilMillisecond {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSSSSS";
    NSString *dataStr = [formatter stringFromDate:[NSDate date]];
    return dataStr;
}

+ (NSString *)nowSeconds {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

+ (NSString *)nowMilliseconds {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970] * 1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

@end
