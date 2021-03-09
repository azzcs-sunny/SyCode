//
//  Cache.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/10.
//

#import "Cache.h"

@implementation Cache

static Cache *_cache = nil;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [[super allocWithZone:NULL]init];
    });
    return _cache;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [Cache shared];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [Cache shared];
}

- (void)setCacheValue:(id)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
}

- (id)getCacheValueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults]objectForKey:key];
}

- (void)removeCacheObjectForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:key];
}

- (BOOL)synchronize {
    return [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)clearWebViewCache {
    [[NSURLCache sharedURLCache]removeAllCachedResponses];
    [NSURLCache sharedURLCache].diskCapacity = 0;
    [NSURLCache sharedURLCache].memoryCapacity = 0;
}

@end
