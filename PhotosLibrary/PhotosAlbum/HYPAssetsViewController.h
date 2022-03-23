//
//  HYPAssetsViewController.h
//  PhotosLibrary
//
//  Created by Peng on 2018/11/26.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYPAssetsViewController : UIViewController

@property (nonatomic, strong) PHFetchResult<PHAsset *> * result;

@property (nonatomic, strong) void(^completion)(BOOL isSuccess, NSArray * items);
@end

NS_ASSUME_NONNULL_END
