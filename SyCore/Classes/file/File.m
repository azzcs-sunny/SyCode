//
//  File.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/30.
//

#import "File.h"
#import "Device.h"
#import "LogHeader.h"

@interface File()

@property(nonatomic, strong)NSString *baseBirPath;

@end
@implementation File

static File                         *_file = nil;
static NSString                     *TEMP_DIR = @"temp";
static NSString                     *CACHE_DIR = @"cache";
static NSString                     *DATA_DIR = @"data";

+(instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _file = [[super allocWithZone:NULL]init];
    });
    return _file;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [File shared];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [File shared];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createAlldir];
    }
    return self;
}

- (void)createAlldir {
    self.baseBirPath = [NSString stringWithFormat:@"%@/%@/", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0], [Device bundleID]];
    NSArray <NSString *>*folders = @[TEMP_DIR, CACHE_DIR, DATA_DIR];
    for (int i = 0; i < folders.count; i++) {
        NSString *foldir = folders[i];
        NSString *dir = [NSString stringWithFormat:@"%@%@", self.baseBirPath, foldir];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:dir] == false) {
            Log(@"create %@", foldir);
            NSError *error;
            BOOL b = [fileManager createDirectoryAtPath:dir withIntermediateDirectories:true attributes:nil error:&error];
            if (!b) {
                Log(@"error: %@", &error);
            }
        }
    }
}

#pragma mark - 公开方法
/// 临时目录的路径
- (NSString *)pathWithTemporaryDirFileName: (NSString *)name {
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", _file.baseBirPath, TEMP_DIR, name];
    Log(@"%@",path);
    return  path;
}

/// 缓存的路径
- (NSString *)pathWithCacheDirFileName: (NSString *)name {
    NSString *path = [NSString stringWithFormat:@"%@%@/%@", _file.baseBirPath, CACHE_DIR, name];
    Log(@"%@",path);
    return  path;
}

/// 数据目录的路径
- (NSString *)pathWithDataDirFileName: (NSString *)name {
    NSString *path = [NSString stringWithFormat:@"%@%@/%@", _file.baseBirPath, DATA_DIR, name];
    Log(@"%@",path);
    return  path;
}

/// 系统缓存的路径
- (NSString *)pathWithSystemCacheDirFileName: (NSString *)name {
    NSString *path = [NSString stringWithFormat:@"%@%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true)[0], [Device bundleID], name];
    return path;
}

/// 删除文件目录中的数据
- (void)deleteDataInTemporaryDirFileName: (NSString *)name {
    [_file deleteDataInDocumentDirectoryDirName:TEMP_DIR filaName:name];
}

/// 将数据写入文档目录
- (void)writeDataToTemporaryDir: (NSString *)name data: (NSData *)data callback: (void(^)(BOOL b))callback {
    [_file writeDataToDocumentDirectoryDirName:TEMP_DIR filaName:name data:data callback:callback];
}

/// 从文档目录读取数据
- (void)readDataFromTemporaryDir: (NSString *)name callback: (void(^)(NSData *d))callback {
    [_file readDataFromDocumentDirectoryDirName:TEMP_DIR filaName:name callback:callback];
}

/// 文件是否存在于目录中
- (BOOL)existInDataDir: (NSString *)name {
    NSString *path = [self pathWithDataDirFileName:name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

/// 文件路径是否存在
- (BOOL)existsPath: (NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

/// 从路径复制文件到指定文件目录下
- (void)copyFileToDocumentDirectoryFromPath: (NSString *)path dirName: (NSString *)dir filaName: (NSString *)name callback: (void(^)(BOOL b))callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        NSString *dirStr = [NSString stringWithFormat:@"%@%@", _file.baseBirPath, dir];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isBool = false;
        if ([fileManager fileExistsAtPath:path]) {
            NSError *error;
            [fileManager copyItemAtPath:path toPath:[NSString stringWithFormat:@"%@/%@", dirStr, name] error:&error];
            isBool = true;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(isBool);
        });
    });
}

/// 从路径移动文件到指定文件目录下
- (void)moveItemAtPath: (NSString *)atPath toPath: (NSString *)toPath callback: (void(^)(BOOL b))callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_queue_t mQueue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSString *dirStr = toPath;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![toPath.pathExtension  isEqual: @""]) {
            dirStr = toPath.stringByDeletingLastPathComponent;
        }
        if([fileManager fileExistsAtPath:dirStr] == false) {
            NSError *error;
            BOOL success = [fileManager createDirectoryAtPath:dirStr withIntermediateDirectories:true attributes:nil error:&error];
            if (!success) {
                Log(@"error when createDirectory in moveItem %@", &error);
                dispatch_async(mQueue, ^{
                    if (callback) {
                        callback(false);
                    }
                });
                return;
            }
        }
        
        NSError *error;
        BOOL moveItrmBool = [fileManager moveItemAtPath:atPath toPath:toPath error:&error];
        if (moveItrmBool) {
            dispatch_async(mQueue, ^{
                if (callback) {
                    callback(true);
                }
            });
        }else {
            Log(@"%@", error.localizedDescription);
            dispatch_async(mQueue, ^{
                if (callback) {
                    callback(false);
                }
            });
        }
    });
}

/// 删除系统缓存目录中的数据
- (void)deleteDataInSystemCacheDirFileName: (NSString *)name {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue, ^{
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true)[0], [Device bundleID], name];
        [weakSelf deleteDataWithPath: path];
    });
}

/// 删除数据
- (void)deleteDataWithPath: (NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path] == true) {
        if ([fileManager isDeletableFileAtPath:path]) {
            NSError *error;
           BOOL success = [fileManager removeItemAtPath:path error:&error];
            if (success) {
                Log(@"delete file %@ successfully", path);
            }else {
                Log(@"error when delete file path is:%@ and error is %@", path, &error);
            }
        }
    }
}

/// 文件大小
- (CGFloat)getSizeWithPath: (NSString *)path {
    NSError *error;
    NSDictionary<NSFileAttributeKey, id> *dict = [[NSFileManager defaultManager]attributesOfItemAtPath:path error:&error];
    if (dict[NSFileSize]) {
        return [dict[NSFileSize] floatValue] / 1024.0 / 1024.0;
    }
    return 0;
}

#pragma mark - 私有方法, 不对外公开

/// 删除文件目录中的数据
- (void)deleteDataInDocumentDirectoryDirName: (NSString *)dir filaName: (NSString *)name {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue, ^{
        NSString *path = [NSString stringWithFormat:@"%@%@/%@", weakSelf.baseBirPath, dir, name];
        [weakSelf deleteDataWithPath:path];
    });
}

/// 将数据写入文档目录
- (void)writeDataToDocumentDirectoryDirName: (NSString *)dir filaName: (NSString *)name data: (NSData *)data callback: (void(^)(BOOL b))callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_queue_t mQueue = dispatch_get_main_queue();
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue, ^{
        NSString *dirStr = [NSString stringWithFormat:@"%@%@", weakSelf.baseBirPath, dir];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:dirStr] == false) {
            Log(@"%@ is not exist so can not read data", dirStr);
            [fileManager createDirectoryAtPath:dirStr withIntermediateDirectories:true attributes:nil error:nil];
        }
        NSString *file = [NSString stringWithFormat:@"%@/%@", dirStr, name];
        Log(@"write file to path: %@", file);
        BOOL b = [fileManager createFileAtPath:file contents:data attributes:nil];
        dispatch_async(mQueue, ^{
            callback(b);
        });
    });
}

/// 从文档目录读取数据
- (void)readDataFromDocumentDirectoryDirName: (NSString *)dir filaName: (NSString *)name callback: (void(^)(NSData *d))callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_queue_t mQueue = dispatch_get_main_queue();
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue, ^{
        NSString *dirStr = [NSString stringWithFormat:@"%@%@", weakSelf.baseBirPath, dir];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:dirStr] == false) {
            Log(@"%@ is not exist so can not read data", dirStr);
            dispatch_async(mQueue, ^{
                callback(nil);
            });
        }else {
            NSString *path = [NSString stringWithFormat:@"%@/%@", dirStr, name];
            Log(@"read file from path: %@", path);
            NSData *da = [NSData dataWithContentsOfFile:path];
            dispatch_async(mQueue, ^{
                callback(da);
            });
        }
    });
}

@end
