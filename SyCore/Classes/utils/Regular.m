//
//  Regular.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/16.
//

#import "Regular.h"

@implementation Regular

+ (BOOL)mobileRegular:(NSString *)mobile {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^1([3-9][0-9])\\d{8}$"];
    return [predicate evaluateWithObject:mobile];
}

+ (BOOL)passwordRegular:(NSString *)password {
    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{8,24}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}

+ (BOOL)isIDCard:(NSString *)ID {
    BOOL flag;
    if (ID.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *IDPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    return [IDPredicate evaluateWithObject:ID];
}

@end
