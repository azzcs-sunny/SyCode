//
//  Encrypt.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/16.
//

#import "Encrypt.h"
#import <CommonCrypto/CommonCrypto.h>

#define CC_MD5_DIGEST_LENGTH    16
@implementation Encrypt

+ (NSString * _Nullable)MD5:(NSString * _Nonnull)string {
    if (string == nil || [string length] == 0) {
        return nil;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([string UTF8String], (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat: @"%02x", (int)(digest[i])];
    }
    return [ms copy];
}

@end
