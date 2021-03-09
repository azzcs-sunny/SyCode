//
//  PhotoKit.m
//  SunnyCore
//
//  Created by 肖志强 on 2020/11/3.
//

#import "PhotoKit.h"
#import <MBProgressHUD.h>
#import "UIColor+Category.h"
#import "LogHeader.h"

@interface PhotoKit()

@property (nonatomic, strong) PHCachingImageManager *imageManager;

@property (nonatomic, strong) PHImageRequestOptions *thumbRequestOptions;

@property (nonatomic, strong) PHImageRequestOptions *originRequestOptions;

@property (nonatomic, assign) CGSize thumbSize;

@property (nonatomic, strong) MBProgressHUD *hud;
@end
@implementation PhotoKit

static PhotoKit *_photo = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageManager = [[PHCachingImageManager alloc]init];
        self.thumbRequestOptions = [PHImageRequestOptions new];
        self.thumbRequestOptions.synchronous = false;
        self.thumbRequestOptions.networkAccessAllowed = true;
        /// 必须同步 否则会获得多张结果
        self.originRequestOptions = [PHImageRequestOptions new];
        self.originRequestOptions.synchronous = true;
        self.originRequestOptions.networkAccessAllowed = true;
        self.originRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        self.originRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        self.hud = nil;
        __weak typeof(self) weakSelf = self;
        self.originRequestOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.hud == nil) {
                    weakSelf.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:true];
                    weakSelf.hud.label.text = @"正在加载";
                }
                if (progress >= 1.0) {
                    [weakSelf.hud hideAnimated:true];
                }
            });
        };
        self.thumbSize = CGSizeMake(150, 150);
    }
    return self;
}

+(instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _photo = [[super allocWithZone:NULL]init];
    });
    return _photo;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [PhotoKit shared];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [PhotoKit shared];
}

/// 获取Limited模式下的相册列表
- (void)partAlbumWithMediaType:(PHAssetMediaType)mediaType callBack: (void(^)(NSArray <Photo *>*obj, NSArray<Album *>* _Nonnull albums))callBack {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray <Photo *>*photos = [NSMutableArray array];
        PHFetchOptions *options = [PHFetchOptions new];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending: true]];
        PHFetchResult <PHAsset *>*result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Photo *model = [Photo new];
            model.name = [obj valueForKey:@"filename"];
            model.identifier = obj.localIdentifier;
            model.index = idx;
            model.asset = obj;
            [photos addObject:model];
        }];
        
        [_photo newPhotos:photos callBack:^(NSArray<Photo *> *obj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Album *album = [Album new];
                album.name = @"可访问的照片";
                album.count = 1;
                [_photo getAlbumAsset:obj.firstObject.asset options:options thumbSize:self.thumbSize callBack:^(UIImage *img) {
                    album.thumb = img;
                    if (callBack) {
                        callBack(obj, @[album]);
                    }
                }];
            });
        }];
    });
}

- (void)newPhotos: (NSMutableArray <Photo *> *)photos callBack: (void(^)(NSArray <Photo *>*obj))callBack {
    __block NSMutableArray <Photo *>*ps = [NSMutableArray array];
    [photos enumerateObjectsUsingBlock:^(Photo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.imageManager requestImageForAsset:obj.asset targetSize:self.thumbSize contentMode:PHImageContentModeAspectFit options:self.originRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result != nil) {
                [ps addObject:obj];
            }
            if (photos.count - 1 == idx) {
                if (callBack) {
                    callBack(ps);
                }
            }
        }];
    }];
}

/// 获取相册列表
- (void)allAlbumnsWithMediaType: (PHAssetMediaType)mediaType callBack: (void(^)(NSArray <Album *>*obj))callBack {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray <Album *>*albums = [NSMutableArray array];
        PHFetchOptions *options = [PHFetchOptions new];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending: true]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", mediaType];
        PHFetchResult<PHAssetCollection *> *smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        [smartAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Album *model = [_photo getAlbumAssetCollection:obj options:options thumbSize:_photo.thumbSize];
            if (model != nil) {
                [albums addObject:model];
            }
        }];

        PHFetchResult<PHAssetCollection *> *userAlbum =  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        [userAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Album *model = [_photo getAlbumAssetCollection:obj options:options thumbSize:_photo.thumbSize];
            if (model != nil) {
                [albums addObject:model];
            }
        }];

        //根据数量进行排序，如果数量一致则按照name排序
        NSSortDescriptor *countDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:false];
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:false];
        albums = [albums sortedArrayUsingDescriptors:@[countDescriptor, nameDescriptor].mutableCopy].mutableCopy;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                callBack(albums);
            }
        });
    });
}

/// 获取某个相册中的列表
- (void)photosOfAlbumWithMediaType: (PHAssetMediaType)mediaType album: (Album *)album callBack: (void(^)(NSArray <Photo *>*obj))callBack {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray <Photo *>*albums = [NSMutableArray array];
        PHFetchOptions *options = [PHFetchOptions new];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending: true]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", mediaType];
        PHFetchResult<PHAsset *> *assetFetchResult = [PHAsset fetchAssetsInAssetCollection:album.collection options:options];
        [assetFetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Photo *model = [Photo new];
            model.name = [obj valueForKey:@"filename"];
            model.identifier = obj.localIdentifier;
            model.index = idx;
            model.asset = obj;
            [albums addObject:model];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                callBack(albums);
            }
        });
    });
}

/// 获取相册每个列表的缩略图，名字，数量
- (Album *)getAlbumAssetCollection: (PHAssetCollection *)assetCollection options: (PHFetchOptions *)options thumbSize: (CGSize)thumbSize {
    PHFetchResult<PHAsset *> *assetFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
    if (assetFetchResult.count > 0) {
        Album *model = [Album new];
        model.name = assetCollection.localizedTitle;
        model.count = assetFetchResult.count;
        if (assetFetchResult.lastObject != nil) {
            [_photo getAlbumAsset:assetFetchResult.lastObject options:options thumbSize:thumbSize callBack:^(UIImage *img) {
                model.thumb = img;
            }];
        }
        model.collection = assetCollection;
        return model;
    }
    return nil;
}

/// 根据PHAsset获取缩略图
- (void)getAlbumAsset: (PHAsset *)asset options: (PHFetchOptions *)options thumbSize: (CGSize)thumbSize callBack: (void(^)(UIImage *img))callBack {
    [self.imageManager requestImageForAsset:asset targetSize:thumbSize contentMode:PHImageContentModeAspectFit options:self.thumbRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (callBack) {
            callBack(result);
        }
    }];
}

/// 为以后使用的资源准备图像。当你调用这个方法，Photos会开始在后台获取图像数据并生成缩略图
- (void)startCachingForAssets: (NSArray <PHAsset *>*)assets {
    [_photo startCachingForAssets:assets targetSize:PHImageManagerMaximumSize options:self.thumbRequestOptions];
}

- (void)startCachingForAssets: (NSArray <PHAsset *>*)assets targetSize: (CGSize)targetSize options: (PHImageRequestOptions *)options {
    /// 是否缓存高质量图片
    self.imageManager.allowsCachingHighQualityImages = false;
    [self.imageManager startCachingImagesForAssets:assets targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options];
}


/// 这个方法通过给定的options取消对给定的资源的图片缓存。当不再需要这些图片缓存的时候使用这个方法来取消缓存（有可能正在缓存过程中）
- (void)stopCachingForAssets: (NSArray <PHAsset *>*)assets {
    [_photo stopCachingForAssets:assets targetSize:PHImageManagerMaximumSize options:self.thumbRequestOptions];
}

- (void)stopCachingForAssets: (NSArray <PHAsset *>*)assets targetSize: (CGSize)targetSize options: (PHImageRequestOptions *)options {
    [self.imageManager stopCachingImagesForAssets:assets targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options];
}

/// 取消所有正在进行过程中的图像缓存
- (void)stopAllCaching {
    [self.imageManager stopCachingImagesForAllAssets];
}

/// 通过PHAsset获取缩略图
- (void)thubByIdentifierPhoto: (Photo *)photo callBack: (void(^)(UIImage * _Nullable image))callBack {
    [_photo thubByIdentifierPhoto:photo targetSize:self.thumbSize callBack:callBack];
}

- (void)thubByIdentifierPhoto: (Photo *)photo targetSize: (CGSize)targetSize callBack: (void(^)(UIImage * _Nullable image))callBack {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.imageManager requestImageForAsset:photo.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:self.thumbRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callBack) {
                    callBack(result);
                }
            });
        }];
    });
}

/// 通过PHAsset获取清晰图
- (void)photoByIdentifierPhoto: (Photo *)photo callBack:(nonnull void (^)(UIImage * _Nullable, BOOL isPlaceholder))callBack {
    [_photo photoByIdentifierPhoto:photo targetSize:PHImageManagerMaximumSize callBack:callBack];
}

- (void)photoByIdentifierPhoto: (Photo *)photo targetSize: (CGSize)targetSize callBack: (void(^)(UIImage * _Nullable image, BOOL isPlaceholder))callBack {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.imageManager requestImageForAsset:photo.asset targetSize:targetSize contentMode:PHImageContentModeDefault options:self.originRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (info != nil) {
                if ((NSURL *)info[@"PHImageFileURLKey"]) {
                    NSURL *url = (NSURL *)info[@"PHImageFileURLKey"];
                    photo.type = url.pathExtension.lowercaseString;
                    photo.url = url;
                }else {
                    photo.type = @"jpg";
                }
                
                NSInteger orientation = (NSInteger)info[@"PHImageFileOrientationKey"];
                if (orientation) {
                    switch (orientation) {
                        case 0: case 4:
                            photo.orientation = 0;
                            break;
                        case 1: case 5:
                            photo.orientation = 100;
                            break;
                        case 2: case 6:
                            photo.orientation = -90;
                            break;
                        case 3: case 7:
                            photo.orientation = 90;
                            break;
                        default:
                            photo.orientation = 0;
                            break;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL scuess = [info[@"PHImageResultIsDegradedKey"] boolValue];
                    if (callBack) {
                        callBack(result, scuess);
                    }
                });
            }
        }];
    });
}

/// 根据localIdentifier返回PHAsset
- (void)photoByIdentifier: (NSString *)identifier callBack: (void(^)(UIImage * _Nullable image, NSString * _Nullable type, NSURL * _Nullable url))callBack {
    [_photo photoByIdentifier:identifier targetSize:PHImageManagerMaximumSize callBack:callBack];
}

- (void)photoByIdentifier: (NSString *)identifier targetSize: (CGSize)targetSize callBack: (void(^)(UIImage * _Nullable image, NSString * _Nullable type, NSURL * _Nullable url))callBack {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PHFetchResult<PHAsset *> *assetFetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil];
        if (assetFetchResult.firstObject) {
            [self.imageManager requestImageForAsset:assetFetchResult.firstObject targetSize:targetSize contentMode:PHImageContentModeDefault options:self.originRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSURL *url = info[@"PHImageFileURLKey"];
                    NSString *type = @"jpg";
                    if (url.pathExtension.lowercaseString) {
                        type = url.pathExtension.lowercaseString;
                    }
                    if (callBack) {
                        callBack(result, type, url);
                    }
                });
            }];
        }
    });
}

/// 通过PHAsset获得视频URL
- (void)avasetByPHAssetWithPHAsset: (PHAsset *)asset callBack: (void(^)(AVAsset * _Nullable avasset, AVAudioMix * _Nullable avaudioMix, NSDictionary * _Nullable dict))callBack {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc]init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.networkAccessAllowed = true;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.imageManager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callBack) {
                    callBack(asset, audioMix, info);
                }
            });
        }];
    });
}

/// 将图片保存到相册
- (void)savePhotoImage: (UIImage *)image completionTarget: (id)target completion: (SEL)completion {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        UIImageWriteToSavedPhotosAlbum(image, target, completion, nil);
    });
}

/// 传入NSURL将图片保存到相册
- (void)saveFileToAlbumUrl: (NSURL *)url completion: (void(^)(void))completion {
    NSError *error = nil;
    __block NSString *createdAssetID = nil;
    BOOL success = [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:[UIImage imageWithContentsOfFile:url.absoluteString]].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    if (success) {
        Log(@"保存成功");
    }else {
        Log(@"保存失败： %@", &error);
    }
}

///获取所有相册， 并且获取最后一张照片
- (void)getLastPhoto: (void(^)(Photo * _Nullable photo))callback {
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending: true]];
    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    if (fetchResult.firstObject != nil) {
        PHAsset *lastAsset = fetchResult.firstObject;
        if (lastAsset != nil) {
            Photo *model = [Photo new];
            model.name = [lastAsset valueForKey:@"filename"];
            model.identifier = lastAsset.localIdentifier;
            model.asset = lastAsset;
            if (callback) {
                callback(model);
            }
        }else {
            if (callback) {
                callback(nil);
            }
        }
    }else {
        if (callback) {
            callback(nil);
        }
    }
}

/// 将视频转成mp4并且放到指定路径下    注意:所有回调都在子线程中
- (void)importVideoAsset: (PHAsset *)asset toPath: (NSString *)toPath onStart: (void(^)(AVAssetExportSession * _Nullable session))start onComplete: (void(^)(void))complete onFailed: (void(^)(NSError * _Nullable error))failed {
    [[PHImageManager defaultManager]requestExportSessionForVideo:asset options:nil exportPreset:AVAssetExportPresetPassthrough resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
        NSURL *outputURL = [NSURL fileURLWithPath:toPath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.outputURL = outputURL;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if (exportSession.status == AVAssetExportSessionStatusFailed) {
                if (failed) {
                    failed(exportSession.error);
                }
            }else if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                if (complete) {
                    complete();
                }
            }else if (exportSession.status == AVAssetExportSessionStatusExporting) {
                if (start) {
                    start(exportSession);
                }
            }
        }];
    }];
}

@end
