//
//  Event.m
//  TimeForest
//
//  Created by 肖志强 on 2020/10/9.
//

#import "Event.h"

@implementation Event

+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject {
    [[NSNotificationCenter defaultCenter]addObserver:observer selector:aSelector name:aName object:anObject];
}

+ (void)removeAllEventListener:(id)observer {
    [[NSNotificationCenter defaultCenter]removeObserver:observer];
}

+ (void)removeEventListener:(id)observer name:(NSNotificationName)aName object:(id)anObject {
    [[NSNotificationCenter defaultCenter]removeObserver:observer name:aName object:anObject];
}

+ (void)postNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

+ (void)postNotificationName:(NSNotificationName)aName {
    [[NSNotificationCenter defaultCenter]postNotificationName:aName object:nil];
}

+ (void)postNotificationName:(NSNotificationName)aName object:(id)anObject {
    [[NSNotificationCenter defaultCenter]postNotificationName:aName object:anObject];
}

+ (void)postNotificationName:(NSNotificationName)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    [[NSNotificationCenter defaultCenter]postNotificationName:aName object:anObject userInfo:aUserInfo];
}

@end
