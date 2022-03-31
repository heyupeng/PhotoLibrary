//
//  HYPAssetModel.h
//  PhotosLibrary
//
//  Created by Peng on 2018/11/29.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - HYPAssetModel
@interface HYPAssetModel : NSObject

@property (nonatomic, strong) PHAsset * asset;

@property (nonatomic, strong) NSString * title;

@property (nonatomic, strong, nullable) UIImage * image;

@property (nonatomic, strong, nullable) UIImage * previewImage;

@property (nonatomic, strong, nullable) UIImage * originImage;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic) NSUInteger selectedIndex;

// 用于记录 Asset requestImage
@property (nonatomic) PHImageRequestID requestID;

- (void)requestImageWithSize:(CGSize)size compeletion:(void(^)(UIImage *image, NSDictionary * info))completion;

- (void)resetImages;

@end

#pragma mark - HYPAlbumModel
@interface HYPAlbumModel : NSObject

@property (nonatomic, strong) PHAssetCollection * collection;

@property (nonatomic, strong) PHFetchOptions * options;

// collection 图集
@property (nonatomic, strong) PHFetchResult<PHAsset *> * fetchResult;

@property (nonatomic, strong) NSString * title;
// 图集容量 [fetchResult count]
@property (nonatomic, readonly) NSInteger count;

@property (nonatomic, strong) UIImage * image;

- (instancetype)initWithAssetCollection:(PHAssetCollection *)collection options:(PHFetchOptions *)options;

- (void)requestSmallImage:(void (^)(UIImage * image))handler;

@end
NS_ASSUME_NONNULL_END
