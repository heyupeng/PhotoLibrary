//
//  UIImage+Editor.h
//  PhotosLibrary
//
//  Created by Peng on 2018/12/4.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Editor)

- (UIImage *)compressWithSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
