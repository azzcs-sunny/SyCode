//
//  Log.h
//  TimeForest
//
//  Created by 肖志强 on 2020/10/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Log : NSObject

+ (void)initialStsPath: (NSString *)path;

+ (instancetype (^)(const char * _Nonnull file, int line, const char * _Nonnull function, id info, ...))verboseInfo;

+ (void)uploadLogFilePostApiPath: (nullable NSString *)postApiPath success: (void(^)( void))success failed: (void(^)(void))failed;
@end

NS_ASSUME_NONNULL_END
