//
//  Permission.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/11/4.
//

#import "Permission.h"
#import <PhotosUI/PhotosUI.h>
#import "Device.h"
#import <Photos/Photos.h>
#import <Contacts/Contacts.h>
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CLLocationManager.h>
#import "LogHeader.h"

@implementation Permission

static Permission *_permission = nil;

+(instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _permission = [[super allocWithZone:NULL]init];
    });
    return _permission;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [Permission shared];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [Permission shared];
}

- (void)requestPermissionType: (PermissonType)type completion: (void(^)(BOOL allow, AuthorizationStatus status))completion {
    switch (type) {
        case PermissonTypeNotification:
            [_permission takeNotificationAuthorityCompLetion:completion];
            break;
        case PermissonTypeAlbum:
            [_permission takeAlbumAuthorityCompLetion:completion];
            break;
        case PermissonTypeCamera:
            [_permission takeCameraAuthorityCompLetion:completion];
            break;
        case PermissonTypeContact:
            [_permission takeContactAuthorityCompLetion:completion];
            break;
        case PermissonTypeMic:
            [_permission takeMicAuthorityCompLetion:completion];
            break;
        case PermissonTypeLocation:
            [_permission takeNCLLocationManagerAuthorityCompLetion:completion];
        default:
            break;
    }
}

/// 定位权限
- (void)takeNCLLocationManagerAuthorityCompLetion: (void(^)(BOOL allow, AuthorizationStatus status))completion {
    CLAuthorizationStatus s = [CLLocationManager authorizationStatus];
    switch (s) {
        case kCLAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    Log(@"只会调用一次，是否允许访问定位");
                    if (completion) {
                        if (!granted) {
                            Log(@"拒绝授权,不允许访问定位");
                            completion(false, AuthorizationStatusDenied);
                        }else {
                            Log(@"现在授权,允许访问定位");
                            completion(true, AuthorizationStatusAuthorized);
                        }
                    }
                 }];
            }
            break;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            Log(@"不允许访问定位---%ld", s);
            completion(false, AuthorizationStatusDenied);
            [_permission goSettingPage:@"定位权限没有开启，请前往设置中开启"];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            Log(@"授权且在未使用APP时使用定位");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            Log(@"授权且当APP使用中使用定位");
            break;
    }
}

/// 通知权限
- (void)takeNotificationAuthorityCompLetion: (void(^)(BOOL allow, AuthorizationStatus status))completion {
}

/// 相机权限
- (void)takeCameraAuthorityCompLetion: (void(^)(BOOL allow, AuthorizationStatus status))completion {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (authStatus) {
            case AVAuthorizationStatusAuthorized:
                Log(@"允许访问相机 --AVAuthorizationStatusAuthorized");
                if (completion) {
                    completion(true, AuthorizationStatusAuthorized);
                }
                break;
            case AVAuthorizationStatusRestricted:
            case AVAuthorizationStatusDenied:
                Log(@"不允许访问相机---%ld", authStatus);
                [_permission goSettingPage:@"相机权限没有开启，请前往设置中开启"];
                break;
            case AVAuthorizationStatusNotDetermined:
                {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        Log(@"只会调用一次，是否允许访问相机");
                        if (completion) {
                            if (!granted) {
                                Log(@"拒绝授权,不允许访问相机");
                                completion(false, AuthorizationStatusDenied);
                            }else {
                                Log(@"现在授权,允许访问相机");
                                completion(true, AuthorizationStatusAuthorized);
                            }
                        }
                     }];
                }
                break;
        }
    }else {
        Log(@"模拟器下不支持拍照");
    }
}

/// 相册权限
- (void)takeAlbumAuthorityCompLetion: (void(^)(BOOL allow, AuthorizationStatus status))completion {
    PHAuthorizationStatus authStatus;
    if (@available(iOS 14, *)) {
        authStatus = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    }else {
        authStatus = [PHPhotoLibrary authorizationStatus];
    }
    
    switch (authStatus) {
        case PHAuthorizationStatusAuthorized:
            Log(@"允许访问相册 --PHAuthorizationStatusAuthorized");
            if (completion) {
                completion(true, AuthorizationStatusAuthorized);
            }
            break;
        case PHAuthorizationStatusLimited:
            Log(@"用户已授权此应用程序进行有限照片库访问 -- PHAuthorizationStatusLimited");
            if (completion) {
                completion(true, AuthorizationStatusLimited);
            }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            Log(@"不允许访问相册---%ld", authStatus);
            [_permission goSettingPage:@"相册权限没有开启，请前往设置中开启"];
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            if (@available(iOS 14, *)) {
                [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
                    Log(@"iOS14以上 只会调用一次，是否允许访问相册 -- PHAuthorizationStatusNotDetermined");
                    if (completion) {
                        if (status == PHAuthorizationStatusRestricted) {
                            Log(@"拒绝授权,不允许访问相册 -- PHAuthorizationStatusRestricted");
                            completion(false, AuthorizationStatusRestricted);
                        }else if (status == PHAuthorizationStatusDenied) {
                            Log(@"拒绝授权,不允许访问相册 -- PHAuthorizationStatusDenied");
                            completion(false, AuthorizationStatusDenied);
                        }else if (status == PHAuthorizationStatusLimited) {
                            Log(@"已授权此应用程序进行有限照片库访问 -- PHAuthorizationStatusLimited");
                            completion(true, AuthorizationStatusLimited);
                        } else {
                            Log(@"现在授权,允许访问相册 -- PHAuthorizationStatusAuthorized");
                            completion(true, AuthorizationStatusAuthorized);
                        }
                    }
                }];
            }else {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    Log(@"低于iOS14只会调用一次，是否允许访问相册");
                    if (completion) {
                        if (status == PHAuthorizationStatusRestricted) {
                            Log(@"拒绝授权,不允许访问相册 -- PHAuthorizationStatusRestricted");
                            completion(false, AuthorizationStatusRestricted);
                        }else if (status == PHAuthorizationStatusDenied) {
                            Log(@"拒绝授权,不允许访问相册 -- PHAuthorizationStatusDenied");
                            completion(false, AuthorizationStatusDenied);
                        }else {
                            Log(@"现在授权,允许访问相册");
                            completion(true, AuthorizationStatusAuthorized);
                        }
                    }
                }];
            }
        }
            break;
    }
}

/// 通讯录权限
- (void)takeContactAuthorityCompLetion: (void(^)(BOOL allow, AuthorizationStatus status))completion {
    CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (authStatus) {
        case CNAuthorizationStatusAuthorized:
            Log(@"允许访问通讯录 --CNAuthorizationStatusAuthorized");
            if (completion) {
                completion(true, AuthorizationStatusAuthorized);
            }
            break;
        case CNAuthorizationStatusRestricted:
        case CNAuthorizationStatusDenied:
            Log(@"不允许访问通讯录---%ld", authStatus);
            [_permission goSettingPage:@"通讯录权限没有开启，请前往设置中开启"];
            break;
        case CNAuthorizationStatusNotDetermined:
            {
                CNContactStore *contactStore = [[CNContactStore alloc] init];
                 [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                     Log(@"只会调用一次，是否允许访问通讯录");
                     if (completion) {
                         if (!granted) {
                             Log(@"拒绝授权,不允许访问通讯录");
                             completion(false, AuthorizationStatusDenied);
                         }else {
                             Log(@"现在授权,允许访问通讯录");
                             completion(true, AuthorizationStatusAuthorized);
                         }
                     }
                 }];
            }
            break;
    }
}

/// 麦克风权限
- (void)takeMicAuthorityCompLetion: (void(^)(BOOL allow, AuthorizationStatus status))completion {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            Log(@"允许访问麦克风 --AVAuthorizationStatusAuthorized");
            if (completion) {
                completion(true, AuthorizationStatusAuthorized);
            }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            Log(@"不允许访问麦克风---%ld", authStatus);
            [_permission goSettingPage:@"麦克风权限没有开启，请前往设置中开启"];
            break;
        case AVAuthorizationStatusNotDetermined:
            {
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    Log(@"只会调用一次，是否允许访问麦克风");
                    if (completion) {
                        if (!granted) {
                            Log(@"拒绝授权,不允许访问麦克风");
                            completion(false, AuthorizationStatusDenied);
                        }else {
                            Log(@"现在授权,允许访问麦克风");
                            completion(true, AuthorizationStatusAuthorized);
                        }
                    }
                 }];
            }
            break;
    }
}

- (void)goSettingPage: (NSString *)message {
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *go = [UIAlertAction actionWithTitle:@"去打开权限" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString: UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:nil];
        }
    }];
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addAction:ok];
    [alertVc addAction:go];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVc animated:true completion:nil];
    
}

@end
