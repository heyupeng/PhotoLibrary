//
//  HYPEditImageViewController.h
//  PhotosLibrary
//
//  Created by Peng on 2019/1/3.
//  Copyright © 2019年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#import "GeometryExt.h"
#import "HYPAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYPEditImageViewController : UIViewController

@property (nonatomic, strong) HYPAssetModel * model;

@property (nonatomic, strong) UIImage * inputImage;
@property (nonatomic, strong) UIImage * outputImage;

@end

NS_ASSUME_NONNULL_END
