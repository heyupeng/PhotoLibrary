//
//  ColorConversion.h
//  PhotosLibrary
//
//  Created by Peng on 2022/3/29.
//  Copyright © 2022 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/// RGB To HSV, also HSB .
void RGBToHSV(float * rgb, float * hsv);

/// RGB To HSL .
void RGBToHSL(float * rgb, float * hsl);

NS_ASSUME_NONNULL_END
