//
//  Permission.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, PermissonType) {
    PermissonTypeNone = 0,
    /// 系统通知
    PermissonTypeNotification,
    /// 系统定位
    PermissonTypeLocation,
    /// 系统相册
    PermissonTypeAlbum,
    /// 系统通讯录
    PermissonTypeContact,
    /// 系统相机
    PermissonTypeCamera,
    /// 系统麦克风
    PermissonTypeMic
};

typedef NS_ENUM(NSUInteger, AuthorizationStatus) {
    /// 用户未作出选择
    AuthorizationStatusNotDetermined,
    /// 用户已授权此应用程序进行有限照片库访问
    AuthorizationStatusLimited,
    /// 用户已授权此应用程序访问照片数据
    AuthorizationStatusAuthorized,
    /// 用户已明确拒绝此应用程序访问照片数据
    AuthorizationStatusDenied,
    /// 无权限访问照片数据
    AuthorizationStatusRestricted
};

@interface Permission : NSObject

+(instancetype)shared;

- (void)requestPermissionType: (PermissonType)type completion: (void(^)(BOOL allow, AuthorizationStatus status))completion;

- (void)goSettingPage: (NSString *)message;

@end

NS_ASSUME_NONNULL_END
