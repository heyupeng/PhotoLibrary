//
//  HYPPreviewViewController.h
//  PhotosLibrary
//
//  Created by Peng on 2018/11/29.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "GeometryExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYPPreviewViewController : UIViewController

@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) NSMutableArray * selectedItems;

@property (nonatomic, strong) NSIndexPath * currenIndexPath;

@property (nonatomic, strong) void(^completion)(BOOL isSuccess, NSArray * items);

@end

NS_ASSUME_NONNULL_END
