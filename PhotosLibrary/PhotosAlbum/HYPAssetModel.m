//
//  HYPAssetModel.m
//  PhotosLibrary
//
//  Created by Peng on 2018/11/29.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "HYPAssetModel.h"

/*
 {
 PHImageFileOrientationKey = 0;
 PHImageResultDeliveredImageFormatKey = 4031;
 PHImageResultIsDegradedKey = 1;
 PHImageResultRequestIDKey = 29;
 PHImageResultWantedImageFormatKey = 4037;
 }
 
 {
 PHImageFileOrientationKey = 0;
 PHImageFileSandboxExtensionTokenKey = "737e5d95c8d84737c53e393a2b493074d5266b1f;00000000;00000000;000000000000001a;com.apple.app-sandbox.read;01;01000003;0000000000d02da6;/private/var/mobile/Media/DCIM/100APPLE/IMG_0060.JPG";
 PHImageFileURLKey = "file:///var/mobile/Media/DCIM/100APPLE/IMG_0060.JPG";
 PHImageFileUTIKey = "public.jpeg";
 PHImageResultDeliveredImageFormatKey = 9999;
 PHImageResultIsDegradedKey = 0;
 PHImageResultIsInCloudKey = 0;
 PHImageResultIsPlaceholderKey = 0;
 PHImageResultRequestIDKey = 29;
 PHImageResultWantedImageFormatKey = 4037;
 }
 
 {
 PHImageErrorKey = "Error Domain=CloudPhotoLibraryErrorDomain Code=25 \"Record Acjj/dy3w3g14pb7UP5B4lOb0Zxn does not exist\" UserInfo={NSLocalizedDescription=Record Acjj/dy3w3g14pb7UP5B4lOb0Zxn does not exist}";
 PHImageResultDeliveredImageFormatKey = 4037;
 PHImageResultIsDegradedKey = 0;
 PHImageResultIsInCloudKey = 1;
 PHImageResultIsPlaceholderKey = 0;
 PHImageResultRequestIDKey = 29;
 PHImageResultWantedImageFormatKey = 4037;
 }
 */
#pragma mark - HYPAssetModel
@implementation HYPAssetModel

- (PHImageRequestID)requestImageForAsset:(PHAsset *)asset targetSize:(CGSize)size compeletion:(void(^)(UIImage * image, NSDictionary * info))compeletion {
    /*
     PHImageRequestOptionsDeliveryModeHighQualityFormat //client将只获得一个结果 asynchronous
     PHImageRequestOptionsDeliveryModeFastFormat //  synchronous
     */
    PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.networkAccessAllowed = true;
    
    PHImageRequestID requestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (compeletion) {compeletion(result, info);}
    }];
    return requestID;
}

- (void)requestImageWithSize:(CGSize)size compeletion:(void(^)(UIImage *image, NSDictionary * info))completion {
    if (self.requestID != 0) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.requestID];
    }
    
    PHImageRequestID requestID = [self requestImageForAsset:self.asset targetSize:size compeletion:^(UIImage *image, NSDictionary *info) {
        self.requestID = 0;
        if (completion) {
            completion(image, info);
        }
    }];
    _requestID = requestID;
}

- (void)requestPostImageWithSize:(CGSize)size compeletion:(void(^)(HYPAssetModel * model))completion {
//    if (self.postImage) {
//        if (completion) { completion(self); }
//        return;
//    }
    
    weakly(self);
    [self requestImageWithSize:size compeletion:^(UIImage * _Nonnull image, NSDictionary * _Nonnull info) {
        strongly(self);
        strongself.postImage = image;
        if ([[info objectForKey:PHImageResultIsDegradedKey] intValue] == 0) {
            if ([info objectForKey:@"PHImageFileURLKey"]) {
                strongself.originImage = image;
                strongself.previewImage = image;
            }
        }
        if (completion) {
            completion(strongself);
        }
    }];
}

- (void)requestPreviewImageWithSize:(CGSize)size completion:(void(^)(HYPAssetModel * model))completion {
    
    weakly(self);
    [self requestImageWithSize:size compeletion:^(UIImage * _Nonnull image, NSDictionary * _Nonnull info) {
        strongly(self);
        if ([[info objectForKey:PHImageResultIsDegradedKey] intValue] == 0) {
            strongself.previewImage = image;
            if ([info objectForKey:@"PHImageFileURLKey"]) {
                strongself.originImage = image;
            }
        }
        if (completion) completion(strongself);
    }];
}

- (void)resetImages {
    self.postImage = nil;
    self.previewImage = nil;
    self.originImage = nil;
}

@end

#pragma mark - HYPAlbumModel
@implementation HYPAlbumModel

- (instancetype)initWithAssetCollection:(PHAssetCollection *)collection options:(PHFetchOptions *)options {
    if ([self init]) {
        _collection = collection;
        _options = options;
    }
    return self;
}

// Small image
- (void)requestPostImageCompletion:(void(^)(UIImage * image, NSDictionary * info))completion {
    
    CGSize size = CGSizeMake(180, 180);
    PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.networkAccessAllowed = true;
    
    // 最新资源
    PHAsset * asset = [self.fetchResult.lastObject.creationDate compare:self.fetchResult.firstObject.creationDate] == NSOrderedDescending? self.fetchResult.lastObject: self.fetchResult.firstObject;
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:1 options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completion) {
            completion(result, info);
        }
    }];
}
- (void)requestSmallImage:(void (^)(UIImage * image))handler {
    if (_image) {
        handler(_image);
        return;
    }
    [self requestPostImageCompletion:^(UIImage *image, NSDictionary *info) {
        self.image = image;
        if (handler) {
            handler(image);
        }
    }];
}

- (NSString *)title {
    if (_title) return _title;
    return _collection.localizedTitle;
}

- (NSInteger)count {
    if (self.fetchResult) {
        return [self.fetchResult count];
    }
    return 0;
}

@end
