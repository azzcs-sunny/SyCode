//
//  File.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/10/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface File : NSObject<NSCopying>

+ (instancetype)shared;

/// 临时目录的路径
- (NSString *)pathWithTemporaryDirFileName: (NSString *)name;

/// 缓存的路径
- (NSString *)pathWithCacheDirFileName: (NSString *)name;

/// 数据目录的路径
- (NSString *)pathWithDataDirFileName: (NSString *)name;

/// 系统缓存的路径
- (NSString *)pathWithSystemCacheDirFileName: (NSString *)name;

/// 删除文件目录中的数据
- (void)deleteDataInTemporaryDirFileName: (NSString *)name;

/// 将数据写入文档目录
- (void)writeDataToTemporaryDir: (NSString *)name data: (NSData *)data callback: (void(^)(BOOL b))callback;

/// 从文档目录读取数据
- (void)readDataFromTemporaryDir: (NSString *)name callback: (void(^)(NSData *d))callback;

/// 文件是否存在于目录中
- (BOOL)existInDataDir: (NSString *)name;

/// 文件路径是否存在
- (BOOL)existsPath: (NSString *)path;

/// 从路径复制文件到指定文件目录下
- (void)copyFileToDocumentDirectoryFromPath: (NSString *)path dirName: (NSString *)dir filaName: (NSString *)name callback: (void(^)(BOOL b))callback;

/// 从路径移动文件到指定文件目录下
- (void)moveItemAtPath: (NSString *)atPath toPath: (NSString *)toPath callback: (void(^)(BOOL b))callback;

/// 删除系统缓存目录中的数据
- (void)deleteDataInSystemCacheDirFileName: (NSString *)name;

/// 删除数据
- (void)deleteDataWithPath: (NSString *)path;

/// 文件大小
- (CGFloat)getSizeWithPath: (NSString *)path;

@end

NS_ASSUME_NONNULL_END
