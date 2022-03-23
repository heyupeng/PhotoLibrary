//
//  HYPAlbumViewController.h
//  PhotosLibrary
//
//  Created by Peng on 2018/11/23.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#import "HYPImageManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYPPickerManager : NSObject

@end

@interface HYPAlbumViewController : UIViewController

@property (nonatomic) HYPMediaType showMediaType;

@property (nonatomic) BOOL isCanSelectImage;

@property (nonatomic) BOOL isCanSelectVideo;

@property (nonatomic) BOOL isShowEmptyAlbumCollection;

@property (nonatomic, strong) void(^completion)(BOOL isSuccess, NSArray * items);

@end

NS_ASSUME_NONNULL_END
