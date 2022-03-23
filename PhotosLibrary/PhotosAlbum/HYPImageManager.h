//
//  HYPImageManager.h
//  PhotosLibrary
//
//  Created by Peng on 2018/11/30.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN
@class HYPAlbumModel;

typedef NS_ENUM(NSUInteger, HYPMediaType) {
    HYPMediaTypeAll = 0,
    HYPMediaTypeImage = 1,
    HYPMediaTypeVideo,
};

@interface HYPImageManager : NSObject

+ (instancetype)share;
+ (void)destroy;

// 默认为HYPMediaTypeAll。设置为HYPMediaTypeImage，只显示图片.
@property (nonatomic) HYPMediaType showMediaType;

// 默认为YES。 设置为NO，图片不可选
@property (nonatomic) BOOL isCanSelectImage;

// 默认为YES。 设置为NO，视频不可选
@property (nonatomic) BOOL isCanSelectVideo;

// 默认为NO。 设置为YES可显示空白相集
@property (nonatomic) BOOL isShowEmptyAlbumCollection;

// 默认为NO。 设置为YES按时间升序
@property (nonatomic) BOOL sortAscendingDate;

- (NSMutableArray *)fetchAblumsWithMediaType:(HYPMediaType)mediaType;

- (NSArray *)getAlbumModelsWithCollections:(PHFetchResult<PHAssetCollection *> *)collections options:(PHFetchOptions *)options;
@end

NS_ASSUME_NONNULL_END
