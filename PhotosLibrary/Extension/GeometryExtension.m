//
//  GeometryExtension.m
//  PhotosLibrary
//
//  Created by Peng on 2019/1/3.
//  Copyright © 2019年 heyupeng. All rights reserved.
//

#import "GeometryExtension.h"

CG_EXTERN CGRect CGRectEdgeInsets(CGRect rect, UIEdgeInsets insets) {
    CGRect newRect = rect;
    rect.origin.x += insets.left;
    rect.origin.y += insets.top;
    rect.size.width -= insets.right + insets.left;
    rect.size.height -= insets.top + insets.bottom;
    return newRect;
}
