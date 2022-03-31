//
//  CI.m
//  PhotosLibrary
//
//  Created by Peng on 2022/3/29.
//  Copyright © 2022 heyupeng. All rights reserved.
//

#import "ColorConversion.h"
#import <math.h>
#if !defined(MAX3)
    #define MAX_XYZ(X, Y, Z) MAX(MAX(X, Y), Z)
    #define MAX3(X, Y, Z) MAX_XYZ(X, Y, Z)
#endif

#if !defined(MIN3)
    #define MIN_XYZ(X, Y, Z) MIN(MIN(X, Y), Z)
    #define MIN3(X, Y, Z) MIN_XYZ(X, Y, Z)
#endif

/// RGB To HSV,  HSB。
///
/// 色调（H），饱和度（S）, 价值（V）
/// @param rgb r,g,b数值区间 [0, 1]。
/// @param hsv 数值区间 [0, 1]。
void RGBToHSV(float * rgb, float * hsv) {
    float max, min, delta;
    max = MAX3(rgb[0], rgb[1], rgb[2]);
    min = MIN3(rgb[0], rgb[1], rgb[2]);
    delta = max - min;
    
    float h = 0, s = 0, v = 0;
    if (delta != 0) {
        if (max == rgb[0]) {
            h = 60 * ((rgb[1] - rgb[2]) / delta + 0);
            if (h < 0) h += 360;
        }
        else if (max == rgb[1]) {
            h = 60 * ((rgb[2] - rgb[0]) / delta + 2);
        }
        else if (max == rgb[2]) {
            h = 60 * ((rgb[0] - rgb[1]) / delta + 4);
        }
        // [0, 360] => [0, 1];
        h /= 360.0;
    }
    if (max != 0) {
        s = delta / max;
    }
    v = max;
    
    hsv[0] = h; hsv[1] = s; hsv[2] = v;
}


/// RGB to HSL
/// @param rgb RGB三色，数值区间 [0, 1]。
/// @param hsl Hue (H), Saturation (S), Lightness (L) .
void RGBToHSL(float * rgb, float * hsl) {
    float max, min, delta;
    max = MAX3(rgb[0], rgb[1], rgb[2]);
    min = MIN3(rgb[0], rgb[1], rgb[2]);
    delta = max - min;
    
    float h = 0, s = 0, l = 0;
    
    // lightness
    l = (max + min) * 0.5;
    
    // hue
    if (delta != 0) {
        if (max == rgb[0]) {
            h = 60 * ((rgb[1] - rgb[2]) / delta + 0);
            if (h < 0) h += 360;
        }
        else if (max == rgb[1]) {
            h = 60 * ((rgb[2] - rgb[0]) / delta + 2);
        }
        else if (max == rgb[2]) {
            h = 60 * ((rgb[0] - rgb[1]) / delta + 4);
        }
        // [0, 360] => [0, 1];
        h /= 360.0;
    }
    
    // saturation
    if (delta != 0) {
        s = delta / (1 - ABS(2 * l - 1));
    }
    
    hsl[0] = h; hsl[1] = s; hsl[2] = s;
}
