//
//  Log.m
//  TimeForest
//
//  Created by 肖志强 on 2020/10/11.
//

#import "Log.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "NSDate+Category.h"
#import "Device.h"
#import "Cache.h"
#import <SSZipArchive/SSZipArchive.h>

@implementation Log

static DDFileLogger *fileLogger = nil;
static NSString     *stsPath    = nil;

+ (instancetype (^)(const char * _Nonnull file, int line, const char * _Nonnull function, id info, ...))verboseInfo {
    return ^ id (const char * _Nonnull file, int line, const char * _Nonnull function, id info, ...) {
        va_list ap;
        NSString *body = @"";
        if (info) {
            va_start(ap, info);
            if (![info hasSuffix: @"\n"]) {
                info = [info stringByAppendingString: @"\n"];
            }
            body = [[NSString alloc] initWithFormat:info arguments:ap];
            va_end(ap);
        }
        
        #if DEBUG
        NSLog(@"\n********************************************************************\n\tTime: %@\n\tThread: %@\n\tQueue: %@\n\tFile: %s\n\tFunction: %s\n\tLine: %d\n\tVerbose: %@\n********************************************************************\n", [NSDate nowUntilisecond], [NSThread currentThread], [Log currentQueueName], file, function, line, body);
        #else
        DDLogVerbose(@"\n********************************************************************\n\tTime: %@\n\tThread: %@\n\tQueue: %@\n\tFile: %s\n\tFunction: %s\n\tLine: %d\n\tVerbose: %@\n********************************************************************\n", [NSDate nowUntilisecond], [NSThread currentThread], [Log currentQueueName], file, function, line, body);
        #endif
        return self;
    };
}

+ (NSString *)currentQueueName {
    return [NSString stringWithCString:dispatch_queue_get_label(nil) encoding:NSUTF8StringEncoding];
}

+ (void)initialStsPath: (NSString *)path {
    //    if (@available(iOS 10.0, *)) {
    //        [DDLog addLogger:[DDOSLogger sharedInstance] withLevel:DDLogLevelAll];
    //    }
    stsPath = path;
    
    if ([DDTTYLogger sharedInstance] != nil) {
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelAll];
    }
    fileLogger = [[DDFileLogger alloc]init];
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger withLevel:DDLogLevelAll];
}

+ (void)uploadLogFilePostApiPath: (nullable NSString *)postApiPath success: (void(^)( void))success failed: (void(^)(void))failed {
//    NSString *logDir = fileLogger.logFileManager.logsDirectory;
//    NSArray <NSString *>*paths = fileLogger.logFileManager.sortedLogFilePaths;
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
//    dispatch_queue_t mQueue = dispatch_get_main_queue();
//    if (paths.count > 0) {
//        dispatch_async(queue, ^{
//            NSString *fileName =[NSString stringWithFormat:@"%@_%@_%@_", [Device bundleID], [Device versionString], [Device build]];
//            if (![[Global shared].userInfo.ID isEqualToString:@""]) {
//                fileName = [NSString stringWithFormat:@"%@_id_%@",fileName, [Global shared].userInfo.ID];
//            }else {
//                fileName = [NSString stringWithFormat:@"%@_unknown_%@", fileName, [Device deviceId]];
//            }
//            fileName = [NSString stringWithFormat:@"%@_%@.zip",fileName, [NSDate nowUntilisecond]];
//            [SSZipArchive createZipFileAtPath:[NSString stringWithFormat:@"%@/%@", logDir, fileName] withFilesAtPaths:paths];
//            if ([[File shared]existsPath:[NSString stringWithFormat:@"%@/%@", logDir, fileName]]) {
//                dispatch_async(mQueue, ^{
//                    if (stsPath != nil) {
//                        [[QiniuUpload shared]uploadFile:[NSString stringWithFormat:@"%@/%@", logDir, fileName] fileName: fileName success:^(NSString * _Nonnull appendString) {
//                            if (postApiPath != nil) {
////                                [[NetWork shared]post:postApiPath hud:@"正在上传" params:nil];
//                                dispatch_async(queue, ^{
//                                    [[File shared]deleteDataWithPath:[NSString stringWithFormat:@"%@/%@", logDir, fileName]];
//                                    for (NSString *path in paths) {
//                                        [[File shared]deleteDataWithPath:path];
//                                    }
//                                });
//                                dispatch_async(mQueue, ^{
//                                    success();
//                                });
//                            }
//                        }];
//                    }
//                });
//            }else {
//                Log(@"文件路径是否存在");
//                dispatch_async(mQueue, ^{
//                    failed();
//                });
//            }
//        });
//    }else {
//        Log(@"没有日志可以提交");
//        dispatch_async(mQueue, ^{
//            failed();
//        });
//    }
}

@end
