//
//  NotifyCenter.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/12.
//

#import "NotifyCenter.h"
#import <UserNotifications/UserNotifications.h>
#import <JPUSHService.h>
#import "Cache.h"
#import "Event.h"
#import "EventType.h"
#import "LogHeader.h"

@implementation NotifyCenter

static NotifyCenter *_notify = nil;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _notify = [[super allocWithZone:NULL] init];
    });
    return _notify;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NotifyCenter shared];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [NotifyCenter shared];
}

- (void)registDelegate: (id)delegate launchOptions: (NSDictionary *)launchOptions jPushAppkey: (NSString *)appkey isProduction: (BOOL)isProduction {
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc]init];
    entity.types = JPAuthorizationOptionAlert | JPAuthorizationOptionSound | JPAuthorizationOptionBadge;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:delegate];
    [JPUSHService setupWithOption:launchOptions appKey:appkey channel:@"App Store" apsForProduction:!isProduction];
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if (resCode == 0) {
            if (registrationID != nil) {
                [[Cache shared]setCacheValue:registrationID forKey:@"registrationID"];
            }
            Log(@"get registration id complete:%@", registrationID);
        }else {
            Log(@"get registration id failed");
        }
    }];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
}


- (void)addTags {
    NSSet * tagsSet = [[NSSet alloc] initWithArray:@[@"users"]];
    [JPUSHService addTags:tagsSet completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        
    } seq:1];
}

- (void)removeTags {
    NSSet * tagsSet = [[NSSet alloc] initWithArray:@[@"users"]];
    [JPUSHService deleteTags:tagsSet completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        
    } seq:1];
}

- (void)addAlias: (NSString *)userId {
    Log(@"注册别名Alias");
    [JPUSHService setAlias:userId completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        Log(@"addAlias ----iResCode:%ld \n iAlias:%@ \n seq:%ld",(long)iResCode, iAlias, (long)seq);
    } seq:[userId integerValue]];
}

- (void)removeAlias: (NSString *)userId {
    Log(@"删除别名Alias");
    [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        Log(@"deleteAlias ----   iResCode:%ld \n iAlias:%@ \n seq:%ld",(long)iResCode, iAlias, (long)seq);
    } seq:[userId integerValue]];
}

- (void)networkDidReceiveMessage: (NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    Log(@"透传: %@", userInfo);
    [self onMessage:userInfo type:1];
}

- (void)handleRemoteNotificationUserInfo: (NSDictionary *)userInfo {
    [JPUSHService handleRemoteNotification:userInfo];
    Log(@"通知: %@", userInfo);
    [self onMessage:userInfo type:0];
}

- (void)onMessage: (NSDictionary *)userInfo type: (NSInteger)type {
    NSDictionary *extras = userInfo[@"extras"];
    [Event postNotificationName:NOTIFY_MESSAGE object:nil userInfo:@{@"type": extras[@"type"], @"userInfo": extras, @"content_type": userInfo[@"content_type"]}];
}


- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification  API_AVAILABLE(ios(10.0)){
    NSDictionary *userInfo = notification.request.content.userInfo;
    if (notification != nil && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        Log(@"从通知界面直接进入应用");
    }else {
        Log(@"从通知设置界面进入应用");
    }
    Log(userInfo);
}

- (void)setBadgeValue: (NSInteger)value {
    [JPUSHService setBadge:value];
    [UIApplication sharedApplication].applicationIconBadgeNumber = value;
}

- (void)dealloc
{
    [Event removeEventListener:self name:kJPFNetworkDidReceiveMessageNotification object:nil];
}

@end
