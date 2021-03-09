//
//  Event.h
//  TimeForest
//
//  Created by 肖志强 on 2020/10/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Event : NSObject

+ (void)removeAllEventListener:(id)observer;

+ (void)postNotification:(NSNotification *)notification;

+ (void)removeEventListener:(id)observer name:(nullable NSNotificationName)aName object:(nullable id)anObject;

+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject;

+ (void)postNotificationName:(NSNotificationName)aName;

+ (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject;

+ (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;

@end

NS_ASSUME_NONNULL_END
