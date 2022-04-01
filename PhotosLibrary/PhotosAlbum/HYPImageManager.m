//
//  HYPImageManager.m
//  PhotosLibrary
//
//  Created by Peng on 2018/11/30.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "HYPImageManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "HYPAssetModel.h"

@interface HYPImageManager ()

@end

@implementation HYPImageManager

static HYPImageManager * shareManager;

+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[self alloc] init];
    });
    return shareManager;
}

+ (void)destroy {
    if (shareManager) {
        shareManager = nil;
    }
}

- (instancetype)init {
    self = [super init];
    _showMediaType = HYPMediaTypeAll;
    
    _isCanSelectImage = YES;
    
    _isCanSelectVideo = NO;
    
    _isShowEmptyAlbumCollection = NO;
    _sortAscendingDate = NO;
    return self;
}

- (NSMutableArray *)fetchAblumsWithMediaType:(HYPMediaType)mediaType {
    _showMediaType = mediaType;
    
    // Create a PHFetchResult object for each section in the table view.
    NSPredicate *predicate;
    if (mediaType == HYPMediaTypeImage) {
        predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    }
    else if (mediaType == HYPMediaTypeVideo) {
        predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    }
    
    NSMutableArray * dataSource = [NSMutableArray new];

    PHFetchOptions * options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:_sortAscendingDate]];
    options.predicate = predicate;
    
    PHFetchResult<PHAsset *> * allPhotos = [PHAsset fetchAssetsWithOptions:options];
    HYPAlbumModel * albumModel = [[HYPAlbumModel alloc] init];
//    albumModel.collection = collection;
    albumModel.options = options;
    albumModel.fetchResult = allPhotos;
    albumModel.title = NSLocalizedString(@"All Photos", comment: @""); // @"allPhotos";
    
    [dataSource addObject:albumModel];
    
    PHFetchResult<PHAssetCollection *> * smartAlbumCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    PHFetchResult<PHAssetCollection *> * albumCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
    [dataSource addObjectsFromArray:[self getAlbumModelsWithCollections:smartAlbumCollections options:options]];
    
    [dataSource addObjectsFromArray:[self getAlbumModelsWithCollections:albumCollections options:options]];
    
    return dataSource;
}

- (NSArray *)getAlbumModelsWithCollections:(PHFetchResult<PHAssetCollection *> *)collections options:(PHFetchOptions *)options {
    
    NSMutableArray * dataSource = [NSMutableArray new];
    
    for (PHAssetCollection * collection in collections) {
        
        // 过滤「最近删除」相集 Recently Deleted
        if (collection.assetCollectionSubtype == 1000000201) {continue;}
        
        PHFetchResult<PHAsset *> * result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        
        // 过滤空相集
        if (!_isShowEmptyAlbumCollection && result.count < 1) continue;
        
        HYPAlbumModel * albumModel = [[HYPAlbumModel alloc] init];
        albumModel.collection = collection;
        albumModel.options = options;
        albumModel.fetchResult = result;
        
        [dataSource addObject:albumModel];
    }
    return dataSource;
}

@end
