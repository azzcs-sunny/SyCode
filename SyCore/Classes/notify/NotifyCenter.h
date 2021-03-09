//
//  NotifyCenter.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CommandType) {
    /// 系统消息
    CommandTypeMessage = 0,
    /// 卖出
    CommandTypeSell,
    /// 赠送
    CommandTypeGive,
    /// 拉取日志
    CommandTypeLog,
};

@interface NotifyCenter : NSObject<NSCopying>

+ (instancetype)shared;

- (void)addTags;

- (void)removeTags;

- (void)addAlias: (NSString *)userId;

- (void)removeAlias: (NSString *)userId;

- (void)registDelegate: (id)delegate launchOptions: (NSDictionary *)launchOptions;

- (void)handleRemoteNotificationUserInfo: (NSDictionary *)userInfo;

- (void)setBadgeValue: (NSInteger)value;

@end

NS_ASSUME_NONNULL_END
