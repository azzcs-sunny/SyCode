//
//  Photo.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/11/3.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface Photo : NSObject
// 相片名称
@property(nonatomic, copy)NSString *name;

// 缩略图
@property(nonatomic, strong)UIImage *thumb;

// 相片集缓存 ios8以上为PHAsset ios8以下为ALAsset
@property(nonatomic, strong)PHAsset *asset;

// 相片本地标识 ios8以上为localIdentifier ios8以为下照片的url
@property(nonatomic, strong)NSString *identifier;

// 相片所在格子
@property(nonatomic, assign)NSInteger index;

// 本地引用链接
@property(nonatomic, strong)NSURL *url;

// 文件类型
@property(nonatomic, assign)NSString *type;

// 旋转
@property(nonatomic, assign)NSInteger orientation;

//
@property(nonatomic, assign)BOOL thumbCached;

// 
@property(nonatomic, assign)BOOL originCached;
@end

NS_ASSUME_NONNULL_END
