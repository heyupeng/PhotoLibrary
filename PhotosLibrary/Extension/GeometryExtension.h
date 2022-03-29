//
//  GeometryExtension.h
//  PhotosLibrary
//
//  Created by Peng on 2019/1/3.
//  Copyright © 2019年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

// CGPoint Add, subtract, multiply divide
CG_INLINE CGPoint CGPointAddPoint(CGPoint point1, CGPoint point2);

CG_INLINE CGPoint CGPointSubtractPoint(CGPoint point1, CGPoint point2);

// CGSize
CG_INLINE CGSize CGSizeFromScale(CGSize size, CGFloat scale);

// CGRect
CG_INLINE CGPoint CGRectGetInnerCenterPoint(CGRect rect);

CG_INLINE CGPoint CGRectGetMinPoint(CGRect rect);

CG_INLINE CGPoint CGRectGetMaxPoint(CGRect rect);


// CGPoint
CG_INLINE CGFloat CGPointGetDistance(CGPoint point) {
    return sqrt(pow(point.x, 2) + pow(point.x, 2));
}

CG_INLINE CGFloat CGPointGetDistanceToPoint(CGPoint point1, CGPoint point2) {
    return CGPointGetDistance(CGPointSubtractPoint(point1, point2));
}

CG_INLINE CGPoint CGPointAddPoint(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

CG_INLINE CGPoint CGPointSubtractPoint(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

// CGSize
CG_INLINE CGSize CGSizeFromScale(CGSize size, CGFloat scale) {
    return CGSizeMake(size.width * scale, size.height * scale);
}

// CGRect
CG_INLINE CGPoint CGRectGetInnerCenterPoint(CGRect rect) {
    //    return CGPointMake(CGRectGetWidth(rect) * 0.5, CGRectGetHeight(rect) * 0.5);
    return CGPointMake(rect.size.width * 0.5, rect.size.height * 0.5);
}

CG_INLINE CGPoint CGRectGetMinPoint(CGRect rect) {
    return CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
}

CG_INLINE CGPoint CGRectGetMaxPoint(CGRect rect) {
    return CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
}

CG_EXTERN CGRect CGRectEdgeInsets(CGRect rect, UIEdgeInsets insets);
