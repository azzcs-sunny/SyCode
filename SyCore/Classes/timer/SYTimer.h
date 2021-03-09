//
//  SYTimer.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, SYTaskType) {
    SYTaskTypeTimer,
    SYTaskTypeCADisplayLink
};

@protocol SYTimerDelegate <NSObject>

- (void)fireTaskName: (NSString *)taskName any: (id)any;

@optional
- (void)finishedTaskName: (NSString *)taskName;

@end

@interface SYTask: NSObject

- (instancetype)initWithName: (NSString *)name interval: (CGFloat)interval repeatTimes: (NSInteger)repeatTimes data: (id)data  delegate: (id <SYTimerDelegate>)delegate type: (SYTaskType)type fire: (void(^)(NSString *taskName, id data))fire finished: (void(^)(NSString *taskName))finished;

- (instancetype)initWithName: (NSString *)name interval: (CGFloat)interval fire: (void(^)(NSString *taskName, id data))fire;

- (instancetype)initWithName: (NSString *)name interval: (CGFloat)interval delegate: (id <SYTimerDelegate>)delegate;

@end

@interface SYTimerTask: NSObject

- (instancetype)initWithTask: (SYTask *)task offset: (CGFloat)offset;

@end

@interface SYTimer : NSObject<NSCopying>

+ (instancetype)shared;

/// 将任务添加到队列
- (void)addToQueueTask: (SYTask *)task;

/// 暂停计时
- (void)pauseTaskWithName: (NSString *)name;

/// 开始计时
- (void)restartTaskWithName: (NSString *)name;

/// 从队列删除该定时器
- (void)removeFromQueueName: (NSString *)name;

/// 重制定时器
- (void)resetTaskWithName: (NSString *)name;

/// 重制并且开始计时
- (void)resetAndStartTaskWithName: (NSString *)name;

/// 防抖
- (void)debounceAction: (void(^)(void))action;

/// 通过name获取该任务， 如果不存在则返回nil
- (SYTask *)getFromQueueName: (NSString *)name;

/// 通过name查询队列中是否存在该任务
- (BOOL)existFromQueueName: (NSString *)name;

- (void)suspend;

- (void)resume;
@end

NS_ASSUME_NONNULL_END
