//
//  Device.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/30.
//

#import "Device.h"
#import <UIKit/UIKit.h>
//#import <SAMKeychain/SAMKeychain.h>

@implementation Device

+ (NSString *)bundleID {
    return [NSBundle mainBundle].bundleIdentifier;
}

+ (NSString *)deviceName {
    return [[UIDevice currentDevice] name];
}

+ (NSString *)sysVersion {
    return [[UIDevice currentDevice]systemVersion];
}

+ (NSString *)versionString {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)build {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
}

+ (NSString *)identifierForVendor {
    return [[[UIDevice currentDevice]identifierForVendor] UUIDString];
}

+ (NSString *)uuid {
    return  [[NSUUID UUID]UUIDString];
}

+ (NSString *)deviceId {
    NSString *identify = [Device bundleID];
//    NSString *deviceId = [SAMKeychain passwordForService:identify account:identify];
//    if ( deviceId == nil) {
//        if ([Device identifierForVendor] != nil) {
//            deviceId = [Device identifierForVendor];
//        }else {
//            deviceId = [Device uuid];
//        }
//        [SAMKeychain setPassword:deviceId forService:identify account:identify];
//    }
//    return deviceId;
    return identify;
}

@end
