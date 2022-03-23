//
//  UIImage+Editor.m
//  PhotosLibrary
//
//  Created by Peng on 2018/12/4.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "UIImage+Editor.h"

@implementation UIImage (Editor)

- (UIImage *)compressWithSize:(CGSize)size {
    UIImage * resultImage;
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

@end
