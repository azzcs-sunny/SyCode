//
//  Cache.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Cache : NSObject<NSCopying>

+ (instancetype)shared;

/** 存储 */
- (void)setCacheValue: (id)value forKey: (NSString *)key;

/** 取值 */
- (id)getCacheValueForKey: (NSString *)key;

/** 删除 */
- (void)removeCacheObjectForKey: (NSString *)key;

- (BOOL)synchronize;

- (void)clearWebViewCache;

@end

NS_ASSUME_NONNULL_END
