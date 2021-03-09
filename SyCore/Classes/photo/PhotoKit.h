//
//  PhotoKit.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/11/3.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "Album.h"
#import "Photo.h"
#import <AssetsLibrary/AssetsLibrary.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoKit : NSObject

+(instancetype)shared;

/// 获取相册列表
- (void)allAlbumnsWithMediaType: (PHAssetMediaType)mediaType callBack: (void(^)(NSArray <Album *>*obj))callBack;

/// 获取有限相册图片列表
- (void)partAlbumWithMediaType:(PHAssetMediaType)mediaType callBack: (void(^)(NSArray <Photo *>*obj, NSArray<Album *>  * _Nonnull albums))callBack;

/// 获取某个相册中的列表
- (void)photosOfAlbumWithMediaType: (PHAssetMediaType)mediaType album: (Album *)album callBack: (void(^)(NSArray <Photo *>*obj))callBack;

/// 获取相册每个列表的缩略图，名字，数量
- (Album *)getAlbumAssetCollection: (PHAssetCollection *)assetCollection options: (PHFetchOptions *)options thumbSize: (CGSize)thumbSize;

/// 根据PHAsset获取缩略图
- (void)getAlbumAsset: (PHAsset *)asset options: (PHFetchOptions *)options thumbSize: (CGSize)thumbSize callBack: (void(^)(UIImage *img))callBack;

/// 为以后使用的资源准备图像。当你调用这个方法，Photos会开始在后台获取图像数据并生成缩略图
- (void)startCachingForAssets: (NSArray <PHAsset *>*)assets;
- (void)startCachingForAssets: (NSArray <PHAsset *>*)assets targetSize: (CGSize)targetSize options: (PHImageRequestOptions *)options;

/// 这个方法通过给定的options取消对给定的资源的图片缓存。当不再需要这些图片缓存的时候使用这个方法来取消缓存（有可能正在缓存过程中）
- (void)stopCachingForAssets: (NSArray <PHAsset *>*)assets;
- (void)stopCachingForAssets: (NSArray <PHAsset *>*)assets targetSize: (CGSize)targetSize options: (PHImageRequestOptions *)options;

/// 取消所有正在进行过程中的图像缓存
- (void)stopAllCaching;

/// 通过PHAsset获取缩略图
- (void)thubByIdentifierPhoto: (Photo *)photo callBack: (void(^)(UIImage * _Nullable image))callBack;
- (void)thubByIdentifierPhoto: (Photo *)photo targetSize: (CGSize)targetSize callBack: (void(^)(UIImage * _Nullable image))callBack;

/// 通过PHAsset获取清晰图
- (void)photoByIdentifierPhoto: (Photo *)photo callBack: (void(^)(UIImage * _Nullable image, BOOL isPlaceholder))callBack;
- (void)photoByIdentifierPhoto: (Photo *)photo targetSize: (CGSize)targetSize callBack: (void(^)(UIImage * _Nullable image, BOOL isPlaceholder))callBack;

/// 根据localIdentifier返回PHAsset
- (void)photoByIdentifier: (NSString *)identifier callBack: (void(^)(UIImage * _Nullable image, NSString * _Nullable type, NSURL * _Nullable url))callBack;
- (void)photoByIdentifier: (NSString *)identifier targetSize: (CGSize)targetSize callBack: (void(^)(UIImage * _Nullable image, NSString * _Nullable type, NSURL * _Nullable url))callBack;

/// 通过PHAsset获得视频URL
- (void)avasetByPHAssetWithPHAsset: (PHAsset *)asset callBack: (void(^)(AVAsset * _Nullable avasset, AVAudioMix * _Nullable avaudioMix, NSDictionary * _Nullable dict))callBack;

- (void)savePhotoImage: (UIImage *)image completionTarget: (id)target completion: (SEL)completion;

- (void)saveFileToAlbumUrl: (NSURL *)url completion: (void(^)(void))completion;

///获取所有相册， 并且获取最后一张照片
- (void)getLastPhoto: (void(^)(Photo * _Nullable photo))callback;

/// 将视频转成mp4并且放到指定路径下    注意:所有回调都在子线程中
- (void)importVideoAsset: (PHAsset *)asset toPath: (NSString *)toPath onStart: (void(^)(AVAssetExportSession * _Nullable session))start onComplete: (void(^)(void))complete onFailed: (void(^)(NSError * _Nullable error))failed;

@end

NS_ASSUME_NONNULL_END
