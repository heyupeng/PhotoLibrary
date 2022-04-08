//
//  HYPFilterHelper.h
//  PhotosLibrary
//
//  Created by Peng on 2018/12/5.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterAttributesController : UIViewController

@property (nonatomic, strong) CIFilter * filter;

@property (nonatomic, copy) void(^FilterAttributesValueChangedBlock)(CIFilter * filter, NSDictionary * att);
@end

NS_ASSUME_NONNULL_END
