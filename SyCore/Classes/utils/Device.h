//
//  Device.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Device : NSObject

+ (NSString *)bundleID;

+ (NSString *)deviceName;

+ (NSString *)sysVersion;

+ (NSString *)versionString;

+ (NSString *)build;

+ (NSString *)identifierForVendor;

+ (NSString *)uuid;

+ (NSString *)deviceId;

@end

NS_ASSUME_NONNULL_END
